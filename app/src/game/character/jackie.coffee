
#_require ./base_character

class Jackie extends BaseCharacter
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

    bodyDef = new b2Dynamics.b2BodyDef()
    bodyDef.type = b2Dynamics.b2Body.b2_dynamicBody
    @body = @universe.world.CreateBody(bodyDef)

    box = new b2Shapes.b2PolygonShape()
    box.SetAsBox(@_w, @_h)
    @_body_box = @body.CreateFixture2(box, 5)

    circle = new b2Shapes.b2CircleShape(@_w)
    circle.SetLocalPosition(new b2Vec2(0, @_h))
    @_body_circle = @body.CreateFixture2(circle, 0)
    @_body_circle.SetRestitution(0)

    @body.SetBullet(true)
    @body.SetFixedRotation(true)
    @body.SetPosition(init_pos)

  update: () ->
    super()

  draw: () ->
    @_positionSprite(@stand)

  size: () ->
    return {w: @stand.width, h: @stand.height}
