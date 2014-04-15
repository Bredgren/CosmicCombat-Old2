
#_require ./dev_guy_small
#_require ./jackie
#_require ./goku

class Characters
  @JACKIE = "Jackie"
  @GOKU = "Goku"
  @DEV_GUY_SMALL = "Dev Guy Small"
  @DEFAULT = "Defualt"

  @TYPES: [
    @DEFAULT
    @DEV_GUY_SMALL
    @JACKIE
    @GOKU
  ]

  @newCharacter: (universe, init_pos, type, click_callback) ->
    Char = null
    switch type
      when @JACKIE then Char = Jackie
      when @GOKU then Char = Goku
      when @DEV_GUY_SMALL, @DEFAULT then Char = DevGuySmall

    return new Char(universe, init_pos, click_callback)
