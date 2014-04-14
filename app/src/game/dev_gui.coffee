
#_require ./character/characters
#_require ../util

class DevGui
  enabled: false

  MOUSE_LEFT: 0
  MOUSE_RIGHT: 2

  text: null  # PIXI text object for the "Dev-Mode" text
  select_text: null  # PIXI text object to show seleted character
  control_text: null  # PIXI text object to show controlled character
  terrain_brush: null

  screen_x: 0
  screen_y: 0
  world_x: 0
  world_y: 0
  show_aabb: true
  show_center_of_mass: true
  show_controller: true
  show_joint: true
  show_pair: true
  show_shape: true
  new_char: false
  new_char_options:
    pos:
      x: 0
      y: 0
    type: Characters.GOKU
    onclick: null
  selected_char: null  # the currently selected character
  sel_update_fn: null
  con_update_fn: null
  left_mouse: ''
  right_mouse: ''
  mouse_actions: ["none", "new character", "remove terrain"]
  terrain_brush_size: 1
  terrain_brush_prec: 10
  dragging: -1

  constructor: (@game) ->
    style = {font: "15px Arial", fill: "#FFFFFF"}
    @dev_text = new PIXI.Text("Dev-Mode", style)
    @dev_text.position.x = 10
    @dev_text.position.y = 5

    style = {font: "10px Arial", fill: "#FFFFFF"}
    @select_text = new PIXI.Text("Selected", style)
    @control_text = new PIXI.Text("Controlled", style)

    @terrain_brush = new PIXI.Graphics()
    @_onUpdateTerrainBrush()

    @new_char_options.onclick = @onCharacterClick

  _onMouseActionChange: () =>
    if (@left_mouse is "add terrain" or @left_mouse is "remove terrain" or
        @right_mouse is "add terrain" or @right_mouse is "remove terrain")
      @game.stage.addChild(@terrain_brush)
      console.log('add')
    else
      if @terrain_brush in @game.stage.children
        @game.stage.removeChild(@terrain_brush)
        console.log('remove')

  create: () ->
    @gui = new dat.GUI()
    @root_folder = @gui.addFolder('Dev Controls')
    @root_folder.open()
    @root_folder.add(@, 'toggleDevMode')
    @_createMouseCoordsFolder()
    @_createGameFolder()
    l = @root_folder.add(@, 'left_mouse', @mouse_actions)
    l.onChange(@_onMouseActionChange)
    r = @root_folder.add(@, 'right_mouse', @mouse_actions)
    r.onChange(@_onMouseActionChange)
    @_createNewCharFolder()
    @_createTerrainBrushFolder()
    @_createCharacterFolder()

  remove: () ->
    @_removeSelCharFolder()
    @_removeConCharFolder()
    @gui.destroy()

  update: () ->
    if @enabled
      if @selected_char
        pos = @game.camera.worldToScreen(@selected_char.position())
        size = @selected_char.size()
        w = @select_text.width
        @select_text.position.x = Math.round(pos.x - w / 2)
        @select_text.position.y = Math.round(pos.y - size.h / 2 - 10)
        @sel_update_fn()
      else
        @select_text.position.x = -100
        @select_text.position.y = 0
      c = @game.getControlledCharacter()
      if c
        pos = @game.camera.worldToScreen(c.position())
        size = c.size()
        w = @control_text.width
        @control_text.position.x = Math.round(pos.x - w / 2)
        @control_text.position.y = Math.round(pos.y - size.h / 2 - 10)
        @con_update_fn()
      else
        @control_text.position.x = -100
        @control_text.position.y = 0

  toggleDevMode: () ->
    if @enabled
      @game.stage.removeChild(@dev_text)
      @game.stage.removeChild(@select_text)
      @game.stage.removeChild(@control_text)
      if @terrain_brush in @game.stage.children
        @game.stage.removeChild(@terrain_brush)
        console.log('remove')
      @remove()
    else
      @game.stage.addChild(@dev_text)
      @game.stage.addChild(@select_text)
      @game.stage.addChild(@control_text)
      if (@left_mouse is "add terrain" or @left_mouse is "remove terrain" or
          @right_mouse is "add terrain" or @right_mouse is "remove terrain")
        @game.stage.addChild(@terrain_brush)
        console.log('add')
      @create()
    @enabled = not @enabled

  setMouseCoords: (screen_x, screen_y, world_x, world_y) ->
    @screen_x = screen_x
    @screen_y = screen_y
    @world_x = world_x
    @world_y = world_y

    @new_char_options.pos.x = world_x
    @new_char_options.pos.y = world_y

  _createMouseCoordsFolder: () ->
    f = @root_folder.addFolder("Mouse Coords")
    f.add(@, "screen_x").listen()
    f.add(@, "screen_y").listen()
    f.add(@, "world_x").listen()
    f.add(@, "world_y").listen()

  _createGameFolder: () ->
    f = @root_folder.addFolder("Game")
    f.open()

    f2 = f.addFolder("Debug Draw")
    f2.add(@game.universe, "debug_draw_enabled")
    onChange = (flag) =>
      (value) =>
        if value then @game.universe.addDebugDrawFlag(flag)
        else @game.universe.removeDebugDrawFlag(flag)
    a = f2.add(@, 'show_aabb')
    a.onChange(onChange(@game.universe.db_draw_flags.aabb))
    a = f2.add(@, 'show_center_of_mass')
    a.onChange(onChange(@game.universe.db_draw_flags.center))
    a = f2.add(@, 'show_controller')
    a.onChange(onChange(@game.universe.db_draw_flags.control))
    a = f2.add(@, 'show_joint')
    a.onChange(onChange(@game.universe.db_draw_flags.joint))
    a = f2.add(@, 'show_pair')
    a.onChange(onChange(@game.universe.db_draw_flags.pair))
    a = f2.add(@, 'show_shape')
    a.onChange(onChange(@game.universe.db_draw_flags.shape))

    f.add(@game, "paused")
    f.add(@game, "camera_attached")

  _onUpdateTerrainBrush: () =>
    @terrain_brush.clear()
    @terrain_brush.lineStyle(1, 0xBB0000)
    c = createCircle(@terrain_brush_prec, {x: 0, y: 0},
      @terrain_brush_size * settings.PPM)
    v0 = c[0]
    @terrain_brush.moveTo(v0.x, v0.y)
    for v in c[1..]
      @terrain_brush.lineTo(v.x, v.y)
    @terrain_brush.lineTo(v0.x, v0.y)

  _createTerrainBrushFolder: () ->
    f = @root_folder.addFolder("Terrain Brush Settings")
    size = f.add(@, 'terrain_brush_size')
    size.onChange(@_onUpdateTerrainBrush)
    prec = f.add(@, 'terrain_brush_prec')
    prec.onChange(@_onUpdateTerrainBrush)
    # f.add(@, 'terrain_brush_shape', @brush_shapes)

  _createCharacterFolder: () ->
    @char_folder = @root_folder.addFolder("Characters")
    @_createSelCharFolder()
    @_createConCharFolder()

  _createNewCharFolder: () ->
    f = @root_folder.addFolder("New Character Settings")
    f.add(@new_char_options, 'type', Characters.TYPES)

  _createSelCharFolder: () ->
    char = @selected_char
    if not char then return

    @sel_char_folder = @char_folder.addFolder("Selected Character")
    @sel_char_folder.add(@, "takeControl").listen()
    @sel_update_fn = @_fillCharFolder(char, @sel_char_folder)

  _removeSelCharFolder: () ->
    if not @sel_char_folder then return
    @char_folder.removeFolder(@sel_char_folder)
    @sel_char_folder = undefined

  restore25: () ->
    char = @game.getControlledCharacter()
    char.recoverPercent(.25)

  _createConCharFolder: () ->
    char = @game.getControlledCharacter()
    if not char then return

    @con_char_folder = @char_folder.addFolder("Controlled Character")
    @con_update_fn = @_fillCharFolder(char, @con_char_folder)
    @con_char_folder.add(@, "restore25")

  _removeConCharFolder: () ->
    if not @con_char_folder then return
    @char_folder.removeFolder(@con_char_folder)
    @con_char_folder = undefined

  _fillCharFolder: (char, f) ->
    ef = f.addFolder("Energy")
    fn = @_fillEnergyFolder(char, ef)
    df = f.addFolder("Movment Damping")
    @_fillDampingFolder(char, df)

    pos = char.position()
    f.add(pos, "x").listen()
    f.add(pos, "y").listen()

    return fn

  _fillEnergyFolder: (entity, f) ->
    energy = entity.energy
    gui = {}
    gui.max = energy.max()
    gui.current = energy.current()
    gui.strength = energy.strength()
    gui.max_gui = null
    gui.current_gui = null
    gui.strength_gui = null

    updateStrength = () ->
      gui.strength = energy.strength()
      gui.strength_gui.updateDisplay()

    updateCurrent = () ->
      gui.current = energy.current()
      gui.current_gui.updateDisplay()
      updateStrength()

    updateMax = () ->
      gui.max = energy.max()
      gui.max_gui.updateDisplay()
      updateCurrent()

    gui.max_gui = f.add(gui, "max").listen()
    gui.max_gui.onChange((value) ->
      energy.setMax(value)
      updateMax())
    gui.current_gui = f.add(gui, "current").listen()
    gui.current_gui.onChange((value) ->
      energy.setCurrent(value)
      updateCurrent())
    gui.strength_gui = f.add(gui, "strength").listen()
    gui.strength_gui.onChange((value) ->
      energy.setStrength(value)
      updateStrength())

    return updateMax

  _fillDampingFolder: (char, f) ->
    f.add(char, "fly_move_damp")
    f.add(char, "fly_not_move_damp")
    f.add(char, "ground_move_damp")
    f.add(char, "ground_not_move_damp")
    f.add(char, "not_ground_move_damp")
    f.add(char, "not_ground_not_move_damp")

  _selectCharacter: (character) ->
    c = @game.getControlledCharacter()
    if character is c or character is @selected_char then return
    @selected_char = character
    @_removeSelCharFolder()
    @_createSelCharFolder()

  takeControl: () ->
    if @selected_char
      c = @game.getControlledCharacter()
      if c then c.endAll()
      @game.setControlledCharacter(@selected_char)
      @_removeConCharFolder()
      @_createConCharFolder()
      @_removeSelCharFolder()
      @selected_char = null

  onCharacterClick: (character, mousedata) =>
    if @enabled
      @_selectCharacter(character)

  onMouseDown: (button, screen_pos) ->
    m = null
    if button is @MOUSE_LEFT
      m = @left_mouse
    else if button is @MOUSE_RIGHT
      m = @right_mouse

    switch m
      when "new character"
        @game.spawnCharacter(@new_char_options)
      when "remove terrain"
        @game.universe.removeTerrain(@world_x, @world_y,
          @terrain_brush_size, @terrain_brush_prec)

    @dragging = button

  onMouseUp: (button, screen_pos) ->
    @dragging = -1

  onMouseMove: (screen_pos) ->
    w = @game.camera.screenToWorld(screen_pos)
    @setMouseCoords(screen_pos.x, screen_pos.y, w.x, w.y)

    @terrain_brush.position.x = @screen_x
    @terrain_brush.position.y = @screen_y

    m = null
    if @dragging is @MOUSE_LEFT
      m = @left_mouse
    else if @dragging is @MOUSE_RIGHT
      m = @right_mouse

    switch m
      when "remove terrain"
        @game.universe.removeTerrain(@world_x, @world_y,
          @terrain_brush_size, @terrain_brush_prec)
