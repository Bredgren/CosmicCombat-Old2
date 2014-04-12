
#_require ../config
#_require ../global
#_require ../util
#_require ./character/characters
#_require ./debug_draw
#_require ./planet

class Universe
  planets: []
  current_planet: null
  characters: []
  debug_draw_enabled: false
  _debug_drawer: null

  db_draw_flags:
    aabb: b2DebugDraw.e_aabbBit
    center: b2DebugDraw.e_centerOfMassBit
    control: b2DebugDraw.e_controllerBit
    joint: b2DebugDraw.e_jointBit
    pair: b2DebugDraw.e_pairBit
    shape: b2DebugDraw.e_shapeBit

  constructor: (@game, @graphics, @camera) ->
    gravity = new b2Vec2(0, 20)
    @world = new b2Dynamics.b2World(gravity, doSleep=true)
    @current_planet = new Planet(@, 100)
    @current_planet.load()

    @_debug_drawer = new DebugDraw(@camera)
    @_debug_drawer.SetSprite(@graphics)
    # @_debug_drawer.SetDrawScale(settings.PPM)
    @_debug_drawer.SetDrawScale(1)
    @_debug_drawer.SetAlpha(1)
    @_debug_drawer.SetFillAlpha(1)
    @_debug_drawer.SetLineThickness(1.0)
    @_debug_drawer.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit |
      b2DebugDraw.e_centerOfMassBit | b2DebugDraw.e_controllerBit |
      b2DebugDraw.e_pairBit | b2DebugDraw.e_aabbBit)
    @world.SetDebugDraw(@_debug_drawer)

    bodyDef = new b2Dynamics.b2BodyDef()
    bodyDef.type = b2Dynamics.b2Body.b2_dynamicBody
    bodyDef.position.x = 0
    bodyDef.position.y = -10

    fixDef = new b2Dynamics.b2FixtureDef()
    fixDef.density = 1.0
    fixDef.friction = 0.5
    fixDef.restitution = 0.2
    fixDef.shape = new b2Shapes.b2CircleShape(1)

    @world.CreateBody(bodyDef).CreateFixture(fixDef)

    bodyDef.position.x = 10
    bodyDef.position.y = -10

    fixDef.density = 2.0
    fixDef.friction = 0.7
    fixDef.restitution = 0.2
    fixDef.shape = new b2Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(2, 2)

    @world.CreateBody(bodyDef).CreateFixture(fixDef)

  update: () ->
    @current_planet.update()
    c.update() for c in @characters
    @_wrapObjects()
    @world.Step(settings.BOX2D_TIME_STEP, settings.BOX2D_VI, settings.BOX2D_PI)
    @world.ClearForces()

  _wrapObjects: () ->
    body = @world.GetBodyList()
    while body
      new_pos = @boundedPoint(body.GetPosition())
      body.SetPosition(new b2Vec2(new_pos.x, new_pos.y))
      body = body.GetNext()
    new_camera_pos = @boundedPoint(@camera)
    @camera.x = new_camera_pos.x
    @camera.y = new_camera_pos.y

  draw: () ->
    @current_planet.draw()
    c.draw() for c in @characters
    if @debug_draw_enabled
      @world.DrawDebugData()

  # Takes a point in world space where you would like to draw something and
  # returns the point on screen that it should be drawn at. This takes into
  # account the wrapping by returning the position that is within the screen.
  # If no position is in the screen or more than one is then it returns the
  # position that is closest to the camera, which prevents disappearing and
  # reappearing at the edges.
  # Optionally you may provide a custom set of bounds.
  getDrawingPosWrapped: (pos, bounds) ->
    screen_pos = @camera.worldToScreen(pos)
    if @camera.onScreen(screen_pos)
      return screen_pos

    if not bounds
      bounds = @getBounds()

    min_x = bounds.x - bounds.w / 2
    max_x = min_x + bounds.w * 2

    alt_x = boundedValue(pos.x + bounds.w, min_x, max_x)

    # Check all cases
    alt_pos = [{x: alt_x, y: pos.y}, pos]
    screen_alt_pos = null
    min_dist = null
    for pos in alt_pos
      p = @camera.worldToScreen(pos)
      dist = Math.abs(p.x - @camera.w / 2) +  Math.abs(p.y - @camera.h / 2)
      if min_dist is null or dist < min_dist
        screen_alt_pos = p
        min_dist = dist

    return screen_alt_pos

  getBounds: () ->
    return @current_planet.getBounds()

  # Takes a point [{x, y}] and returns a new point whose values are wrapped
  # Astroids-style within the space specified by the given bounds or getBounds()
  boundedPoint: (point, bounds) ->
    if not bounds
      bounds = @getBounds()

    x = boundedValue(point.x, bounds.x, bounds.x + bounds.w)

    return {x: x, y: point.y}

  addDebugDrawFlag: (flag) ->
    flags = @_debug_drawer.GetFlags()
    flags = flags | flag
    @_debug_drawer.SetFlags(flags)

  removeDebugDrawFlag: (flag) ->
    flags = @_debug_drawer.GetFlags()
    flags = flags - flag
    @_debug_drawer.SetFlags(flags)

  # Creates a new Character
  # options [Object]:
  #   pos: {x, y} - default = {x: 0, y: 0}
  #   type: String - ...
  #   onclick = (Character, mousedata) ->
  # returns the new Character
  newCharacter: (options) ->
    options = options ? {}
    options.pos = options.pos ? {x: 0, y: 0}
    type = options.type ? "Goku"
    callback = options.onclick ? () ->
    pos = new b2Vec2(options.pos.x, options.pos.y)
    character = Characters.newCharacter(@, pos, type, callback)
    @characters.push(character)
    return character

  removeTerrain: (x, y, size, prec) ->
    @current_planet.removeTerrain(x, y, size, prec)
