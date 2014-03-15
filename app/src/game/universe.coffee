
#_require ../config
#_require ../global
#_require ./debug_draw
#_require ./character/character

class Universe
  planets: []
  characters: []
  _debug_draw: false
  _debug_drawer: null

  constructor: (@game, @graphics, @camera) ->
    gravity = new b2Vec2(0, 20)
    @world = new b2Dynamics.b2World(gravity, doSleep=true)

    @_debug_drawer = new DebugDraw(@camera)
    @_debug_drawer.SetSprite(@graphics)
    # @_debug_drawer.SetDrawScale(settings.PPM)
    @_debug_drawer.SetDrawScale(1)
    @_debug_drawer.SetFillAlpha(0.3)
    @_debug_drawer.SetLineThickness(1.0)
    @_debug_drawer.SetFlags(b2Dynamics.b2DebugDraw.e_shapeBit |
      b2Dynamics.b2DebugDraw.e_jointBit)
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
    @world.Step(settings.BOX2D_TIME_STEP, settings.BOX2D_VI, settings.BOX2D_PI)
    @world.ClearForces()

  draw: () ->
    c.draw() for c in @characters
    if @_debug_draw
      @world.DrawDebugData()

  toggleDebugDraw: () ->
    @_debug_draw = not @_debug_draw

  # Creates a new character
  # options [Object]:
  #   pos: {x, y} - default = {x: 0, y: 0}
  #
  newCharacter: (options) ->
    options = options ? {}
    options.pos = options.pos ? {x: 0, y: 0}
    pos = new b2Vec2(options.pos.x, options.pos.y)
    character = new Character(@, pos)
    @characters.push(character)

  _createTerrain: () ->
    w = 20 / 2
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
