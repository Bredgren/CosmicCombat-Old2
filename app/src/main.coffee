# The main script for the game

#_require ./config
#_require ./game/game

# Execute after document is loaded
$ ->
  DOM_LOADED = true
  assets = ["assets/img/jackie_chun.json"]
  loader = new PIXI.AssetLoader(assets)
  loader.onComplete = main
  loader.load()
  # main()

W = 0
H = 0
stance = null
# The main method for the game
main = ->
  W = if settings.FULL_SCREEN then window.innerWidth else settings.WIDTH
  H = if settings.FULL_SCREEN then window.innerHeight else settings.HEIGHT

  body = $('body')

  container = $('<div>')
  container.css('margin-right', 'auto')
  container.css('margin-left', 'auto')
  container.css('width', "#{W}px")
  body.append(container)

  black = 0x000000
  stage = new PIXI.Stage(black)
  renderer = PIXI.autoDetectRenderer(W, H)

  container.append(renderer.view)

  canvas = $('canvas')[0]

  graphics = new PIXI.Graphics()
  stage.addChild(graphics)

  game = new Game(stage, graphics)

  # jackie_tx = PIXI.Texture.fromImage("assets/img/jackie.png")
  # jackie = new PIXI.Sprite(jackie_tx)
  # jackie.rotation = .56
  # jackie.position.x = W / 2 - 16
  # jackie.position.y = H / 4 - 38
  # stage.addChild(jackie)

  # basic_updater = (p, field_acl) ->
  #   p.vel.x += field_acl.x + p.acl.x
  #   p.vel.y += field_acl.y + p.acl.y
  #   p.pos.x += p.vel.x
  #   p.pos.y += p.vel.y

  # circle_drawer = (p) ->
  #   graphics.alpha = .5
  #   graphics.lineStyle(3, 0x00FFFF)
  #   # r = 7 * Math.random()
  #   # t = 50 - p.life
  #   # if t < 4
  #   #   r = 20 - t * 2
  #   # else if t > 40
  #   #   t = t - 40
  #   #   r = 5 - t * .5
  #   # y = p.pos.y + Math.sin(p.life+Math.random()*5) * 5
  #   # graphics.drawCircle(p.pos.x, y, r)
  #   graphics.drawCircle(p.pos.x, p.pos.y, 7 * Math.random())
  #   # graphics.drawCircle(p.pos.x, p.pos.y, r)

  # basic_emitter =
  #   pos:
  #     x: W / 2
  #     y: H / 4
  #   rate: 5
  #   active: true
  #   particle_fn: () ->
  #     m = 6
  #     a = 3.8
  #     ax = Math.cos(a)
  #     ay = Math.sin(a)
  #     vx = -m * ax
  #     vy = -m * ay
  #     p =
  #       pos:
  #         x: W / 2
  #         y: H / 4 + Math.random() * 10 - 5
  #       vel:
  #         x: vx
  #         y: vy
  #       acl:
  #         x: 0 #ax / 20
  #         y: 0 #ay / 20
  #       life: 50

  # attract_field =
  #   pos:
  #     x: W / 2 + 175
  #     y: H / 2 - 40
  #   strength: -100

  # # piccolo_tx = PIXI.Texture.fromImage("assets/img/piccolo.png")
  # # piccolo = new PIXI.Sprite(piccolo_tx)
  # # piccolo.scale.x = -1
  # # piccolo.rotation = 0.4
  # # piccolo.position.x = attract_field.pos.x + 81
  # # piccolo.position.y = attract_field.pos.y
  # # stage.addChild(piccolo)

  # ps = new ParticleSystem(500, basic_updater, circle_drawer)
  # ps.addEmitter(basic_emitter)
  # ps.addField(attract_field)


  # createCircle = (precision, origin, radius) ->
  #   angle = 2 * Math.PI / precision
  #   circleArray = []
  #   for i in [0...precision]
  #     v =
  #       X: origin.x + radius * Math.cos(angle * i)
  #       Y: origin.y + radius * Math.sin(angle * i)
  #     circleArray.push(v)
  #   return [circleArray]

  # t_x = W / 2 / 30
  # t_y = 12
  # w = 10
  # h = 1
  # terrain = [[{X: t_x - w, Y: t_y - h}, {X: t_x + w, Y: t_y - h},
  #            {X: t_x + w, Y: t_y + h}, {X: t_x - w, Y: t_y + h}]]

  # explosion = createCircle(10,
  #   {x: t_x + 5, y: t_y - .5},
  #    1.4)

  # ClipperLib.JS.ScaleUpPaths(terrain, 100)
  # ClipperLib.JS.ScaleUpPaths(explosion, 100)

  # cpr = new ClipperLib.Clipper()
  # cpr.AddPaths(terrain, ClipperLib.PolyType.ptSubject, true)
  # cpr.AddPaths(explosion, ClipperLib.PolyType.ptClip, true)

  # solution = []
  # type = ClipperLib.ClipType.ctDifference
  # fill_type = ClipperLib.PolyFillType.pftNonZero

  # cpr.Execute(type, solution, fill_type, fill_type)

  # # solution = ClipperLib.Clipper.SimplifyPolygons(solution, fill_type)
  # solution = ClipperLib.JS.Clean(solution, .1 * 100)

  # ClipperLib.JS.ScaleDownPaths(solution, 100)
  # ClipperLib.JS.ScaleDownPaths(explosion, 100)

  # result = []
  # for poly in solution
  #   r = []
  #   for v in poly
  #     r.push({x: v.X, y: v.Y})
  #   swctx = new poly2tri.SweepContext(r)
  #   swctx.triangulate()
  #   triangles = swctx.getTriangles()
  #   triangles.forEach((t) ->
  #     tri = []
  #     t.getPoints().forEach((p) ->
  #       tri.push({x: p.x, y: p.y}))
  #     result.push(tri))

  # world = new b2Dynamics.b2World(new b2Math.b2Vec2(0, 10), true)
  # fixDef = new b2Dynamics.b2FixtureDef()
  # fixDef.density = 1.0
  # fixDef.friction = 0.5
  # fixDef.restitution = 0.2

  # bodyDef = new b2Dynamics.b2BodyDef()

  # bodyDef.type = b2Dynamics.b2Body.b2_staticBody
  # for poly in result
  #   fixDef.shape = new b2Shapes.b2PolygonShape()
  #   shape = []
  #   for v in poly
  #     shape.push(new b2Math.b2Vec2(v.x, v.y))
  #   fixDef.shape.SetAsArray(shape, shape.length)
  #   world.CreateBody(bodyDef).CreateFixture(fixDef)

  # bodyDef.type = b2Dynamics.b2Body.b2_dynamicBody
  # for i in [0..10]
  #   if (Math.random() > 0.5)
  #     fixDef.shape = new b2Shapes.b2PolygonShape()
  #     fixDef.shape.SetAsBox(Math.random() + 0.1, Math.random() + 0.1)
  #   else
  #     fixDef.shape = new b2Collision.Shapes.b2CircleShape(Math.random() + 0.1)
  #   bodyDef.position.x = Math.random() * 10 + W / 2 / 30 - 5
  #   bodyDef.position.y = Math.random() * 10
  #   world.CreateBody(bodyDef).CreateFixture(fixDef)

  # if settings.DEBUG
  #   debugDraw = new DebugDraw()
  #   debugDraw.SetSprite(graphics)
  #   debugDraw.SetDrawScale(30.0)
  #   debugDraw.SetFillAlpha(0.3)
  #   debugDraw.SetLineThickness(1.0)
  #   debugDraw.SetFlags(b2Dynamics.b2DebugDraw.e_shapeBit |
  #     b2Dynamics.b2DebugDraw.e_jointBit)
  #   world.SetDebugDraw(debugDraw)

  ##############################################################################
  # Set event handlers

  onResize = ->
    console.log("resize")

  keyDownListener = (e) ->
    console.log("key down:", e.keyCode)
    if e.keyCode == 192
      game.toggleDevMode()
    # else if e.keyCode == 32
    #   if not stance.playing
    #     stance.gotoAndPlay(0)
    game.onKeyDown(e.keyCode)

  keyUpListener = (e) ->
    console.log("key up:", e.keyCode)
    game.onKeyUp(e.keyCode)

  # Catch accidental leaving
  onBeforeUnload = (e) ->
    console.log("leaving")

    # if (not e)
    #   e = window.event
    # e.cancelBubble = true
    # if (e.stopPropagation)
    #   e.stopPropagation()
    #   e.preventDefault()
    #   return "Warning: Progress my be lost."
    # return null

  mouseMoveHandler = (e) ->
    x = e.layerX
    y = e.layerY
    console.log("mouse:", x, y)
    game.onMouseMove({x: x, y: y})

  clickHandler = (e) ->
    x = e.layerX
    y = e.layerY
    console.log("click:", x, y)

  mouseDownHandler = (e) ->
    console.log("mouse down")
    x = e.layerX
    y = e.layerY
    game.onMouseDown({x: x, y: y})

  mouseUpHandler = (e) ->
    console.log("mouse up")
    x = e.layerX
    y = e.layerY
    game.onMouseUp({x: x, y: y})

  mouseOutHandler = (e) ->
    console.log("mouse out")

  mouseWheelHandler = (e) ->
    delta = Math.max(-1, Math.min(1, (e.wheelDelta or -e.detail)))
    console.log("mouse wheel: ", delta)

  focusHandler = (e) ->
    console.log("focus")

  blurHandler = (e) ->
    console.log("blur")

  event_catcher = canvas

  window.onresize = onResize
  document.body.addEventListener('keydown', keyDownListener, false)
  document.body.addEventListener('keyup', keyUpListener, false)
  window.onbeforeunload = onBeforeUnload
  event_catcher.addEventListener('mousemove', mouseMoveHandler, false)
  event_catcher.addEventListener('click', clickHandler, false)
  event_catcher.addEventListener('mousedown', mouseDownHandler, false)
  event_catcher.addEventListener('mouseup', mouseUpHandler, false)
  event_catcher.addEventListener('mouseout', mouseOutHandler, false)
  event_catcher.addEventListener('DOMMouseScroll', mouseWheelHandler, false)
  event_catcher.addEventListener('mousewheel', mouseWheelHandler, false)
  event_catcher.addEventListener('focus', focusHandler, false)
  event_catcher.addEventListener('blur', blurHandler, false)

  ##############################################################################
  # Game loop

  main_loop = ->
    update()
    clear()
    draw()
    queue()

  update = ->
    # world.Step(1 / 60, 10, 10)
    # world.ClearForces()
    # ps.update()
    game.update()

  clear = ->
    graphics.clear()

  draw = ->
    # if settings.DEBUG
    #   world.DrawDebugData()
    # ps.draw()
    # graphics.lineStyle(1, 0x00FF00)
    # graphics.drawCircle(attract_field.pos.x, attract_field.pos.y, 5)

    game.draw()
    renderer.render(stage)

  queue = ->
    window.requestAnimationFrame(main_loop)

  # main_loop()

  t = () ->
    anim = []
    tex = PIXI.Texture.fromFrame("jackie_stand_01")
    anim.push(tex)
    for i in [1..5]
      texture = PIXI.Texture.fromFrame("jackie_stance_0#{i}")
      anim.push(texture)
    for i in [0..4]
      texture = PIXI.Texture.fromFrame("jackie_stance_0#{5-i}")
      anim.push(texture)
    anim.push(tex)

    stand = PIXI.Sprite.fromFrame("jackie_stand_01")
    stand.position.x = 32
    stand.position.y = 64
    stage.addChild(stand)

    stance = new PIXI.MovieClip(anim)
    stance.position.x = 100
    stance.position.y = 100
    stance.anchor.x = 0
    stance.anchor.y = 1
    stance.animationSpeed = 0.2
    stance.loop = false
    stance.play()
    stage.addChild(stance)

    main_loop()

  main_loop()