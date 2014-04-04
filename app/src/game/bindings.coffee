
class Bindings
  @US: "US"
  @COLEMAK: "Colemak"

  @LAYOUTS: [
    @US
    @COLEMAK
  ]

  @COLEMAK_MAP: # Colemak -> Us
    68: 71 # D -> G Pushing the G key types D
    69: 75 # E -> K or we see the code for E which is the button labeled K
    70: 69 # F -> E
    71: 84 # G -> T
    73: 76 # I -> L
    74: 89 # J -> Y
    75: 78 # K -> N
    76: 85 # L -> U
    78: 74 # N -> J
    79: 186 # O -> ;
    80: 82 # P -> R
    82: 83 # R -> S
    83: 68 # S -> D
    84: 70 # T -> F
    85: 73 # U -> I
    89: 79 # Y -> O
    186: 80 # ; -> P

  layout: @COLEMAK
  actions: {}

  constructor: () ->

  # actionDown and actionUp should be the function to call when the given key
  # is pushed or released respectively
  bind: (key, actionDown, actionUp) ->
    @actions[key] = [actionDown, actionUp]

  # Triggers the action for the given key
  onKeyDown: (key) ->
    key = @_getUSKey(key)
    # code = if (96 <= key and key <= 105) then key-48 else key
    # console.log(String.fromCharCode(code), key)
    if key not of @actions then return
    @actions[key][0]()

  onKeyUp: (key) ->
    key = @_getUSKey(key)
    if key not of @actions then return
    @actions[key][1]()

  _getUSKey: (key) ->
    switch @layout
      when Bindings.US
        return key
      when Bindings.COLEMAK
        if key not of Bindings.COLEMAK_MAP
          return key
        return Bindings.COLEMAK_MAP[key]
