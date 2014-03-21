
#_require ../config
#_require ../global
#_require ../util
#_require ./debug_draw
#_require ./character/characters

class Universe
  planets: []
  characters: []
  debug_draw_enabled: false
  _debug_drawer: null

  __terrain_width: 100

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

    atm_tex = PIXI.Texture.fromImage("assets/img/atmosphere.png")
    @_atm = new PIXI.TilingSprite(atm_tex, settings.WIDTH, 3000)
    @_atm.position.x = 0
    @_atm.position.y = 0
    @game.bg_stage.addChild(@_atm)

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

    @_terrain = []
    @_createTerrain()
    @_updateTerrainBody()

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

  update: () ->
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

  draw: () ->
    @_atm.position.y = -@camera.worldToScreenUnits(@camera).y - 2500
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
    min_y = bounds.y - bounds.h / 2
    max_y = min_y + bounds.h * 2

    alt_x = boundedValue(pos.x + bounds.w, min_x, max_x)
    alt_y = boundedValue(pos.y + bounds.h, min_y, max_y)

    # Check all cases
    alt_pos = [{x: alt_x, y: pos.y}, {x: pos.x, y: alt_y}, {x: alt_x, y: alt_y},
      pos]
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
    return {
      x: -@__terrain_width / 2
      y: -@__terrain_width
      w: @__terrain_width
      h: @__terrain_width + 10
    }

  # Takes a point [{x, y}] and returns a new point whose values are wrapped
  # Astroids-style within the space specified by the given bounds or getBounds()
  boundedPoint: (point, bounds) ->
    if not bounds
      bounds = @getBounds()

    x = boundedValue(point.x, bounds.x, bounds.x + bounds.w)
    y = boundedValue(point.y, bounds.y, bounds.y + bounds.h)

    return {x: x, y: y}

  # toggleDebugDraw: () ->
  #   @_debug_draw = not @_debug_draw

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
  #
  # click_callback = (Character, mousedata) ->
  # returns the new Character
  newCharacter: (options, click_callback) ->
    options = options ? {}
    options.pos = options.pos ? {x: 0, y: 0}
    type = options.type ? "Goku"
    pos = new b2Vec2(options.pos.x, options.pos.y)
    # character = new Character(@, pos, type, click_callback)
    character = Characters.newCharacter(@, pos, type, click_callback)
    @characters.push(character)
    return character

  _createTerrain: () ->
    w = @__terrain_width / 2
    h = 10 / 2
    cx = 0
    cy = h
    @_terrain = [[{x: cx - w, y: cy - h}, {x: cx + w, y: cy - h},
                  {x: cx + w, y: cy + h}, {x: cx - w, y: cy + h}]]

  _updateTerrainBody: () ->
    # Remove current body
    body = @world.GetBodyList()
    while body
      data = body.GetUserData()
      if data and data == "Terrain"
        @world.DestroyBody(body)
      body = body.GetNext()

    # Add body to match current _terrain
    bodyDef = new b2Dynamics.b2BodyDef()
    bodyDef.type = b2Dynamics.b2Body.b2_staticBody
    bodyDef.userData = "Terrain"

    fixDef = new b2Dynamics.b2FixtureDef()
    fixDef.density = 1.0
    fixDef.friction = 0.5
    fixDef.restitution = 0 #0.2
    for poly in @_terrain
      fixDef.shape = new b2Shapes.b2PolygonShape()
      shape = []
      for v in poly
        shape.push(new b2Vec2(v.x, v.y))
      fixDef.shape.SetAsArray(shape, shape.length)
      @world.CreateBody(bodyDef).CreateFixture(fixDef)
