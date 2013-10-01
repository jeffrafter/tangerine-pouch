# This file loads the most basic settings related to Tangerine and kicks off Backbone's router.
#   * The doc `configuration` holds the majority of settings.
#   * The Settings object contains many convenience functions that use configuration's data.
#   * Templates should contain objects and collections of objects ready to be used by a Factory.
# Also intialized here are: Backbone.js, and jQuery.i18n

# Utils.disableConsoleLog()
# Utils.disableConsoleAssert()

Tangerine =
  "db_name"    : window.location.pathname.split("/")[1]
  "design_doc" : _.last(String(window.location).split("_design/")).split("/")[0]

# Local tangerine database handle
Tangerine.$db = $.couch.db(Tangerine.db_name)

# Backbone configuration
# Backbone.couch_connector.config.db_name   = Tangerine.db_name
# Backbone.couch_connector.config.ddoc_name = Tangerine.design_doc
# Backbone.couch_connector.config.global_changes = false
Backbone.sync = BackbonePouch.sync({
  db: PouchDB('tangerine')
});
Backbone.Model.prototype.idAttribute = '_id';

# set underscore's template engine to accept handlebar-style variables
_.templateSettings = interpolate : /\{\{(.+?)\}\}/g

Tangerine.onBackButton = (event) ->
  if Tangerine.activity == "assessment run"
    if confirm t("NavigationView.message.incomplete_main_screen")
      Tangerine.activity = ""
      window.history.back()
    else
      return false
  else
    window.history.back()


# Grab our system config doc
Tangerine.config = new Backbone.Model(configuration)

# Tangerine.config.fetch
#  error   : ->
#    console.log "could not fetch configuration"
#
#  success : ->

# get our Tangerine settings
Tangerine.settings = new Settings "_id" : "settings"
Tangerine.settings.fetch
  success: ->

    # guarentee instanceId
    Tangerine.settings.set "instanceId", Utils.humanGUID() unless Tangerine.settings.has("instanceId")

    Tangerine.onSettingsLoad()
  error: ->
    Tangerine.settings.set Tangerine.config.get("defaults")['settings']

    # generate a random ID for this individual instance
    Tangerine.settings.set "instanceId", Utils.humanGUID()

    Tangerine.settings.save null,
      error: ->
        console.log "couldn't save new settings"
      success: ->
        Tangerine.onSettingsLoad()

Tangerine.onSettingsLoad = ->

  # Template files for ease of use in grids
  # Tangerine.templates = new Template "_id" : "templates"
  # Tangerine.templates.fetch
  #  success: ->
  Tangerine.templates = new Template(templates)

  Tangerine.ensureAdmin ->
    Tangerine.transitionUsers ->
      $ ->
        # Start the application

        window.vm = new ViewManager()

        #$("<button id='reload'>reload me</button>").appendTo("#footer").click -> document.location.reload()

        $.i18n.init
          "fallbackLng" : "en"
          "lng"         : Tangerine.settings.get "language"
          "resGetPath"  : "locales/__lng__/translation.json"
        , (t) ->
          window.t = t


          if Tangerine.settings.get("context") != "server"
            document.addEventListener "deviceready"
            , ->
              document.addEventListener "online", -> Tangerine.online = true
              document.addEventListener "offline", -> Tangerine.online = false

              ### Note, turns on menu button
              document.addEventListener "menubutton", (event) ->
                console.log "menu button"
              , false
              ###

              # prevents default
              document.addEventListener "backbutton", Tangerine.onBackButton, false
            , false


          # Singletons
          Tangerine.router = new Router()
          Tangerine.user   = if Tangerine.settings.get("context") is "server"
              new User()
            else
              new TabletUser()
          Tangerine.nav    = new NavigationView
            user   : Tangerine.user
            router : Tangerine.router
          Tangerine.log    = new Log()

          Tangerine.user.sessionRefresh
            success: ->
              $("body").addClass(Tangerine.settings.get("context"))

              Backbone.history.start()

# make sure all users in the _users database have a local user model for future use
Tangerine.transitionUsers = (callback) ->

  return callback() if Tangerine.settings.get("context") is "server" or Tangerine.settings.has("usersTransitioned")

  $.couch.login
    name     : "admin"
    password : "password"
    success: ->
      $.couch.userDb (uDB) =>
        resp = uDB.allDocs
        docIds = _.pluck(resp.rows, "id").filter (a) -> ~a.indexOf("org.couchdb")
        nextDoc = () ->
          id = docIds.pop()
          return finish() unless id?
          if doc = uDB.get id
            teacher = null
            # console.log doc
            name = doc._id.split(":")[1]

            hashes =
              if doc.password_sha?
                pass : doc.password_sha
                salt : doc.salt
              else
                TabletUser.generateHash("password")

            teacherId = doc.teacherId
            unless teacherId?
              teacherId = Utils.humanGUID()
              teacher = new Teacher "_id" : teacherId, "name" : name

            if name is "admin"
              roles = ["_admin"]
              hashes = TabletUser.generateHash("password")
            else
              roles = doc.roles || []


            newDoc =
              "_id"   : TabletUser.calcId(name)
              "name"  : name
              "roles" : roles
              "pass"  : hashes.pass
              "salt"  : hashes.salt
              "teacherId"  : teacherId
              "collection" : "user"
            #return
            Tangerine.$db.saveDoc newDoc,
              success: (doc) ->
                if teacher?
                  teacher.save null,
                    success: ->
                      nextDoc()
                else
                  nextDoc()

              error: (doc) ->
                nextDoc()

        finish = ->
          Tangerine.settings.save "usersTransitioned" : true,
            success: ->
              $.couch.logout
                success: ->
                  callback()

        nextDoc() # kick it off


# if admin user doesn't exist in _users database, create it
Tangerine.ensureAdmin = (callback) ->
  if Tangerine.settings.get("context") != "server" && not Tangerine.settings.has("adminEnsured")
    $.couch.login
      name     : "admin"
      password : "password"
      success: ->
        $.couch.userDb (uDB) =>
          if doc = uDB.get "org.couchdb.user:admin"
            $.couch.logout
              success:->
                Tangerine.settings.save "adminEnsured" : true
                callback()
              error: ->
                console.log "error logging out admin user"
          else
            if doc = uDB.put
              name     : "admin"
              password : null
              roles    : []
              type     : "user"
              _id      : "org.couchdb.user:admin"
              Tangerine.settings.save "adminEnsured" : true
              $.couch.logout
                success: -> callback()
                error: ->
                  console.log "Error logging out admin user"
  else
    callback()
