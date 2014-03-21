
#_require ./character/characters

class DevGui
  enabled: false

  text: null  # PIXI text object for the "Dev-Mode" text
  new_text: null  # PIXI text object for new character
  select_text: null  # PIXI text object to show seleted character
  control_text: null  # PIXI text object to show controlled character

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

  constructor: (@game) ->
    style = {font: "15px Arial", fill: "#FFFFFF"}
    @dev_text = new PIXI.Text("Dev-Mode", style)
    @dev_text.position.x = 10
    @dev_text.position.y = 5

    style = {font: "10px Arial", fill: "#FFFFFF"}
    @new_text = new PIXI.Text("Click to spawn Character", style)
    @select_text = new PIXI.Text("Selected", style)
    @control_text = new PIXI.Text("Controlled", style)

    @new_char_options.onclick = @onCharacterClick

  create: () ->
    @gui = new dat.GUI()
    @root_folder = @gui.addFolder('Dev Controls')
    @root_folder.open()
    @root_folder.add(@, 'toggleDevMode')
    @_createMouseCoordsFolder()
    @_createGameFolder()
    @_createCharacterFolder()

  remove: () ->
    @gui.destroy()

  update: () ->
    if @enabled
      if @selected_char
        pos = @game.camera.worldToScreen(@selected_char.position())
        size = @selected_char.size()
        w = @select_text.width
        @select_text.position.x = Math.round(pos.x - w / 2)
        @select_text.position.y = Math.round(pos.y - size.h / 2 - 10)
    #     # @_dev.cur_energy_gui.max = @_dev.selected_char.energy.max()
    #     # @_dev.cur_energy_gui.current = @_dev.selected_char.energy.current()
    #     # @_dev.cur_energy_gui.strength = @_dev.selected_char.energy.strength()
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
    #     # @_dev.con_energy_gui.max = @_controlled_char.energy.max()
    #     # @_dev.con_energy_gui.current = @_controlled_char.energy.current()
    #     # @_dev.con_energy_gui.strength = @_controlled_char.energy.strength()
      else
        @control_text.position.x = -100
        @control_text.position.y = 0

  toggleDevMode: () ->
    if @enabled
      @game.stage.removeChild(@dev_text)
      if @new_char
        @game.stage.removeChild(@new_text)
      @game.stage.removeChild(@select_text)
      @game.stage.removeChild(@control_text)
      @remove()
    else
      @game.stage.addChild(@dev_text)
      if @new_char
        @game.stage.addChild(@new_text)
      @game.stage.addChild(@select_text)
      @game.stage.addChild(@control_text)
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

  _createCharacterFolder: () ->
    @char_folder = @root_folder.addFolder("Characters")
    @_createNewCharFolder()
    @_createSelCharFolder()
    @_createConCharFolder()

  _createNewCharFolder: () ->
    f = @char_folder.addFolder("New Character")
    a = f.add(@, 'new_char')
    a.onChange(@_onChangeNewChar)
    f.add(@new_char_options, 'type', Characters.TYPES)

  _createSelCharFolder: () ->

  _createConCharFolder: () ->

  _onChangeNewChar: (value) =>
    if value
      @game.stage.addChild(@new_text)
    else
      @game.stage.removeChild(@new_text)

  _selectCharacter: (character) ->
    console.log('select')
  #   if character is @_controlled_char or character is @_dev.selected_char
  #     return
  #   @_dev.selected_char = character
  #   @_createSelectedCharFolder()

  # takeControl: () ->
  #   if @_dev.selected_char
  #     if @_controlled_char
  #       @_controlled_char.endAll()
  #     @_controlled_char = @_dev.selected_char
  #     @_createControlledCharFolder()
  #     @_removeSelectedCharFolder()
  #     @_dev.selected_char = null

  onCharacterClick: (character, mousedata) =>
    if @enabled
      @_selectCharacter(character)

  onMouseDown: (screen_pos) ->
    if @new_char
      @game.spawnCharacter(@new_char_options)

  onMouseMove: (screen_pos) ->
    w = @game.camera.screenToWorld(screen_pos)
    @setMouseCoords(screen_pos.x, screen_pos.y, w.x, w.y)

    if @new_char
      w = @new_text.width
      h = @new_text.height
      @new_text.position.x = screen_pos.x - w / 2
      @new_text.position.y = screen_pos.y - h
