
#_require ../../global
#_require ../../config
#_require ../energy/energy

class BaseCharacter
  body: null
  energy: null

  # stats
  recover_rate: 0.0002  # percent of max
  improve_rate: 0.1  # percent of amount recovered
  power_up_rate: 0.001
  power_down_rate: 0.004
  fly_cost: 10
  jump_str: 25
  jump_cost_ratio: 0.1 # energy per unit of jump_str
  max_vel: 15
  fly_move_damp: 1
  fly_not_move_damp: 10
  ground_move_damp: 1
  ground_not_move_damp: 10
  not_ground_move_damp: 1
  not_ground_not_move_damp: 2

  _stage: null

  _w: 0
  _h: 0
  _body_box: null
  _body_circle: null

  # state
  _move_direction: null
  _directions:
    left: false
    right: false
    up: false
    down: false
  _flying: false
  _jumping: false
  _blocking: false
  _power_up: 0

  # init_pos [b2Vec2]
  constructor: (@universe, init_pos, type, click_callback) ->
    @_stage = @universe.game.game_stage
    @_move_direction = new b2Vec2(0, 0)
    @energy = new Energy(100)

  update: () ->
    energy_spent = 0
    vel = @body.GetLinearVelocity()
    pos = @body.GetPosition()
    on_ground = @onGround()
    moving = true  # deliberate moving

    if not @_blocking
      force = @_move_direction.Copy()
      force.Multiply(500)
      @body.ApplyForce(force, pos)
      if force.x is 0 and force.y is 0
        moving = false

    jump_cost = @jump_str * @jump_cost_ratio
    if @_jumping and on_ground and @energy.strength() > jump_cost
      moving = true
      imp = new b2Vec2(0, -@jump_str)
      @body.ApplyImpulse(imp, pos)
      energy_spent += jump_cost

    if (Math.abs(vel.x) > @max_vel)
      vel.x = (if vel.x > 0 then 1 else -1) * @max_vel
      @body.SetLinearVelocity(vel)

    if (Math.abs(vel.y) > @max_vel)
      vel.y = (if vel.y > 0 then 1 else -1) * @max_vel
      @body.SetLinearVelocity(vel)

    @body.SetAwake(true)

    if @_flying
      if @energy.strength() > @fly_cost
        anti_g = @universe.world.GetGravity().Copy()
        anti_g.Multiply(-@body.GetMass())
        @body.ApplyForce(anti_g, pos)
        energy_spent += @fly_cost
      else
        @endFly()

    if on_ground
      if moving
        @body.SetLinearDamping(@ground_move_damp)
      else
        @body.SetLinearDamping(@ground_not_move_damp)
    else if @_flying
      if moving
        @body.SetLinearDamping(@fly_move_damp)
      else
        @body.SetLinearDamping(@fly_not_move_damp)
    else
      if moving
        @body.SetLinearDamping(@not_ground_move_damp)
      else
        @body.SetLinearDamping(@not_ground_not_move_damp)

    @_updateEnergy(energy_spent)

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

  startUp: () ->
    @_jumping = true
    if @_flying
      @_directions.up = true
      @_move_direction.y = -1

  endUp: () ->
    @_jumping = false
    if @_flying
      @_directions.up = false
      if @_directions.down
        @_move_direction.y = 1
      else
        @_move_direction.y = 0
        # @_stopMoveY()

  startDown: () ->
    if @_flying
      @_directions.down = true
      @_move_direction.y = 1

  endDown: () ->
    if @_flying
      @_directions.down = false
      if @_directions.up
        @_move_direction.y = -1
      else
        @_move_direction.y = 0
        # @_stopMoveY()

  startFly: () ->
    if @energy.strength() >= @fly_cost
      if @_blocking
        @_stopMoveX()
        @_stopMoveY()
      @_flying = true

  endFly: () ->
    @endUp()
    @endDown()
    @_flying = false

  startRight: () ->
    @_directions.right = true
    @_move_direction.x = 1

  endRight: () ->
    @_directions.right = false
    if @_directions.left
      @_move_direction.x = -1
    else
      @_move_direction.x = 0
      # @_stopMoveX()

  startLeft: () ->
    @_directions.left = true
    @_move_direction.x = -1

  endLeft: () ->
    @_directions.left = false
    @_move_direction.x = (if @_directions.right then 1 else 0)
    if @_directions.right
      @_move_direction.x = 1
    else
      @_move_direction.x = 0
      # @_stopMoveX()

  startPowerUp: () ->
    @_power_up = @power_up_rate

  endPowerUp: () ->
    @_power_up = 0

  startPowerDown: () ->
    @_power_up = -@power_down_rate

  endPowerDown: () ->
    @_power_up = 0

  startBlock: () ->
    @_blocking = true
    @_stopMoveX()
    @_stopMoveY()

  endBlock: () ->
    @_blocking = false

  endAll: () ->
    @endUp()
    @endDown()
    @endLeft()
    @endRight()
    @endPowerUp()
    @endPowerDown()
    @endBlock()

  _stopMoveX: () ->
    vel = @body.GetLinearVelocity()
    vel.x = 0
    @body.SetLinearVelocity(vel)

  _stopMoveY: () ->
    vel = @body.GetLinearVelocity()
    vel.y = 0
    @body.SetLinearVelocity(vel)

  _positionSprite: (sprite) ->
    pos = @universe.getDrawingPosWrapped(@body.GetPosition())
    sprite.position.x = pos.x
    sprite.position.y = pos.y

    if @_move_direction.x > 0
      sprite.scale.x = 1
    else if @_move_direction.x < 0
      sprite.scale.x = -1

  # Recovers energy and increases the maximum if the amount spent is less
  # than the amount you would recover.
  _updateEnergy: (spent) ->
    max = @energy.max()

    recover_amount = @recover_rate * max - spent
    recovered_amount = @energy.incCurrent(recover_amount)

    if recovered_amount > 0
      improve_amount = @improve_rate * recovered_amount
      @energy.incMax(improve_amount)

    @energy.incStrength(@_power_up * @energy.max())

  _createBody: (pos) ->
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
    if pos
      @body.SetPosition(pos)
