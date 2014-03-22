
#_require ../config
#_require ./camera
#_require ./character/characters
#_require ./dev_gui
#_require ./starfield
#_require ./universe

class Game
  camera: null
  paused: false
  camera_attached: true

  universe: null
  _last_mouse_pos: {x: 0, y: 0}
  _mouse_down: false
  _starfield: null

  _controlled_char: null

  _max_text: null
  _current_text: null
  _strength_text: null

  _new_char_options:
    pos:
      x: 0
      y: 0
    type: Characters.GOKU
    onclick: null

  _dev_gui: null

  constructor: (@stage) ->
    @hud_stage = new PIXI.DisplayObjectContainer()
    @game_stage = new PIXI.DisplayObjectContainer()
    @debug_stage = new PIXI.DisplayObjectContainer()
    @bg_stage = new PIXI.DisplayObjectContainer()
    @stage.addChild(@bg_stage)
    @stage.addChild(@game_stage)
    @stage.addChild(@hud_stage)
    @stage.addChild(@debug_stage)

    @debug_graphics = new PIXI.Graphics()
    @hud_graphics = new PIXI.Graphics()

    @debug_stage.addChild(@debug_graphics)
    @hud_stage.addChild(@hud_graphics)

    @camera = new Camera(0, 0, settings.WIDTH, settings.HEIGHT)
    @universe = new Universe(@, @debug_graphics, @camera)
    @_dev_gui = new DevGui(@)

    @_starfield = new StarField(@camera, @bg_stage, settings.STAR_COUNT,
      settings.STAR_MIN_DEPTH, settings.STAR_MAX_DEPTH)

    @_new_char_options.pos.x = -8
    @_new_char_options.pos.y = -10
    @_new_char_options.type = Characters.JACKIE
    @_new_char_options.onclick = @_dev_gui.onCharacterClick
    @spawnCharacter(@_new_char_options)
    @_controlled_char = @universe.characters[0]

    style = {font: "#{settings.ENERGY_BAR.text.size}px Arial", fill: "#FFFFFF"}
    @_max_text = new PIXI.Text("0", style)
    @stage.addChild(@_max_text)
    @_current_text = new PIXI.Text("0", style)
    @stage.addChild(@_current_text)
    @_strength_text = new PIXI.Text("0", style)
    @stage.addChild(@_strength_text)

    if settings.DEBUG and not @_dev_gui.enabled
      @_dev_gui.toggleDevMode()

  update: () ->
    if not @paused
      @universe.update()

    if @camera_attached and @_controlled_char
      pos = @_controlled_char.position()
      @camera.x = pos.x
      @camera.y = pos.y

    @_dev_gui.update()

  clear: () ->
    @debug_graphics.clear()
    @hud_graphics.clear()
    @_starfield.clear()

  draw: () ->
    @_starfield.draw()
    @universe.draw()
    @_drawEnergyBar()

  _drawEnergyBar: () ->
    if not @_controlled_char then return

    energy = @_controlled_char.energy

    @hud_graphics.lineStyle(1, 0xBB0000)
    @hud_graphics.beginFill(0xFF0000)
    @hud_graphics.fillAlpha = 0.4
    max_bar = settings.ENERGY_BAR
    @hud_graphics.drawRect(max_bar.x, max_bar.y, max_bar.width, max_bar.height)
    @hud_graphics.endFill()

    pad = settings.ENERGY_BAR.text.pad
    @_max_text.setText("" + Math.round(energy.max()))
    @_max_text.position.x = max_bar.x + max_bar.width - @_max_text.width - pad
    @_max_text.position.y = max_bar.y + pad

    @hud_graphics.lineStyle(1, 0x00BB00)
    @hud_graphics.beginFill(0x00FF00)
    @hud_graphics.fillAlpha = 0.4
    if energy.max() is 0
      width = 1
    else
      width = Math.max((energy.current() / energy.max()) * max_bar.width, 1)
    @hud_graphics.drawRect(max_bar.x, max_bar.y, width, max_bar.height)
    @hud_graphics.endFill()

    @_current_text.setText("" + Math.round(energy.current()))
    @_current_text.position.x = max_bar.x + width - @_current_text.width - pad
    @_current_text.position.y = @_max_text.position.y + @_max_text.height + pad

    @hud_graphics.lineStyle(1, 0x0000BB)
    @hud_graphics.beginFill(0x0000FF)
    @hud_graphics.fillAlpha = 0.4
    if energy.max() is 0
      width = 1
    else
      width = Math.max((energy.strength() / energy.max()) * max_bar.width, 1)
    @hud_graphics.drawRect(max_bar.x, max_bar.y, width, max_bar.height)
    @hud_graphics.endFill()

    @_strength_text.setText("" + Math.round(energy.strength()))
    @_strength_text.position.x = max_bar.x + width - @_strength_text.width - pad
    @_strength_text.position.y =
      @_current_text.position.y + @_current_text.height + pad

  toggleDevMode: () ->
    @_dev_gui.toggleDevMode()

  getControlledCharacter: () ->
    return @_controlled_char

  setControlledCharacter: (char) ->
    @_controlled_char = char

  spawnCharacter: (options) ->
    c = @universe.newCharacter(options)

  onKeyDown: (key_code) ->
    if @_controlled_char
      switch key_code
        when settings.BINDINGS.LEFT
          @_controlled_char.startLeft()
        when settings.BINDINGS.RIGHT
          @_controlled_char.startRight()
        when settings.BINDINGS.UP
          @_controlled_char.startUp()
        when settings.BINDINGS.DOWN
          @_controlled_char.startDown()
        when settings.BINDINGS.POWER_UP
          @_controlled_char.startPowerUp()
        when settings.BINDINGS.POWER_DOWN
          @_controlled_char.startPowerDown()
        when settings.BINDINGS.FLY
          @_controlled_char.startFly()
        when settings.BINDINGS.BLOCK
          @_controlled_char.startBlock()

  onKeyUp: (key_code) ->
    if @_controlled_char
      switch key_code
        when settings.BINDINGS.LEFT
          @_controlled_char.endLeft()
        when settings.BINDINGS.RIGHT
          @_controlled_char.endRight()
        when settings.BINDINGS.UP
          @_controlled_char.endUp()
        when settings.BINDINGS.DOWN
          @_controlled_char.endDown()
        when settings.BINDINGS.POWER_UP
          @_controlled_char.endPowerUp()
        when settings.BINDINGS.POWER_DOWN
          @_controlled_char.endPowerDown()
        when settings.BINDINGS.FLY
          @_controlled_char.endFly()
        when settings.BINDINGS.BLOCK
          @_controlled_char.endBlock()

  onMouseDown: (screen_pos) ->
    @_mouse_down = true
    @_dev_gui.onMouseDown(screen_pos)

  onMouseUp: (screen_pos) ->
    @_mouse_down = false

  onMouseMove: (screen_pos) ->
    if @_mouse_down and @_dev_gui.enabled
      dp =
        x: screen_pos.x - @_last_mouse_pos.x
        y: screen_pos.y - @_last_mouse_pos.y
      dp = @camera.screenToWorldUnits(dp)
      @camera.x -= dp.x
      @camera.y -= dp.y

    @_last_mouse_pos = screen_pos

    @_dev_gui.onMouseMove(screen_pos)

  onMouseWheel: (delta) ->
