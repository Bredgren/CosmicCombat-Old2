
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
  linear_damping: 10

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

    if not @_blocking
      force = @_move_direction.Copy()
      force.Multiply(500)
      @body.ApplyForce(force, pos)
      # Only apply damping when not being moved
      if force.x is 0 and force.y is 0 and (@_flying or on_ground)
        @body.SetLinearDamping(@linear_damping)
      else
        @body.SetLinearDamping(0)

    jump_cost = @jump_str * @jump_cost_ratio
    if @_jumping and on_ground and @energy.strength() > jump_cost
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
