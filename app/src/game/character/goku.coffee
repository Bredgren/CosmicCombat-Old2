
#_require ./base_character

class Goku extends BaseCharacter
  recover_rate: 0.0002
  improve_rate: 0.2
  constructor: (universe, init_pos, click_callback) ->
    super(universe, init_pos, click_callback)
    @_jump_str = 15

    @stand = PIXI.Sprite.fromFrame("goku_stand_01")
    @stand.anchor.x = .5
    @stand.anchor.y = .5
    @_stage.addChild(@stand)

    @stand.setInteractive(true)
    @stand.click = (mousedata) =>
      click_callback(@, mousedata)

    @_w = .3
    @_h = .4
    @_offset = 0
    @_createBody(init_pos)

  update: () ->
    super()

  draw: () ->
    @_positionSprite(@stand)

  size: () ->
    return {w: @stand.width, h: @stand.height}
