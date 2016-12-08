exports.context = {
  init: function(settings) {
    var state = empty();
    if (settings.env === 'dev') {
      state = sample();
    }
    return state
  },
  ports: ports
}

function ports(settings, app, state) {
}

function todoItem(title) {
  return { title: title
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