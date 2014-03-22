
#_require ./base_character

class Jackie extends BaseCharacter
  recover_rate: 0.0003
  improve_rate: 0.05
  constructor: (universe, init_pos, click_callback) ->
    super(universe, init_pos, click_callback)
    @stand = PIXI.Sprite.fromFrame("jackie_stand_01")
    @stand.anchor.x = .5
    @stand.anchor.y = .5
    @_stage.addChild(@stand)

    @stand.setInteractive(true)
    @stand.click = (mousedata) =>
      click_callback(@, mousedata)

    @_w = .4
    @_h = .5
    @_offset = .1
    @_createBody(init_pos)

  update: () ->
    super()

  draw: () ->
    @_positionSprite(@stand)

  size: () ->
    return {w: @stand.width, h: @stand.height}
