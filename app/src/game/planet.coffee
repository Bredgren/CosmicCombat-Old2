
class Planet
  gravity: null
  size: 100
  depth: 10
  terrain: []
  characters: []
  # neighbors: []
  _background: null

  # size [Number] the circumference in meters. This size will be rounded down to
  #               be a multiple of the background tile size so that the
  #               background can be seamlessly tiled with edge wrapping.
  constructor: (@universe, @size) ->
    @size = @_getRoundedSize(@size)
    @gravity = new b2Vec2(0, @_getGravity(@size))
    @depth = @size / (2 * Math.PI)
    @world = @universe.world

    @_initTerrain()
    @_initBackground()

  update: () ->

  draw: () ->

  getBounds: () ->
    return {
      x: -@size / 2
      y: -@size * 2
      w: @size
      h: @size * 2 + @depth
    }

  # Adds physics items to the world, ...
  load: () ->
    @_loadTerrain()

  # Removes  physics items from the world, ...
  unload: () ->
    @_unloadTerrain()

  _initTerrain: () ->
    w = @size / 2
    h = @depth / 2
    cx = 0
    cy = h
    @terrain = [[{x: cx - w, y: cy - h}, {x: cx + w, y: cy - h},
                 {x: cx + w, y: cy + h}, {x: cx - w, y: cy + h}]]

  _updateTerrainBody: () ->
    @_unloadTerrain()
    @_loadTerrain()

  _loadTerrain: () ->
    # Add body to match current terrain
    bodyDef = new b2Dynamics.b2BodyDef()
    bodyDef.type = b2Dynamics.b2Body.b2_staticBody
    bodyDef.userData = "Terrain"

    fixDef = new b2Dynamics.b2FixtureDef()
    fixDef.density = 1.0
    fixDef.friction = 0.5
    fixDef.restitution = 0 #0.2
    for poly in @terrain
      fixDef.shape = new b2Shapes.b2PolygonShape()
      shape = []
      for v in poly
        shape.push(new b2Vec2(v.x, v.y))
      fixDef.shape.SetAsArray(shape, shape.length)
      @world.CreateBody(bodyDef).CreateFixture(fixDef)

  _unloadTerrain: () ->
    # Remove current body
    body = @world.GetBodyList()
    while body
      data = body.GetUserData()
      if data and data == "Terrain"
        @world.DestroyBody(body)
      body = body.GetNext()

  _initBackground: () ->
    @_background = new PIXI.RenderTexture()

  # Determines the strength of gravity from the size
  _getGravity: (size) ->
    return size / 5

  # Rounds the given size down to be a multiple of the background tile size
  _getRoundedSize: (size) ->
    return size