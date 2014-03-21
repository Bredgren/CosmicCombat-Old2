
#_require ./character/characters

class DevGui
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

  constructor: (@game) ->

  create: () ->
    @gui = new dat.GUI()
    @root_folder = @gui.addFolder('Dev Controls')
    @root_folder.open()
    @root_folder.add(@game, 'toggleDevMode')
    @_createMouseCoordsFolder()
    @_createGameFolder()
    @_createCharacterFolder()

  remove: () ->
    @gui.destroy()

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
      @game.stage.addChild(@game._dev.new_text)
    else
      @game.stage.removeChild(@game._dev.new_text)
