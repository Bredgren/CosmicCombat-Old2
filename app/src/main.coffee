# The main script for the game

#_require ./config
#_require ./global
#_require ./debug_draw

# Execute after document is loaded
$ ->
  DOM_LOADED = true
  main()

# The main method for the game
main = ->
  w = if settings.FULL_SCREEN then window.innerWidth else settings.WIDTH
  h = if settings.FULL_SCREEN then window.innerHeight else settings.HEIGHT

  body = $('body')

  container = $('<div>')
  body.append(container)

  black = 0x000000
  stage = new PIXI.Stage(black)
  renderer = PIXI.autoDetectRenderer(w, h)

  container.append(renderer.view)

  canvas = $('canvas')[0]

  graphics = new PIXI.Graphics()
  stage.addChild(graphics)

  world = new b2Dynamics.b2World(new b2Math.b2Vec2(0, 10), true)
  fixDef = new b2Dynamics.b2FixtureDef()
  fixDef.density = 1.0
  fixDef.friction = 0.5
  fixDef.restitution = 0.2

  bodyDef = new b2Dynamics.b2BodyDef()

  bodyDef.type = b2Dynamics.b2Body.b2_staticBody
  bodyDef.position.x = w / 2 / 30
  bodyDef.position.y = 13
  fixDef.shape = new b2Shapes.b2PolygonShape()
  s = fixDef.shape
  s.SetAsBox(10, 1)
  world.CreateBody(bodyDef).CreateFixture(fixDef)

  bodyDef.type = b2Dynamics.b2Body.b2_dynamicBody
  for i in [0..10]
    if (Math.random() > 0.5)
      fixDef.shape = new b2Shapes.b2PolygonShape()
      fixDef.shape.SetAsBox(Math.random() + 0.1, Math.random() + 0.1)
    else
      fixDef.shape = new b2Collision.Shapes.b2CircleShape(Math.random() + 0.1)
    bodyDef.position.x = Math.random() * 10 + w / 2 / 30 - 5
    bodyDef.position.y = Math.random() * 10
    world.CreateBody(bodyDef).CreateFixture(fixDef)

  if settings.DEBUG
    debugDraw = new DebugDraw()
    debugDraw.SetSprite(graphics)
    debugDraw.SetDrawScale(30.0)
    debugDraw.SetFillAlpha(0.3)
    debugDraw.SetLineThickness(1.0)
    debugDraw.SetFlags(b2Dynamics.b2DebugDraw.e_shapeBit |
      b2Dynamics.b2DebugDraw.e_jointBit)
    world.SetDebugDraw(debugDraw)

  ##############################################################################
  # Set event handlers

  onResize = ->
    console.log("resize")

  keyDownListener = (e) ->
    console.log("key:", e.keyCode)

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
    x = e.clientX
    y = e.clientY
    console.log("mouse:", x, y)

  clickHandler = (e) ->
    x = e.clientX
    y = e.clientY
    console.log("click:", x, y)

  mouseDownHandler = (e) ->
    console.log("mouse down")

  mouseUpHandler = (e) ->
    console.log("mouse up")

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
    world.Step(1 / 60, 10, 10)
    world.ClearForces()

  clear = ->
    graphics.clear()

  draw = ->
    if settings.DEBUG
      world.DrawDebugData()
    renderer.render(stage)

  queue = ->
    window.requestAnimationFrame(main_loop)

  main_loop()
