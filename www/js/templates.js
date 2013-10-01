var templates = {
  "collection": "template",
  "subtest": {
      "enumeratorHelp"    : "",
      "studentDialog"     : "",
      "transitionComment" : "",
      "order"             : 0,
      "skippable"         : false
  },
  "prototypes" : {
    "grid" : {
      "prototype" : "grid",
      "items" : [],
      "timer" : 0,
      "autostop" : 0,
      "columns" : 0
    },
    "survey" : {
      "prototype" : "survey",
      "gridLinkId": ""
    },
    "observation" : {
      "prototype"      : "observation",
      "totalSeconds"   : 0,
      "intervalLength" : 0,
      "variableName"   : "",
      "displayName"    : ""
    },
    "location": {
      "prototype" : "location",
      "locations" : []
    },
    "consent" : {
      "prototype" : "consent",
      "prompt" : ""
    },
    "id" : {
      "prototype" : "id"
    },
    "datetime": {
      "prototype" : "datetime"
    },
    "gps": {
      "prototype" : "gps"
    }
  },

  "subtestTemplates" : {
    "gps":
    {
      "GPS Coordinates": {}
    },
    "consent" : {
      "Consent Screen": {}
    },
    "id" : {
      "Student ID": {}
    },
    "location" : {
      "School Location": {}
    },
    "datetime" : {
      "Date and Time": {}
    },
    "grid": {
      "Empty Grid": {},
      "Letter Name Knowledge" : {
        "items": ["A", "b", "C", "d", "E"],
        "timer" : 60
      },
      "Letter Sound Knowledge" : {
        "items": ["A", "b", "C", "d", "E"],
        "timer" : 60
      },
      "Familiar word identification" : {
        "items": ["metamorphosis", "erudite", "precocious"],
        "timer" : 60
      },
      "Non-word decoding" : {
        "items": ["bub", "uf", "mig"],
        "timer" : 60
      },
      "Oral passage reading" : {
        "items":["Modou", "wakes", "up", "very", "early."],
        "timer" : 60
      },
      "Addition Level 1" : {
        "items" : ["1+3=(4)","2+3=(5)","6+2=(8)","4+5=(9)","3+3=(6)"],
        "timer" : 60
      },
      "Number Identification" : {
        "items" : ["2","9","0","12","30"],
        "timer" : 60
      },
      "Subtraction Level 1" : {
        "items" : ["4-3=(1)","5-3=(2)","8-2=(6)","9-5=(4)","6-3=(3)"],
        "timer" : 60
      },
      "Timed Syllable Identification" : {
        "items" : ["ma", "en", "ta", "ki", "bo"],
        "timer" : 60
      }
    },
    "observation" : {
      "Classroom Observation" : {}
    },
    "survey" : {
      "Phoneme Segmentation":{},
      "Listening Comprehension":{},
      "Word Problems":{},
      "Initial Sounds":{},
      "Number Discrimination":{},
      "Missing Number":{},
      "Addition Level 2":{},
      "Untimed Reading Comprehension":{},
      "Timed Reading Comprehension":{},
      "Rational Counting":{},
      "Student Information":{},
      "Pupil Context Interview":{},
      "Dictation":{}
    }
  },
  "questionTemplate" : {
    "order" : 0,
    "prompt" : "",
    "hint" : "",
    "name" :"",
    "type" : "single",
    "options" : [],
    "linkedGridScore" : 0
  },
  "optionTemplates" : [
    {
      "name" : "True/False",
      "options" : [
        {"label":"True","value":"1"},
        {"label":"False","value":"0"}
      ]
    },
    {
      "name" : "Yes/No ",
      "options" : [
        {"label":"Yes","value":"1"},
        {"label":"No","value":"0"}
      ]
    },
    {
      "name" : "Correct/Incorrect",
      "options" : [
        {"label":"Correct","value":"1"},
        {"label":"Incorrect","value":"0"}
      ]
    },
    {
      "name" : "True/False/No Response",
      "options" : [
        {"label":"True","value":"1"},
        {"label":"False","value":"0"},
        {"label":"No response","value":"3"}
      ]
    },
    {
      "name" : "Yes/No/No Response",
      "options" : [
        {"label":"Yes","value":"1"},
        {"label":"No","value":"0"},
        {"label":"No response","value":"3"}
      ]
    },
    {
      "name" : "Correct/Incorrect/No Response",
      "options" : [
        {"label":"Correct","value":"1"},
        {"label":"Incorrect","value":"0"},
        {"label":"No response","value":"3"}
      ]
    },
    {
      "name" : "Month",
      "variableName" : "month",
      "options" : [
        {"label":"January","value":"1"},
        {"label":"February","value":"2"},
        {"label":"March","value":"3"},
        {"label":"April","value":"4"},
        {"label":"May","value":"5"},
        {"label":"June","value":"6"},
        {"label":"July","value":"7"},
        {"label":"August","value":"8"},
        {"label":"September","value":"9"},
        {"label":"October","value":"10"},
        {"label":"November","value":"11"},
        {"label":"December","value":"12"}
      ]

    }
  ]
}
