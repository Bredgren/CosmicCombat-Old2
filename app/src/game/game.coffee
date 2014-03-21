
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


  ### Dev-Mode GUI stuff ###

  # Transfers user control to the selected character
  # takeControl: () ->
  #   if @_dev.selected_char
  #     if @_controlled_char
  #       @_controlled_char.endAll()
  #     @_controlled_char = @_dev.selected_char
  #     @_createControlledCharFolder()
  #     @_removeSelectedCharFolder()
  #     @_dev.selected_char = null

  # _selectCharacter: (character) ->
  #   if character is @_controlled_char or character is @_dev.selected_char
  #     return
  #   @_dev.selected_char = character
  #   @_createSelectedCharFolder()

  # _onChangeNewChar: (value) =>
  #   if value
  #     @stage.addChild(@_dev.new_text)
  #   else
  #     @stage.removeChild(@_dev.new_text)

  # _initGui: () ->
  #   @_dev.root_gui = new RootFolder(@)
  #   # @_dev.mouse_gui = new MouseCoordsFolder(@_dev.root_gui, @_dev)

  # _resetGui: () ->
  #   @_dev.root_gui.reset()
  #   # @_dev.gui.folder = null
  #   # @_resetMouseCoordsFolder(@_dev.gui)
  #   # @_resetGameFolder(@_dev.gui.root)
  #   # @_resetCharacterFolder(@_dev.gui.root)

  #   # if @_dev.gui.root
  #   #   @_removeGui()

  # # Assumes _resetGui has been called
  # _createGui: () ->
  #   @_dev.root_gui.create()
  #   # @_dev.mouse_gui.create()

  #   # @_dev.gui.folder = new dat.GUI()
  #   # @_dev.gui.folder.add(@, 'toggleDevMode')

  #   # @_createMouseCoordsFolder(@_dev.gui)
  #   # @_createGameFolder(@_dev.gui.root.folder).open()
  #   # @_createCharacterFolder(@_dev.gui.root.folder)

  # _removeGui: () ->
  #   @_dev.root_gui.remove()
  #   # if not @_dev.gui.folder then return

  #   # @_dev.gui.folder.destroy()
  #   # @_resetGui()

  # _resetMouseCoordsFolder: (parent) ->
  #   if parent
  #     parent.mouse_gui =
  #       folder: null
  #       s_x: null
  #       s_y: null
  #       w_x: null
  #       w_y: null

  # _createMouseCoordsFolder: (parent) ->
  #   f = parent.folder.addFolder('Mouse Coords')
  #   parent.mouse_gui.folder = f
  #   parent.mouse_gui.s_x = f.add(@_dev, 'mouse_screen_x').listen()
  #   parent.mouse_gui.s_y = f.add(@_dev, 'mouse_screen_y').listen()
  #   parent.mouse_gui.w_x = f.add(@_dev, 'mouse_world_x').listen()
  #   parent.mouse_gui.w_y = f.add(@_dev, 'mouse_world_y').listen()
  #   return f

  # _removeMouseCoordsFolder: () ->
  #   if not @_dev.mouse_gui.folder then return

  #   parent = @_dev.gui
  #   parent.removeFolder(@_dev.mouse_gui.folder)
  #   @_resetMouseCoordsFolder

  # _resetGameFolder: () ->
  #   @_dev.game_gui =
  #     folder: null
  #     paused: null
  #     camera: null
  #   @_resetDebugDrawFolder()

  # _createGameFolder: () ->
  #   parent = @_dev.gui
  #   f = parent.addFolder('Game')
  #   @_dev.game_gui.folder = f
  #   @_createDebugDrawFolder()
  #   @_dev.game_gui.paused = f.add(@, 'paused')
  #   @_dev.game_gui.camera = f.add(@, 'camera_attached')

  # _removeGameFolder: () ->
  #   if not @_dev.game_gui.folder then return

  #   parent = @_dev.gui
  #   parent.removeFolder(@_dev.game_gui.folder)
  #   @_resetGameFolder()

  # _resetDebugDrawFolder: () ->
  #   @_dev.debug_gui =
  #     folder: null
  #     debug_draw: null
  #     aabb: null
  #     center: null
  #     control: null
  #     joint: null
  #     pair: null
  #     shape: null

  # _createDebugDrawFolder: () ->
  #   parent = @_dev.game_gui.folder
  #   f = parent.addFolder('Debug Draw')
  #   @_dev.debug_gui.folder = f
  #   @_dev.debug_gui.debug_draw = f.add(@, 'toggleDebugDraw')
  #   onChange = (flag) =>
  #     (value) =>
  #       if value then @universe.addDebugDrawFlag(flag)
  #       else @universe.removeDebugDrawFlag(flag)
  #   @_dev.debug_gui.aabb = f.add(@_dev, 'show_aabb')
  #   @_dev.debug_gui.aabb.onChange(onChange(@universe.db_draw_flags.aabb))
  #   @_dev.debug_gui.center = f.add(@_dev, 'show_center_of_mass')
  #   @_dev.debug_gui.center.onChange(onChange(@universe.db_draw_flags.center))
  #   @_dev.debug_gui.control = f.add(@_dev, 'show_controller')
  #   @_dev.debug_gui.control.onChange(onChange(@universe.db_draw_flags.control))
  #   @_dev.debug_gui.joint = f.add(@_dev, 'show_joint')
  #   @_dev.debug_gui.joint.onChange(onChange(@universe.db_draw_flags.joint))
  #   @_dev.debug_gui.pair = f.add(@_dev, 'show_pair')
  #   @_dev.debug_gui.pair.onChange(onChange(@universe.db_draw_flags.pair))
  #   @_dev.debug_gui.shape = f.add(@_dev, 'show_shape')
  #   @_dev.debug_gui.shape.onChange(onChange(@universe.db_draw_flags.shape))

  # _removeDebugDrawFolder: () ->
  #   if not @_dev.debug_gui.folder then return

  #   parent = @_dev.game_gui.folder
  #   parent.removeFolder(@_dev.debug_gui.folder)
  #   @_resetDebugDrawFolder()

  # _resetCharacterFolder: () ->
  #   @_dev.char_gui =
  #     folder: null
  #   @_resetNewCharFolder()
  #   @_resetSelectedCharFolder()
  #   @_resetControlledCharFolder()

  # _createCharacterFolder: () ->
  #   parent = @_dev.gui
  #   f = parent.addFolder('Characters')
  #   @_dev.char_gui.folder = f
  #   @_createNewCharFolder()
  #   @_createSelectedCharFolder()
  #   @_createControlledCharFolder()

  # _removeCharacterFolder: () ->
  #   if not @_dev.char_gui.folder then return

  #   parent = @_dev.gui
  #   parent.removeFolder(@_dev.char_gui.folder)
  #   @_resetCharacterFolder()

  # _resetNewCharFolder: () ->
  #   @_dev.new_char_gui =
  #     folder: null
  #     new_char: null
  #     type: null

  # _createNewCharFolder: () ->
  #   parent = @_dev.char_gui.folder
  #   f = parent.addFolder('New Character')
  #   @_dev.new_char_gui.folder = f
  #   @_dev.new_char_gui.new_char = f.add(@_dev, 'new_char')
  #   @_dev.new_char_gui.new_char.onChange(@_onChangeNewChar)
  #   @_dev.new_char_gui.type = f.add(@_dev.new_char_options, 'type',
  #     Characters.TYPES)

  # _removeNewCharFolder: () ->
  #   if not @_dev.new_char_gui.folder then return

  #   parent = @_dev.char_gui.folder
  #   parent.removeFolder(@_dev.new_char_gui.folder)
  #   @_resetNewCharFolder()

  # _resetSelectedCharFolder: () ->
  #   @_dev.cur_char_gui =
  #     folder: null
  #     control: null
  #     pos:
  #       x: 0
  #       y: 0
  #   @_resetSelectedEnergyFolder()

  # # Creates or updates the folder
  # _createSelectedCharFolder: () ->
  #   if not @_dev.selected_char then return

  #   if not @_dev.cur_char_gui.folder
  #     parent = @_dev.char_gui.folder
  #     f = parent.addFolder('Selected Character')
  #     @_dev.cur_char_gui.folder = f
  #     @_dev.cur_char_gui.control = f.add(@, 'takeControl').listen()
  #   else
  #     f = @_dev.cur_char_gui.folder
  #     f.remove(@_dev.cur_char_gui.pos.x)
  #     f.remove(@_dev.cur_char_gui.pos.y)
  #     @_removeSelectedEnergyFolder()

  #   @_createSelectedEnergyFolder()
  #   # TODO: fix bug when user changes x/y they are set to NaN.
  #   pos = @_dev.selected_char.position()
  #   @_dev.cur_char_gui.pos.x = f.add(pos, 'x').listen()
  #   @_dev.cur_char_gui.pos.y = f.add(pos, 'y').listen()

  # _removeSelectedCharFolder: () ->
  #   if not @_dev.cur_char_gui.folder then return

  #   parent = @_dev.char_gui.folder
  #   parent.removeFolder(@_dev.cur_char_gui.folder)
  #   @_resetSelectedCharFolder()

  # _resetControlledCharFolder: () ->
  #   @_dev.con_char_gui =
  #     folder: null
  #     pos:
  #       x: null
  #       y: null
  #     lin_damp: null
  #   @_resetControlledEnergyFolder()

  # # Creates or updates the folder
  # _createControlledCharFolder: () ->
  #   if not @_controlled_char then return

  #   if not @_dev.con_char_gui.folder
  #     parent = @_dev.char_gui.folder
  #     f = parent.addFolder('Controlled Character')
  #     @_dev.con_char_gui.folder = f
  #   else
  #     f = @_dev.con_char_gui.folder
  #     f.remove(@_dev.con_char_gui.pos.x)
  #     f.remove(@_dev.con_char_gui.pos.y)
  #     f.remove(@_dev.con_char_gui.lin_damp)
  #     @_removeControlledEnergyFolder()

  #   @_createControlledEnergyFolder()
  #   pos = @_controlled_char.position()
  #   @_dev.con_char_gui.pos.x = f.add(pos, 'x').listen()
  #   @_dev.con_char_gui.pos.y = f.add(pos, 'y').listen()
  #   @_dev.con_char_gui.lin_damp = f.add(@_controlled_char, 'linear_damping')

  # _removeControlledCharFolder: () ->
  #   if not @_dev.con_char_gui.folder then return

  #   parent = @_dev.char_gui.folder
  #   parent.removeFolder(@_dev.con_char_gui.folder)
  #   @_resetControlledCharFolder()

  # _createCharFolder: (char, gui, name) ->
  #   if not char then return

  #   if not gui.folder
  #     parent = @_dev.char_gui.folder
  #     f = parent.addFolder(name)
  #     gui.folder = f
  #   else
  #     f = gui.folder
  #     f.remove(gui.pos.x)
  #     f.remove(gui.pos.y)
  #     f.remove(gui.lin_damp)
  #     # @_removeControlledEnergyFolder()

  #   # @_createControlledEnergyFolder()
  #   pos = char.position()
  #   gui.pos.x = f.add(pos, 'x').listen()
  #   gui.pos.y = f.add(pos, 'y').listen()
  #   gui.lin_damp = f.add(char, 'linear_damping')

  # _resetControlledEnergyFolder: () ->
  #   @_dev.con_energy_gui =
  #     folder: null
  #     max_gui: null
  #     current_gui: null
  #     strength_gui: null
  #     max: 0
  #     current: 0
  #     strength: 0

  # _createControlledEnergyFolder: () ->
  #   parent = @_dev.con_char_gui.folder
  #   gui = @_dev.con_energy_gui
  #   f = @_createEnergyFolder(parent, gui, @_controlled_char)
  #   @_dev.con_energy_gui.folder = f

  # _removeControlledEnergyFolder: () ->
  #   if not @_dev.con_energy_gui.folder then return

  #   parent = @_dev.con_char_gui.folder
  #   parent.removeFolder(@_dev.con_energy_gui.folder)
  #   @_resetControlledEnergyFolder()

  # _resetSelectedEnergyFolder: () ->
  #   @_dev.cur_energy_gui =
  #     folder: null
  #     max_gui: null
  #     current_gui: null
  #     strength_gui: null
  #     max: 0
  #     current: 0
  #     strength: 0

  # _createSelectedEnergyFolder: () ->
  #   parent = @_dev.cur_char_gui.folder
  #   gui = @_dev.cur_energy_gui
  #   f = @_createEnergyFolder(parent, gui, @_dev.selected_char)
  #   @_dev.cur_energy_gui.folder = f

  # _removeSelectedEnergyFolder: () ->
  #   if not @_dev.cur_energy_gui.folder then return

  #   parent = @_dev.cur_char_gui.folder
  #   parent.removeFolder(@_dev.cur_energy_gui.folder)
  #   @_resetSelectedEnergyFolder()

  # _createEnergyFolder: (parent, gui, char) ->
  #   if not char then return

  #   f = parent.addFolder('Energy')

  #   energy = char.energy
  #   gui.max = energy.max()
  #   gui.current = energy.current()
  #   gui.strength = energy.strength()

  #   updateStrength = () ->
  #     gui.strength = energy.strength()
  #     gui.strength_gui.updateDisplay()

  #   updateCurrent = (value) ->
  #     gui.current = energy.current()
  #     gui.current_gui.updateDisplay()
  #     gui.strength_gui.updateDisplay()
  #     updateStrength()

  #   updateMax = (value) ->
  #     gui.max = energy.max()
  #     gui.max_gui.updateDisplay()
  #     updateCurrent(value)

  #   gui.max_gui = f.add(gui, 'max').listen()
  #   gui.max_gui.onChange((value) ->
  #     energy.setMax(value)
  #     updateMax())
  #   gui.current_gui = f.add(gui, 'current').listen()
  #   gui.current_gui.onChange((value) ->
  #     energy.setCurrent(value)
  #     updateCurrent())
  #   gui.strength_gui = f.add(gui, 'strength').listen()
  #   gui.strength_gui.onChange((value) ->
  #     energy.setStrength(value)
  #     updateStrength())

  #   return f
