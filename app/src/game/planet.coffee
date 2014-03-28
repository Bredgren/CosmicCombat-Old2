
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
    bg_pos = @universe.camera.worldToScreen(new b2Vec2(0, 0))
    @_background.position.x = bg_pos.x
    @_background.position.y = bg_pos.y

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
    @universe.game.bg_stage.removeChild(@_background)

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
    tile_map = []
    # Size in tiles
    main_w = (@size * settings.PPM) / settings.BG_TILE_SIZE  #
    edge_w = Math.ceil(settings.WIDTH / settings.BG_TILE_SIZE)
    if edge_w % 2 isnt 0
      edge_w += 1
    total_w = main_w + edge_w
    left_edge = edge_w / 2
    right_edge = left_edge + main_w

    top_row = []
    for x in [0...total_w]
      top_row.push(1)
    tile_map.push(top_row)

    row = []
    for x in [left_edge...right_edge]
      row[x] = [0, 2][Math.round(Math.random() * 1)]
    for x in [0...left_edge]
      row[x] = row[x + main_w]
    for x in [right_edge...total_w]
      row[x] = row[(x - right_edge) + left_edge]
    tile_map.push(row)

    w = (@size * settings.PPM) + (edge_w * settings.BG_TILE_SIZE)
    h = settings.BG_TILE_SIZE * 2
    tex = new PIXI.RenderTexture(w, h)
    container = new PIXI.DisplayObjectContainer()

    for y in [0...2]
      for x in [0...total_w]
        type = tile_map[y][x]
        tile = PIXI.Sprite.fromFrame("bg_type1_#{type}")
        tile.position.x = x * settings.BG_TILE_SIZE
        tile.position.y = y * settings.BG_TILE_SIZE
        container.addChild(tile)

    # Room for adding half a screen on both sides
    # edge_width =
    #   Math.ceil(settings.WIDTH / settings.BG_TILE_SIZE) * settings.BG_TILE_SIZE
    # w = (@size * settings.PPM) + edge_width
    # h = settings.BG_TILE_SIZE * 2
    # tex = new PIXI.RenderTexture(w, h)
    # container = new PIXI.DisplayObjectContainer()

    # for x in [0...w/2] by settings.BG_TILE_SIZE
    #   for y in [0...h] by settings.BG_TILE_SIZE
    #     if y is 0
    #       type = 1
    #     else
    #       type = [0, 2][Math.round(Math.random() * 1)]
    #     tile1 = PIXI.Sprite.fromFrame("bg_type1_#{type}")
    #     tile1.position.x = x
    #     tile1.position.y = y

    #     tile2 = PIXI.Sprite.fromFrame("bg_type1_#{type}")
    #     tile2.position.x = x + w / 2
    #     tile2.position.y = y

    #     container.addChild(tile1)
    #     container.addChild(tile2)

    tex.render(container)

    @_background = new PIXI.Sprite(tex)
    @_background.anchor.x = 0.5
    @_background.anchor.y = 1
    # Background is always assumed to be at position (0, 0) in the world

    @universe.game.bg_stage.addChild(@_background)

  # Determines the strength of gravity from the size
  _getGravity: (size) ->
    return size / 5

  # Rounds the given size up to be a multiple of the background tile size
  _getRoundedSize: (size) ->
    w = size * settings.PPM
    new_w = Math.ceil(w / settings.BG_TILE_SIZE) * settings.BG_TILE_SIZE
    return new_w / settings.PPM
