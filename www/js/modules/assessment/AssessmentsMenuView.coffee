class AssessmentsMenuView extends Backbone.View

  className: "AssessmentsMenuView"

  events:
    'keypress .new_name' : 'newSave'
    'click .new_save'    : 'newSave'
    'click .new_cancel'  : 'newToggle'
    'click .new'         : 'newToggle'
    'click .import'      : 'import'
    'click .apk'         : 'apk'
    'click .groups'      : 'gotoGroups'
    'click .universal_upload' : 'universalUpload'

    'click .sync_tablets' : 'syncTablets'

    'click .results'        : 'results'
    'click .settings'       : 'editInPlace'
    'keyup .edit_in_place'  : 'saveInPlace'
    'change .edit_in_place'  : 'saveInPlace'

  syncTablets: =>
    @tabletManager.sync()

  editInPlace: (event) ->
    return unless Tangerine.user.isAdmin()
    $target    = $(event.target)
    attribute  = $target.attr("data-attribtue")
    @oldTarget = $target.clone()
    classes = $target.attr("class").replace("settings","")
    margins = $target.css("margin")
    $target.after("<input type='text' style='margin:#{margins};' data-attribute='#{attribute}' class='edit_in_place #{classes}' value='#{_.escape($target.html())}'>")
    input = $target.next().focus()
    $target.remove()

  saveInPlace: (event) ->

    return if @alreadySaving

    if event.keyCode
      if event.keyCode == 27
        $(event.target).after(@oldTarget).remove()
        return
      else if event.keyCode != 13
        return true

    @alreadySaving = true
    $target   = $(event.target)
    attribute = $target.attr("data-attribute")
    value     = $target.val()

    updatedAttributes            = {}
    updatedAttributes[attribute] = value

    Tangerine.settings.save updatedAttributes, 
      success: =>
        @alreadySaving = false
        Utils.topAlert("Saved")
        $target.after(@oldTarget.html(value)).remove()
      error: =>
        @alreadySaving = false
        Utils.topAlert("Save error")
        $target.after(@oldTarget).remove()

  results: -> Tangerine.router.navigate "dashboard", true

  universalUpload: -> Utils.universalUpload()

  apk: ->
    TangerineTree.make
      success: (data) ->
        a = document.createElement("a")
        a.href = Tangerine.settings.config.get("tree")
        Utils.sticky("<h1>APK link</h1><p>#{a.host}/apk/#{data.token}</p>")
      error: (xhr, response) ->
        Utils.sticky response.error

  gotoGroups: -> Tangerine.router.navigate "groups", true

  import:     -> Tangerine.router.navigate "import", true

  initialize: (options) ->

    if Tangerine.settings.get("context") == "mobile"
      @tabletManager = new TabletManagerView
        docTypes : ["result"]
        callbacks: 
          completePull: => @tabletManager.pushDocs()

    @[key] = value for key, value of options
      


    @assessments.each (assessment) => assessment.on "new", @addAssessment
    @curricula.each   (curriculum) => curriculum.on "new", @addCurriculum

    @curriculaListView = new CurriculaListView
      "curricula" : @curricula

    @assessmentsView = new AssessmentsView
      "assessments" : @assessments
      "parent"      : @

    @usersMenuView = new UsersMenuView

  render: =>
    
    isAdmin = Tangerine.user.isAdmin
    
    newButton     = "<button class='new command'>New</button>"
    importButton  = "<button class='import command'>Import</button>"
    apkButton     = "<button class='apk navigation'>APK</button>"
    groupsButton  = "<button class='navigation groups'>Groups</button>"
    uploadButton  = "<button class='command universal_upload'>Universal Upload</button>"
    syncTabletsButton = "<button class='command sync_tablets'>Sync Tablets</button>"
    resultsButton = "<button class='navigation results'>Results</button>"
    groupHandle   = "<h2 class='settings grey' data-attribtue='groupHandle'>#{Tangerine.settings.getEscapedString('groupHandle') || Tangerine.settings.get('groupName')}</h2>"


    containers = []
    containers.push "<section id='curricula_container' class='CurriculaListView'></section>" if @curricula.length isnt 0
    if Tangerine.settings.get("context") is "server"
      containers.push "<section id='klass_container' class='KlassesView'></section>"         if @klasses.length isnt 0
      containers.push "<section id='teachers_container' class='TeachersView'></section>"     if @teachers.length isnt 0
      containers.push "<section id='users_menu_container' class='UsersMenuView'></section>"  if @users.length isnt 0



    html = "
      #{Tangerine.settings.contextualize(
        server : "
          #{groupsButton}
          #{apkButton}
          #{resultsButton} 
          #{groupHandle}
          "
        ) }
      <section>
        <h1>Assessments</h1>
    "

    if isAdmin
      html += "
          #{if Tangerine.settings.get("context") == "server" then newButton else "" }
          #{importButton}

          

          <div class='new_form confirmation'>
            <div class='menu_box'>
              <input type='text' class='new_name' placeholder='Name'>
              <select id='new_type'>
                <option value='assessment'>Assessment</option>
                <option value='curriculum'>Curriculum</option>
              </select><br>
              <button class='new_save command'>Save</button> <button class='new_cancel command'>Cancel</button>
            </div>
          </div>
          <div id='assessments_container'></div>
        </section>

        #{containers.join('')}

        #{if Tangerine.settings.get("context") == "mobile" then syncTabletsButton else "" }
        #{if Tangerine.settings.get("context") == "mobile" then uploadButton else "" }

      "
    else
      html += "
        <div id='assessments_container'></div>
      </section>
        <br>
        #{if Tangerine.settings.get("context") == "mobile" then syncTabletsButton else "" }
        #{if Tangerine.settings.get("context") == "mobile" then uploadButton else "" }
      "

    @$el.html html

    @assessmentsView.setElement( @$el.find("#assessments_container") )
    @assessmentsView.render()

    @curriculaListView.setElement( @$el.find("#curricula_container") )
    @curriculaListView.render()

    if Tangerine.settings.get("context") == "server"
      @usersMenuView.setElement( @$el.find("#users_menu_container") )
      @usersMenuView.render()

      if @klasses.length > 0
        @klassesView = new KlassesView
          klasses : @klasses
          curricula : @curricula
          teachers : @teachers
        @klassesView.setElement @$el.find("#klass_container")
        @klassesView.render()
      else
        @$el.find("#klass_container").remove()


      if @teachers.length > 0
        @teachersView = new TeachersView
          teachers : @teachers
          users : @users
        @teachersView.setElement @$el.find("#teachers_container")
        @teachersView.render()
      else
        @$el.find("#teachers_container").remove()

    

    @trigger "rendered"

    return


  addAssessment: (newOne) =>
    @assessments.add newOne
    newOne.on "new", @addAssessment

  addCurriculum: (newOne) =>
    @curricula.add newOne
    newOne.on "new", @addCurriculum

  # Making a new assessment
  newToggle: -> @$el.find('.new_form, .new').fadeToggle(250); false

  newSave: (event) =>

    # this handles ambiguous events
    # the idea is to support clicks and the enter key
    # logic:
    # it it's a keystroke and it's not enter, act normally, just a key stroke
    # if it's a click or enter, process the form

    if event.type != "click" && event.which != 13
      return true

    name    = @$el.find('.new_name').val()
    newType = @$el.find("#new_type option:selected").val()
    newId   = Utils.guid()

    if name.length == 0
      Utils.midAlert "<span class='error'>Could not save <img src='images/icon_close.png' class='clear_message'></span>"
      return false

    if newType == "assessment"
      newObject = new Assessment
        "name"         : name
        "_id"          : newId
        "assessmentId" : newId
        "archived"     : false
      callback = @addAssessment
    else if newType == "curriculum"
      newObject = new Curriculum
        "name"         : name
        "_id"          : newId
        "curriculumId" : newId
      callback = @addCurriculum

    newObject.save null,
      success : => 
        callback(newObject)
        @$el.find('.new_form, .new').fadeToggle(250, => @$el.find('.new_name').val(""))
        Utils.midAlert "#{name} saved"
      error: =>
        @$el.find('.new_form, .new').fadeToggle(250, => @$el.find('.new_name').val(""))
        Utils.midAlert "Please try again. Error saving."

    return false

  # ViewManager
  closeViews: ->
    @assessmentsView.close()
    @curriculaListView.close()

  onClose: ->
    @closeViews()
