
#_require ../../global
#_require ../../config
#_require ../energy/energy

class BaseCharacter
  body: null
  energy: null

  _stage: null

  _w: 0
  _h: 0
  _body_box: null
  _body_circle: null

  _move_direction: null
  _directions:
    left: false
    right: false
    up: false
    down: false
  _jumping: false
  _jump_str: 25
  _max_vel: 15

  # init_pos [b2Vec2]
  constructor: (@universe, init_pos, type, click_callback) ->
    @_stage = @universe.game.game_stage
    @_move_direction = new b2Vec2(0, 0)
    @energy = new Energy(1000)

  update: () ->
    vel = @body.GetLinearVelocity()
    pos = @body.GetPosition()

    force = @_move_direction.Copy()
    force.Multiply(500)
    @body.ApplyForce(force, pos)

    if @_jumping and @onGround()
      imp = new b2Vec2(0, -@_jump_str)
      @body.ApplyImpulse(imp, pos)

    if (Math.abs(vel.x) > @_max_vel)
      vel.x = (if vel.x > 0 then 1 else -1) * @_max_vel
      @body.SetLinearVelocity(vel)

    @body.SetAwake(true)

  draw: () ->

  position: () ->
    return @body.GetPosition()

  setPosition: (pos) ->
    @body.SetPosition(pos)

  size: () ->

  onGround: () ->
    contact = @universe.world.GetContactList()
    while contact
      a = contact.GetFixtureA()
      b = contact.GetFixtureB()
      if contact.IsTouching() and (a == @_body_circle or b == @_body_circle)
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

  _positionSprite: (sprite) ->
    # TODO: Look at both possible position and chose the visible one, favoring
    # the one within the actual bounds if both are visible.
    # pos = @body.GetPosition()
    # pos = {x: pos.x, y: (pos.y + @_offset)}

    # world_bounds = @universe.getBounds()
    # copy_pos = {x: pos.x + world_bounds.w, y: pos.y}
    # copy_bounds = {x: world_bounds.x - world_bounds.w / 2, y: world_bounds.y,
    # w: world_bounds.w * 2, h: world_bounds.h}
    # copy_pos = @universe.boundedPoint(copy_pos, copy_bounds)

    # pos = @universe.game.camera.worldToScreen(pos)
    # copy_pos = @universe.game.camera.worldToScreen(copy_pos)

    pos = @universe.getDrawingPosWrapped(@body.GetPosition())
    sprite.position.x = pos.x
    sprite.position.y = pos.y

    # sprite_copy.position.x = copy_pos.x
    # sprite_copy.position.y = copy_pos.y
