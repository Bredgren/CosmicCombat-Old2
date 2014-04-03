
class Bindings
  @US: "US"
  @COLEMAK: "Colemak"

  @LAYOUTS: [
    @US
    @COLEMAK
  ]

  @COLEMAK_MAP: # Colemak -> Us
    82: 83 # R -> S  Pushing the S key types R
    83: 68 # S -> D
    70: 69 # E -> F

  layout: @COLEMAK
  actions: {}

  constructor: () ->

  # actionDown and actionUp should be the function to call when the given key
  # is pushed or released respectively
  bind: (key, actionDown, actionUp) ->
    @actions[key] = [actionDown, actionUp]

  # Triggers the action for the given key
  onKeyDown: (key) ->
    key = @_getLayoutKey(key)
    if key not of @actions then return
    @actions[key][0]()

  onKeyUp: (key) ->
    key = @_getLayoutKey(key)
    if key not of @actions then return
    @actions[key][1]()

  _getLayoutKey: (key) ->
    switch @layout
      when Bindings.US
        return key
      when Bindings.COLEMAK
        if key not of Bindings.COLEMAK_MAP
          return key
        return Bindings.COLEMAK_MAP[key]
