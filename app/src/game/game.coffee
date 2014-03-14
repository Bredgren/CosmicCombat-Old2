
#_require ../config
#_require ./universe
#_require ./camera

class Game
  _dev_mode: false
  _universe: null
  camera: null
  _last_mouse_pos: {x: 0, y: 0}
  _mouse_down: false

  constructor: (@stage, @graphics) ->
    @camera = new Camera(0, 0, settings.WIDTH, settings.HEIGHT)
    @_universe = new Universe(@, @graphics, @camera)

    style = {font: "15px Arial", fill: "#FFFFFF"}
    @_dev_text = new PIXI.Text("Dev-Mode", style)
    @_dev_text.position.x = 10
    @_dev_text.position.y = 5
    @_dev_text.renderable = false
    @stage.addChild(@_dev_text)

  update: () ->
    @_universe.update()

  draw: () ->
    @_universe.draw()

  toggleDevMode: () ->
    if @_dev_mode
      @stage.addChild(@_dev_text)
    else
      @stage.removeChild(@_dev_text)
    @_dev_mode = not @_dev_mode

  toggleDebugDraw: () ->
    @_universe.toggleDebugDraw()

  onKeyDown: (key_code) ->
    if key_code == 65
      loc = @_universe.controlled_char.body.GetPosition()
      @_universe.controlled_char.body.ApplyForce(new b2Vec2(-100,0), loc)
    else if key_code == 68
      loc = @_universe.controlled_char.body.GetPosition()
      @_universe.controlled_char.body.ApplyForce(new b2Vec2(100,0), loc)

  onKeyUp: (key_code) ->

  onMouseDown: (screen_pos) ->
    @_mouse_down = true

  onMouseUp: (screen_pos) ->
    @_mouse_down = false

  onMouseMove: (screen_pos) ->
    if @_mouse_down
      dx = screen_pos.x - @_last_mouse_pos.x
      dy = screen_pos.y - @_last_mouse_pos.y
      @camera.x -= dx
      @camera.y -= dy

    @_last_mouse_pos = screen_pos

  onMouseWheel: (delta) ->