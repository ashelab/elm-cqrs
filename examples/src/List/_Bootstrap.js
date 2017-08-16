exports.context = {
  init: function(settings) {
    var state = empty();
    if (settings.env === 'dev') {
      state = sample();
    }
    return state
  },
  ports: function(settings, app, state) {
  }
}

function empty() {
  return { data:
    []
  }
}

function sample() {
  return { data:
    [ todoItem("Do Something")
    ]
  }
}