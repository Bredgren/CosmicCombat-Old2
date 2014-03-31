#_require ../util

class Planet
  MAX_TERRAIN_HEIGHT: 20

  gravity: null
  size: 100
  depth: 10
  terrain: []
  characters: []
  # neighbors: []
  _background_sprite: null
  _terrain_sprite: null
  _terrain_mask: null

  # size [Number] the circumference in meters. This size will be rounded down to
  #               be a multiple of the background tile size so that the
  #               background can be seamlessly tiled with edge wrapping.
  constructor: (@universe, @size) ->
    @size = @_getRoundedSize(@size)
    @gravity = new b2Vec2(0, @_getGravity(@size))
    @depth = @size / (2 * Math.PI)
    @world = @universe.world

    @_terrain_mask = new PIXI.Graphics()

    @_initTerrain()
    @_initBackground()

  update: () ->

  draw: () ->
    drawPoly = (vertices) =>
      @_terrain_mask.beginFill()
      v0 = vertices[0]
      v0 = @universe.camera.worldToScreen(v0)
      @_terrain_mask.moveTo(v0.x, v0.y)
      for v in vertices[1..]
        v = @universe.camera.worldToScreen(v)
        @_terrain_mask.lineTo(v.x, v.y)
      @_terrain_mask.lineTo(v0.x, v0.y)
      @_terrain_mask.endFill()

    # TODO: only draw visible wrapped ones if necessary
    @_terrain_mask.clear()
    for poly in @terrain
      bounds = @getBounds()
      min_x = bounds.x - bounds.w / 2
      max_x = min_x + bounds.w * 2
      min_y = bounds.y - bounds.h / 2
      max_y = min_y + bounds.h * 2

      alt_x = poly[0].x + bounds.w
      dif = alt_x - poly[0].x
      wrapped_poly1 = []
      for v in poly
        wrapped_poly1.push({x: v.x + dif, y: v.y})

      alt_x = poly[0].x - bounds.w
      dif = poly[0].x - alt_x
      wrapped_poly2 = []
      for v in poly
        wrapped_poly2.push({x: v.x - dif, y: v.y})

      drawPoly(poly)
      drawPoly(wrapped_poly1)
      drawPoly(wrapped_poly2)

    bg_pos = @universe.camera.worldToScreen(new b2Vec2(0, 0))
    @_background_sprite.position.x = bg_pos.x
    @_background_sprite.position.y = bg_pos.y

    trn_pos = @universe.camera.worldToScreen(new b2Vec2(0, @depth))
    @_terrain_sprite.position.x = trn_pos.x
    @_terrain_sprite.position.y = trn_pos.y

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
    @universe.game.bg_stage.addChild(@_background_sprite)
    @universe.game.bg_stage.addChild(@_terrain_sprite)
    @universe.game.bg_stage.addChild(@_terrain_mask)

  # Removes  physics items from the world and sprites from the stage
  unload: () ->
    @_unloadTerrain()
    @universe.game.bg_stage.removeChild(@_background_sprite)
    @universe.game.bg_stage.removeChild(@_terrain_sprite)
    @universe.game.bg_stage.removeChild(@_terrain_mask)

  _initTerrain: () ->
    w = @size / 2
    h = @depth / 2
    cx = 0
    cy = h
    @terrain = [[{x: cx - w, y: cy - h}, {x: cx + w, y: cy - h},
                 {x: cx + w, y: cy + h}, {x: cx - w, y: cy + h}],
                [{x: cx, y: cy - h}, {x: cx + 4, y: cy - 2 - h},
                 {x: cx + 4, y: cy - h}]]

    edge_w = Math.ceil(settings.WIDTH / settings.BG_TILE_SIZE)
    w = (@size * settings.PPM) + (edge_w * settings.BG_TILE_SIZE)
    h = (@depth + @MAX_TERRAIN_HEIGHT) * settings.PPM
    tex = new PIXI.RenderTexture(w, h)
    container = new PIXI.DisplayObjectContainer()
    g = new PIXI.Graphics()
    container.addChild(g)
    g.beginFill(0x682900)
    g.drawRect(0, 0, w, h)
    g.endFill()

    # TODO: make better
    # TODO: take wrapping into acount
    colors = [0xAF4600, 0xAAAAAA, 0x404040, 0x3F0000]
    for _ in [0...10000]
      g.beginFill(colors[Math.floor(Math.random() * colors.length)])
      x = Math.random() * w
      y = Math.random() * h
      width = (Math.random() * 20) + 1
      height = (Math.random() * 20) + 1
      g.drawRect(x, y, width, height)
      g.endFill()

    tex.render(container)

    @_terrain_sprite = new PIXI.Sprite(tex)
    @_terrain_sprite.anchor.x = 0.5
    @_terrain_sprite.anchor.y = 1
    @_terrain_sprite.mask = @_terrain_mask

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
    # tile_map = []
    # # Size in tiles
    # main_w = (@size * settings.PPM) / settings.BG_TILE_SIZE  #
    # edge_w = Math.ceil(settings.WIDTH / settings.BG_TILE_SIZE)
    # if edge_w % 2 isnt 0
    #   edge_w += 1
    # total_w = main_w + edge_w
    # left_edge = edge_w / 2
    # right_edge = left_edge + main_w

    # top_row = []
    # for x in [0...total_w]
    #   top_row.push(1)
    # tile_map.push(top_row)

    # row = []
    # for x in [left_edge...right_edge]
    #   row[x] = [0, 2][Math.round(Math.random() * 1)]
    # for x in [0...left_edge]
    #   row[x] = row[x + main_w]
    # for x in [right_edge...total_w]
    #   row[x] = row[(x - right_edge) + left_edge]
    # tile_map.push(row)

    # w = (@size * settings.PPM) + (edge_w * settings.BG_TILE_SIZE)
    # h = settings.BG_TILE_SIZE * 2
    # tex = new PIXI.RenderTexture(w, h)
    # container = new PIXI.DisplayObjectContainer()

    # for y in [0...2]
    #   for x in [0...total_w]
    #     type = tile_map[y][x]
    #     tile = PIXI.Sprite.fromFrame("bg_type1_#{type}")
    #     tile.position.x = x * settings.BG_TILE_SIZE
    #     tile.position.y = y * settings.BG_TILE_SIZE
    #     container.addChild(tile)

    # tex.render(container)

    # @_background_sprite = new PIXI.Sprite(tex)
    # @_background_sprite.anchor.x = 0.5
    # @_background_sprite.anchor.y = 1
    # # Background is always assumed to be at position (0, 0) in the world

    # TODO: if random background generation works, remove tile size logic
    edge_w = Math.ceil(settings.WIDTH / settings.BG_TILE_SIZE)
    w = (@size * settings.PPM) + (edge_w * settings.BG_TILE_SIZE)
    h = settings.BG_TILE_SIZE * 2
    tex = new PIXI.RenderTexture(w, h)
    container = new PIXI.DisplayObjectContainer()
    g = new PIXI.Graphics()
    container.addChild(g)
    g.beginFill(0x0094FF)
    g.drawRect(0, 0, w, h)
    g.endFill()

    # TODO: take wrapping into acount
    for _ in [0...20]
      x = Math.random() * w
      y = h
      width = (Math.random() * 20) + 10
      height = width * (10 + (Math.random() * 10) - 5)
      g.beginFill(0x7F3300)
      g.drawRect(x - (width / 2), y - height, width, height) #
      g.endFill()

      s = (height / 2) + ((Math.random() * 10) - 5) #
      x -= s / 2
      y -= height
      g.beginFill(0x007F0E)
      g.drawRect(x, y, s, s)  #
      g.endFill()

      c = [0x005408, 0x00BC0F]
      for _ in [0...(Math.floor(Math.random() * 8) + 2)]
        s2 = (s / 5) + ((Math.random() * 4) - 2)  #
        area_size = s * 1.1
        x2 = (Math.random() * area_size) - (s * .1)
        y2 = (Math.random() * area_size) - (s * .1)
        g.beginFill(c[Math.floor(Math.random() * 2)])
        g.drawRect(x + x2, y + y2, s2, s2)
        g.endFill()

    tex.render(container)

    @_background_sprite = new PIXI.Sprite(tex)
    @_background_sprite.anchor.x = 0.5
    @_background_sprite.anchor.y = 1

  # Determines the strength of gravity from the size
  _getGravity: (size) ->
    return size / 5

  # Rounds the given size up to be a multiple of the background tile size
  _getRoundedSize: (size) ->
    w = size * settings.PPM
    new_w = Math.ceil(w / settings.BG_TILE_SIZE) * settings.BG_TILE_SIZE
    return new_w / settings.PPM
