
#_require ../../global
#_require ../../config

class Character
  MAX_VEL: 15

  # init_pos [b2Vec2]
  constructor: (@universe, init_pos, type, click_callback) ->
    if type is settings.CHARACTERS.JACKIE
      @stand = PIXI.Sprite.fromFrame("jackie_stand_01")
    else
      @stand = PIXI.Sprite.fromFrame("goku_stand_01")

    stats = settings.CHAR_STATS[type]
    @_w = stats.w
    @_h = stats.h
    @_offset = stats.offset

    @stand.anchor.x = .5
    @stand.anchor.y = .5
    @universe.game.stage.addChildAt(@stand, 0)

    @stand.setInteractive(true)
    @stand.click = (mousedata) =>
      click_callback(@, mousedata)

    bodyDef = new b2Dynamics.b2BodyDef()
    bodyDef.type = b2Dynamics.b2Body.b2_dynamicBody
    @body = @universe.world.CreateBody(bodyDef)

    # TODO: address the bug that requires circle to be made first
    circle = new b2Shapes.b2CircleShape(@_w)
    circle.SetLocalPosition(new b2Vec2(0, @_h))
    @body_circle = @body.CreateFixture2(circle, 0)
    @body_circle.SetRestitution(0)

    box = new b2Shapes.b2PolygonShape()
    box.SetAsBox(@_w, @_h)
    box.m_centroid = new b2Vec2(0, -10)
    @body_box = @body.CreateFixture2(box, 5)
    # box = new b2Shapes.b2CircleShape(@_h)
    # @body_box = @body.CreateFixture2(box, 5)

    @body.SetBullet(true)
    @body.SetFixedRotation(true)
    @body.SetPosition(init_pos)

    @_move_direction = new b2Vec2(0, 0)
    @_directions =
      left: false,
      right:  false,
      up: false,
      down: false
    @_jumping = false

  update: () ->
    vel = @body.GetLinearVelocity()
    pos = @body.GetPosition()

    force = @_move_direction.Copy()
    force.Multiply(500)
    @body.ApplyForce(force, pos)

    if @_jumping and @onGround()
      imp = new b2Vec2(0, -25)
      @body.ApplyImpulse(imp, pos)

    if (Math.abs(vel.x) > @MAX_VEL)
      vel.x = (if vel.x > 0 then 1 else -1) * @MAX_VEL
      @body.SetLinearVelocity(vel)

    @body.SetAwake(true)

  draw: () ->
    pos = @body.GetPosition()
    pos = {x: pos.x, y: (pos.y + @_offset)}
    pos = @universe.game.camera.worldToScreen(pos)
    @stand.position.x = pos.x
    @stand.position.y = pos.y

  position: () ->
    return @body.GetPosition()

  size: () ->
    return {w: @stand.width, h: @stand.height}

  onGround: () ->
    contact = @universe.world.GetContactList()
    while contact
      a = contact.GetFixtureA()
      b = contact.GetFixtureB()
      if contact.IsTouching() and (a == @body_circle or b == @body_circle)
        pos = @body.GetPosition()
        manifold = new b2Collision.b2WorldManifold()
        contact.GetWorldManifold(manifold)
        # Only register contacts with bottom half of circle
        below = true
        for p in manifold.m_points
          below &= (p.y > (pos.y + @_h + .1))
        return below
      contact = contact.GetNext()
    return false

  startJump: () ->
    @_jumping = true

  endJump: () ->
    @_jumping = false

  startMoveRight: () ->
    @_directions.right = true
    @_move_direction.x = 1

  endMoveRight: () ->
    @_directions.right = false
    if @_directions.left
      @_move_direction.x = -1
    else
      @_move_direction.x = 0
      @_stopMoveX()

  startMoveLeft: () ->
    @_directions.left = true
    @_move_direction.x = -1

  endMoveLeft: () ->
    @_directions.left = false
    @_move_direction.x = (if @_directions.right then 1 else 0)
    if @_directions.right
      @_move_direction.x = 1
    else
      @_move_direction.x = 0
      @_stopMoveX()

  _stopMoveX: () ->
    vel = @body.GetLinearVelocity()
    vel.x = 0
    @body.SetLinearVelocity(vel)
