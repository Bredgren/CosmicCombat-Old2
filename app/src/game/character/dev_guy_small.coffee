
#_require ./base_character

class DevGuySmall extends BaseCharacter
  recover_rate: 0.0003
  improve_rate: 0.05

  constructor: (universe, init_pos, click_callback) ->
    super(universe, init_pos, click_callback)
    @stand = PIXI.Sprite.fromFrame("dev_guy_small_stand_1")
    @stand.anchor.x = .5
    @stand.anchor.y = .5
    @_stage.addChild(@stand)

    @stand.setInteractive(true)
    @stand.click = (mousedata) =>
      click_callback(@, mousedata)

    @_w = .3
    @_h = .8
    @_offset = -7
    @_createBody(init_pos)

    # Why is attacks shared unless I initialize it here?
    @attacks = []
    @attacks.push(new EnergyAttack1(@))

  update: () ->
    super()

  draw: () ->
    @_positionSprite(@stand)

  size: () ->
    return {w: @stand.width, h: @stand.height}
