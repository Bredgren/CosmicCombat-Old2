
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

    # @stand_copy = PIXI.Sprite.fromFrame("jackie_stand_01")
    # @stand_copy.anchor.x = .5
    # @stand_copy.anchor.y = .5
    # @_stage.addChild(@stand_copy)

    # @stand_copy.setInteractive(true)
    # @stand_copy.click = (mousedata) =>
    #   click_callback(@, mousedata)

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
    # pos = @body.GetPosition()
    # pos = {x: pos.x, y: (pos.y + @_offset)}
    # world_bounds = @universe.getBounds()
    # copy_pos = {x: pos.x + world_bounds.w, y: pos.y}
    # copy_bounds = {x: world_bounds.x - world_bounds.w / 2, y: world_bounds.y,
    # w: world_bounds.w * 2, h: world_bounds.h}
    # copy_pos = @universe.boundedPoint(copy_pos, copy_bounds)
    # pos = @universe.game.camera.worldToScreen(pos)
    # @stand.position.x = pos.x
    # @stand.position.y = pos.y
    # copy_pos = @universe.game.camera.worldToScreen(copy_pos)
    # @stand_copy.position.x = copy_pos.x
    # @stand_copy.position.y = copy_pos.y

  size: () ->
    return {w: @stand.width, h: @stand.height}
