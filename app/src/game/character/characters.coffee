
#_require ./jackie
#_require ./goku

class Characters
  @JACKIE = "Jackie"
  @GOKU = "Goku"
  @DEFAULT = "Defualt"

  @TYPES: [
    @DEFAULT
    @JACKIE
    @GOKU
  ]

  @newCharacter: (universe, init_pos, type, click_callback) ->
    Char = null
    switch type
      when @JACKIE then Char = Jackie
      when @GOKU then Char = Goku

    return new Char(universe, init_pos, click_callback)
