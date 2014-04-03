
class Bindings
  @US: "US"
  @COLEMAK: "Colemak"

  @LAYOUTS: [
    @US
    @COLEMAK
  ]

  layout: @COLEMAK
  actions: {}

  constructor: () ->

  # actionDown and actionUp should be the function to call when the given key
  # is pushed or released respectively
  bind: (key, actionDown, actionUp) ->
    @actions[key] = [actionDown, actionUp]

  # Triggers the action for the given key
  onKeyDown: (key) ->
    if key not of @actions then return
    @actions[key][0]()

  onKeyUp: (key) ->
    if key not of @actions then return
    @actions[key][1]()