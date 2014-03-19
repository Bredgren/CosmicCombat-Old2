
#_require ../../global
#_require ../../config
#_require ../energy/energy

class BaseCharacter
  body: null
  energy: null
  recover_rate: 0.0005  # percent of max
  improve_rate: 0.1  # percent of amount recovered
  power_up_rate: 0.01

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
  _jump_cost_ratio: 0.1
  _max_vel: 15
  _power_up: 0

  # init_pos [b2Vec2]
  constructor: (@universe, init_pos, type, click_callback) ->
    @_stage = @universe.game.game_stage
    @_move_direction = new b2Vec2(0, 0)
    @energy = new Energy(100)

  update: () ->
    vel = @body.GetLinearVelocity()
    pos = @body.GetPosition()

    force = @_move_direction.Copy()
    force.Multiply(500)
    @body.ApplyForce(force, pos)

    if @_jumping and @onGround()
      imp = new b2Vec2(0, -@_jump_str)
      @body.ApplyImpulse(imp, pos)
      @energy.decCurrent(@_jump_str * @_jump_cost_ratio)

    if (Math.abs(vel.x) > @_max_vel)
      vel.x = (if vel.x > 0 then 1 else -1) * @_max_vel
      @body.SetLinearVelocity(vel)

    @body.SetAwake(true)

    @_recover()
    @energy.incStrength(@_power_up * @energy.max())

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

  startPowerUp: () ->
    @_power_up = @power_up_rate

  endPowerUp: () ->
    @_power_up = 0

  startPowerDown: () ->
    @_power_up = -@power_up_rate

  endPowerDown: () ->
    @_power_up = 0

  _stopMoveX: () ->
    vel = @body.GetLinearVelocity()
    vel.x = 0
    @body.SetLinearVelocity(vel)

  _positionSprite: (sprite) ->
    pos = @universe.getDrawingPosWrapped(@body.GetPosition())
    sprite.position.x = pos.x
    sprite.position.y = pos.y

    if @_move_direction.x > 0
      sprite.scale.x = 1
    else if @_move_direction.x < 0
      sprite.scale.x = -1

  _recover: () ->
    max = @energy.max()

    recover_amount = @recover_rate * max
    recovered_amount = @energy.incCurrent(recover_amount)

    improve_amount = @improve_rate * recovered_amount
    @energy.incMax(improve_amount)
