
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

  layout: @US
  actions: {}

  constructor: () ->

  # actionDown and actionUp should be the function to call when the given key
  # is pushed or released respectively
  # Returns an object which can be used to rebind the key
  bind: (key, actionDown, actionUp) ->
    us_key = @_getUSKey(key)
    @actions[us_key] = [actionDown, actionUp]
    return {layout: @layout, key: key}

  # old_key needs to be an object of the type returned by bind
  rebind: (old_key, new_key) ->
    old_key = @_getUSKey(old_key.key, old_key.layout)
    if old_key not of @actions then return
    new_us_key = @_getUSKey(new_key)
    @actions[new_us_key] = @actions[old_key]
    delete @actions[old_key]
    return {layout: @layout, key: new_key}

  # Triggers the action for the given key
  onKeyDown: (key) ->
    us_key = @_getUSKey(key)
    # @_printKey(key, us_key)
    if us_key not of @actions then return
    @actions[us_key][0]()

  onKeyUp: (key) ->
    key = @_getUSKey(key)
    if key not of @actions then return
    @actions[key][1]()

  _getUSKey: (key, layout) ->
    if not layout
      layout = @layout

    switch layout
      when Bindings.US
        return key
      when Bindings.COLEMAK
        if key not of Bindings.COLEMAK_MAP
          return key
        return Bindings.COLEMAK_MAP[key]

  _printKey: (key, us_key) ->
    code_a = if (96 <= key and key <= 105) then key-48 else key
    code_b = if (96 <= us_key and us_key <= 105) then us_key-48 else us_key
    s_a = String.fromCharCode(code_a)
    s_b = String.fromCharCode(code_b)
    console.log("#{s_a}(#{key}) -> #{s_b}(#{us_key})")
