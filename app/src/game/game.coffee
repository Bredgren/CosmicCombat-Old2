
#_require ../config
#_require ./universe
#_require ./camera

class Game
  camera: null
  paused: false
  camera_attached: true

  _universe: null
  _last_mouse_pos: {x: 0, y: 0}
  _mouse_down: false

  _controlled_char: null

  _dev:
    enabled: false  # whether dev-mode is enabled
    text: null  # PIXI text object for the "Dev-Mode" text
    new_char_options: {}  # options used to make new character
    new_char: false  # click creates a character when true
    new_text: null  # PIXI text object for new character
    select_text: null  # PIXI text object to show seleted character
    control_text: null  # PIXI text object to show controlled character
    selected_char: null  # the currently selected character
    mouse_screen_x: 0
    mouse_screen_y: 0
    mouse_world_x: 0
    mouse_world_y: 0

  constructor: (@stage, @graphics) ->
    @camera = new Camera(0, 0, settings.WIDTH, settings.HEIGHT)
    @_universe = new Universe(@, @graphics, @camera)
    @_resetGui()

    @_dev.new_char_options =
      pos:
        x: -8
        y: -10
      type: "Jackie"
    @spawnCharacter()
    @_dev.new_char_options.pos.x = 8
    @spawnCharacter()
    @_controlled_char = @_universe.characters[0]

    style = {font: "15px Arial", fill: "#FFFFFF"}
    @_dev.text = new PIXI.Text("Dev-Mode", style)
    @_dev.text.position.x = 10
    @_dev.text.position.y = 5

    style = {font: "10px Arial", fill: "#FFFFFF"}
    @_dev.new_text = new PIXI.Text("Click to spawn Character", style)
    @_dev.select_text = new PIXI.Text("Selected", style)
    @_dev.control_text = new PIXI.Text("Controlled", style)

    if settings.DEBUG
      @toggleDevMode()

  update: () ->
    if not @paused
      @_universe.update()

    if @camera_attached and @_controlled_char
      pos = @_controlled_char.position()
      @camera.x = pos.x
      @camera.y = pos.y

    if @_dev.enabled
      if @_dev.selected_char
        pos = @camera.worldToScreen(@_dev.selected_char.position())
        size = @_dev.selected_char.size()
        w = @_dev.select_text.width
        @_dev.select_text.position.x = Math.round(pos.x - w / 2)
        @_dev.select_text.position.y = Math.round(pos.y - size.h / 2 - 20)
      if @_controlled_char
        pos = @camera.worldToScreen(@_controlled_char.position())
        size = @_controlled_char.size()
        w = @_dev.control_text.width
        @_dev.control_text.position.x = Math.round(pos.x - w / 2)
        @_dev.control_text.position.y = Math.round(pos.y - size.h / 2 - 10)

  draw: () ->
    @_universe.draw()

  _onCharacterClick: (character, mousedata) =>
    if @_dev.enabled
      @_selectCharacter(character)

  spawnCharacter: () ->
    c = @_universe.newCharacter(@_dev.new_char_options, @_onCharacterClick)

    # Auto select newly created character
    @_selectCharacter(c)

  toggleDevMode: () ->
    if @_dev.enabled
      @stage.removeChild(@_dev.text)
      if @_dev.new_char
        @stage.removeChild(@_dev.new_text)
      @stage.removeChild(@_dev.select_text)
      @stage.removeChild(@_dev.control_text)
      @_dev.gui.destroy()
    else
      @stage.addChild(@_dev.text)
      if @_dev.new_char
        @stage.addChild(@_dev.new_text)
      @stage.addChild(@_dev.select_text)
      @stage.addChild(@_dev.control_text)
      @_resetGui()
      @_createGui()
    @_dev.enabled = not @_dev.enabled

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
    if @_dev.new_char
      @_dev.new_char_options.pos.x = @_dev.mouse_world_x
      @_dev.new_char_options.pos.y = @_dev.mouse_world_y
      @spawnCharacter()

  onMouseUp: (screen_pos) ->
    @_mouse_down = false

  onMouseMove: (screen_pos) ->
    if @_mouse_down and @_dev.enabled
      dp =
        x: screen_pos.x - @_last_mouse_pos.x
        y: screen_pos.y - @_last_mouse_pos.y
      dp = @camera.screenToWorldUnits(dp)
      @camera.x -= dp.x
      @camera.y -= dp.y

    @_last_mouse_pos = screen_pos

    @_dev.mouse_screen_x = screen_pos.x
    @_dev.mouse_screen_y = screen_pos.y
    w = @camera.screenToWorld(screen_pos)
    @_dev.mouse_world_x = w.x
    @_dev.mouse_world_y = w.y

    if @_dev.new_char
      w = @_dev.new_text.width
      h = @_dev.new_text.height
      @_dev.new_text.position.x = screen_pos.x - w / 2
      @_dev.new_text.position.y = screen_pos.y - h

  onMouseWheel: (delta) ->

  # Transfers user control to the selected character
  takeControl: () ->
    if @_dev.selected_char
      @_controlled_char = @_dev.selected_char
      @_createGuiControlledChar(@_dev.char_gui.folder)

  _selectCharacter: (character) ->
    @_dev.selected_char = character
    if @_dev.cur_char_gui.folder
      @_dev.cur_char_gui.folder.remove(@_dev.cur_char_gui.pos.x)
      @_dev.cur_char_gui.folder.remove(@_dev.cur_char_gui.pos.y)
      pos = @_dev.selected_char.position()
      @_dev.cur_char_gui.pos.x =
        @_dev.cur_char_gui.folder.add(pos, 'x').listen()
      @_dev.cur_char_gui.pos.y =
        @_dev.cur_char_gui.folder.add(pos, 'y').listen()

  _changeNewChar: (value) =>
    if value
      @stage.addChild(@_dev.new_text)
    else
      @stage.removeChild(@_dev.new_text)

  _resetGui: () ->
    @_dev.gui = null
    @_dev.mouse_gui =
      folder: null
    @_dev.game_gui =
      folder: null
      debug_draw: null
      paused: null
      camera: null
    @_dev.char_gui =
      folder: null
    @_dev.new_char_gui =
      folder: null
      new_char: null
      type: null
    @_dev.cur_char_gui =
      folder: null
      control: null
      pos: {}
    @_dev.con_char_gui =
      folder: null
      pos: {}

  _createGui: () ->
    @_dev.gui = new dat.GUI()
    @_dev.gui.add(@, 'toggleDevMode')

    @_createGuiMouseCoords(@_dev.gui)
    @_createGuiGame(@_dev.gui)
    @_createGuiCharacter(@_dev.gui)

  _createGuiMouseCoords: (parent) ->
    f = parent.addFolder('Mouse Coords')
    @_dev.mouse_gui.folder = f
    f.add(@_dev, 'mouse_screen_x').listen()
    f.add(@_dev, 'mouse_screen_y').listen()
    f.add(@_dev, 'mouse_world_x').listen()
    f.add(@_dev, 'mouse_world_y').listen()

  _createGuiGame: (parent) ->
    f = parent.addFolder('Game')
    @_dev.game_gui.folder = f
    @_dev.game_gui.debug_draw = f.add(@, 'toggleDebugDraw')
    @_dev.game_gui.paused = f.add(@, 'paused')
    @_dev.game_gui.camera = f.add(@, 'camera_attached')
    f.open()

  _createGuiCharacter: (parent) ->
    f = parent.addFolder('Characters')
    @_dev.char_gui.folder = f
    @_createGuiNewChar(f)
    @_createGuiSelectedChar(f)
    @_createGuiControlledChar(f)

  _createGuiNewChar: (parent) ->
    f = parent.addFolder('New Character')
    @_dev.new_char_gui.folder = f
    @_dev.new_char_gui.new_char = f.add(@_dev, 'new_char')
    @_dev.new_char_gui.new_char.onChange(@_changeNewChar)
    @_dev.new_char_gui.type = f.add(@_dev.new_char_options, 'type',
      ['Jackie', 'Goku'])

  _createGuiSelectedChar: (parent) ->
    f = parent.addFolder('Selected Character')
    @_dev.cur_char_gui.folder = f
    @_dev.cur_char_gui.control = f.add(@, 'takeControl').listen()
    pos = @_dev.selected_char.position()
    @_dev.cur_char_gui.pos.x = f.add(pos, 'x').listen()
    @_dev.cur_char_gui.pos.y = f.add(pos, 'y').listen()

  _createGuiControlledChar: (parent) ->
    if @_dev.con_char_gui.folder
      @_dev.con_char_gui.folder.remove(@_dev.con_char_gui.pos.x)
      @_dev.con_char_gui.folder.remove(@_dev.con_char_gui.pos.y)
    else
      @_dev.con_char_gui.folder = parent.addFolder('Controlled Character')

    f = @_dev.con_char_gui.folder

    pos = @_controlled_char.position()
    @_dev.con_char_gui.pos.x = f.add(pos, 'x').listen()
    @_dev.con_char_gui.pos.y = f.add(pos, 'y').listen()
    # @_dev.new_char_gui.type =
    #   @_dev.new_char_gui.folder.add(@_dev.new_char_options, 'type',
    #     ['Jackie', 'Goku'])
