
#_require ../config
#_require ./universe
#_require ./camera

class Game
  _dev_mode: false
  _universe: null
  camera: null
  _last_mouse_pos: {x: 0, y: 0}
  _mouse_down: false

  _controlled_char: null

  _char_options: {}

  constructor: (@stage, @graphics) ->
    @camera = new Camera(0, 0, settings.WIDTH, settings.HEIGHT)
    @_universe = new Universe(@, @graphics, @camera)
    @_char_options =
      pos:
        x: -8
        y: -10
    @_universe.newCharacter(@_char_options)
    @_char_options.pos.x = 8
    @_universe.newCharacter(@_char_options)
    @_controlled_char = @_universe.characters[1]

    style = {font: "15px Arial", fill: "#FFFFFF"}
    @_dev_text = new PIXI.Text("Dev-Mode", style)
    @_dev_text.position.x = 10
    @_dev_text.position.y = 5
    @_dev_text.renderable = false

    @_gui = null

    if settings.DEBUG
      @toggleDevMode()

  newCharacter: () ->
    # @_char_options.pos.x = 20 * Math.random() - 10
    # @_char_options.pos.y = -10
    @_universe.newCharacter(@_char_options)

  update: () ->
    @_universe.update()

  draw: () ->
    @_universe.draw()

  toggleDevMode: () ->
    if @_dev_mode
      @stage.removeChild(@_dev_text)
      @_gui.destroy()
    else
      @stage.addChild(@_dev_text)
      @_gui = new dat.GUI()
      @_gui.add(@, 'toggleDevMode')
      @_gui.add(@, 'toggleDebugDraw')
      @_gui.add(@, 'newCharacter')
      @_gui.add(@_char_options.pos, 'x').listen()
      @_gui.add(@_char_options.pos, 'y').listen()
    @_dev_mode = not @_dev_mode

  toggleDebugDraw: () ->
    @_universe.toggleDebugDraw()

  onKeyDown: (key_code) ->
    if key_code == 65 # A
      @_controlled_char.startMoveLeft()
    else if key_code == 68 # B
      @_controlled_char.startMoveRight()
    else if key_code == 87 # W
      @_controlled_char.startJump()

  onKeyUp: (key_code) ->
    if key_code == 65
      @_controlled_char.endMoveLeft()
    else if key_code == 68
      @_controlled_char.endMoveRight()
    else if key_code == 87
      @_controlled_char.endJump()

  onMouseDown: (screen_pos) ->
    @_mouse_down = true
    p = @camera.screenToWorld(screen_pos)
    @_char_options.pos.x = p.x
    @_char_options.pos.y = p.y

  onMouseUp: (screen_pos) ->
    @_mouse_down = false

  onMouseMove: (screen_pos) ->
    s = @camera.screenToWorld(screen_pos)
    if @_mouse_down and @_dev_mode
      dp =
        x: screen_pos.x - @_last_mouse_pos.x
        y: screen_pos.y - @_last_mouse_pos.y
      dp = @camera.screenToWorld(dp)
      @camera.x -= dp.x
      @camera.y -= dp.y

    @_last_mouse_pos = @camera.worldToScreen(s)

  onMouseWheel: (delta) ->