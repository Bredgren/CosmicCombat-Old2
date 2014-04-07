
#_require ../config
#_require ./bindings
#_require ./camera
#_require ./character/characters
#_require ./dev_gui
#_require ./starfield
#_require ./universe

class Game
  camera: null
  paused: false
  camera_attached: true
  key_bindings: null
  keys: {}

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

  energy_combos: []
  energy_combo_key: 0
  pressed_energy_combo:
    keys: []
    start_time: 0
  physical_combos: []
  pressed_physical_combo:
    directions: []
    last_time: 0

  KEY_NAMES:
    P_LEFT: 0
    P_UP: 1
    P_RIGHT: 2
    P_DOWN: 3
    E1: 4
    E2: 5
    E3: 6
    E4: 7

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
    # starfield first so stars are behind atmosphere
    @_starfield = new StarField(@camera, @bg_stage, settings.STAR_COUNT,
      settings.STAR_MIN_DEPTH, settings.STAR_MAX_DEPTH)
    @universe = new Universe(@, @debug_graphics, @camera)
    @_dev_gui = new DevGui(@)

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

    @key_bindings = new Bindings()
    @_initKeyBindings()

    combo = {}
    combo.keys = []
    combo.keys.push(@KEY_NAMES.E2)
    combo.keys.push(@KEY_NAMES.E1)
    combo.keys.push(@KEY_NAMES.E3)
    combo.action = @_onEnergyCombo1
    @energy_combos.push(combo)

    combo = {}
    combo.keys = []
    combo.keys.push(@KEY_NAMES.E4)
    combo.keys.push(@KEY_NAMES.E3)
    combo.keys.push(@KEY_NAMES.E2)
    combo.action = @_onEnergyCombo2
    @energy_combos.push(combo)

    combo = {}
    combo.keys = []
    combo.keys.push(@KEY_NAMES.P_LEFT)
    combo.keys.push(@KEY_NAMES.P_LEFT)
    combo.keys.push(@KEY_NAMES.P_UP)
    combo.action = @_onPhysicalCombo1
    @physical_combos.push(combo)

    combo = {}
    combo.keys = []
    combo.keys.push(@KEY_NAMES.P_DOWN)
    combo.keys.push(@KEY_NAMES.P_RIGHT)
    combo.keys.push(@KEY_NAMES.P_UP)
    combo.action = @_onPhysicalCombo2
    @physical_combos.push(combo)

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
      @key_bindings.onKeyDown(key_code)

  onKeyUp: (key_code) ->
    if @_controlled_char
      @key_bindings.onKeyUp(key_code)

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

  _onEnergyComboButtonDown: (combo_button) ->
    if combo_button in @pressed_energy_combo.keys then return
    if @pressed_energy_combo.keys.length is 0
      @pressed_energy_combo.start_time = (new Date()).getTime()
    @pressed_energy_combo.keys.push(combo_button)
    console.log(@pressed_energy_combo.keys)
    for combo in @energy_combos
      if combo.keys.length is @pressed_energy_combo.keys.length
        same = true
        for i in [0...combo.keys.length]
          if combo.keys[i] isnt @pressed_energy_combo.keys[i]
            same = false
            break
        if same
          end_time = (new Date()).getTime()
          time = end_time - @pressed_energy_combo.start_time
          @energy_combo_key = combo.keys[combo.keys.length - 1]
          combo.action(time)
          break

  _onEnergyComboButtonUp: (combo_button) ->
    @pressed_energy_combo.keys = @pressed_energy_combo.keys.filter(
      (b) -> b isnt combo_button)
    console.log(@pressed_energy_combo.keys)
    keys = @pressed_energy_combo.keys
    if keys.length is 1 and keys[0] is @energy_combo_key
      console.log("Energy attack released")
    else if keys.length is 0
      console.log("Energy attack stopped")
      @energy_combo_key = 0

  _onPhysicalComboButtonDown: (combo_button) ->
    prev_time = @pressed_physical_combo.last_time
    cur_time = (new Date()).getTime()
    if cur_time - prev_time > settings.PHYSICAL_COMBO_MIN_TIME
      @pressed_physical_combo.directions = []
    @pressed_physical_combo.directions.push(combo_button)
    @pressed_physical_combo.last_time = cur_time

    s = ""
    for d in @pressed_physical_combo.directions
      switch d
        when @KEY_NAMES.P_LEFT
          s += "left "
        when @KEY_NAMES.P_UP
          s += "up "
        when @KEY_NAMES.P_RIGHT
          s += "right "
        when @KEY_NAMES.P_DOWN
          s += "down "
    console.log("physical attack: #{s}")

    for combo in @physical_combos
      if combo.keys.length is @pressed_physical_combo.directions.length
        same = true
        for i in [0...combo.keys.length]
          if combo.keys[i] isnt @pressed_physical_combo.directions[i]
            same = false
            break
        if same
          combo.action()
          break

  _onPhysicalComboButtonUp: (combo_button) ->

  _onPhysicalCombo1: () ->
    console.log("Executed physical combo1")

  _onPhysicalCombo2: () ->
    console.log("Executed physical combo2")

  _onEnergyCombo1: (time) ->
    console.log("Charging energy combo1 (#{time} ms)")

  _onEnergyCombo2: (time) ->
    console.log("Charging energy combo2 (#{time} ms)")

  _initKeyBindings: () ->
    @keys.left = @key_bindings.bind(settings.BINDINGS.LEFT,
      () => @_controlled_char.startLeft(),
      () => @_controlled_char.endLeft())

    @keys.right = @key_bindings.bind(settings.BINDINGS.RIGHT,
      () => @_controlled_char.startRight(),
      () => @_controlled_char.endRight())

    @keys.up = @key_bindings.bind(settings.BINDINGS.UP,
      () => @_controlled_char.startUp(),
      () => @_controlled_char.endUp())

    @keys.down = @key_bindings.bind(settings.BINDINGS.DOWN,
      () => @_controlled_char.startDown(),
      () => @_controlled_char.endDown())

    @keys.power_up = @key_bindings.bind(settings.BINDINGS.POWER_UP,
      () => @_controlled_char.startPowerUp(),
      () => @_controlled_char.endPowerUp())

    @keys.power_down = @key_bindings.bind(settings.BINDINGS.POWER_DOWN,
      () => @_controlled_char.startPowerDown(),
      () => @_controlled_char.endPowerDown())

    @keys.fly = @key_bindings.bind(settings.BINDINGS.FLY,
      () => @_controlled_char.startFly(),
      () => @_controlled_char.endFly())

    @keys.block = @key_bindings.bind(settings.BINDINGS.BLOCK,
      () => @_controlled_char.startBlock(),
      () => @_controlled_char.endBlock())

    @keys.p_left = @key_bindings.bind(settings.BINDINGS.P_LEFT,
      () => @_onPhysicalComboButtonDown(@KEY_NAMES.P_LEFT),
      () => @_onPhysicalComboButtonUp(@KEY_NAMES.P_LEFT))

    @keys.p_up = @key_bindings.bind(settings.BINDINGS.P_UP,
      () => @_onPhysicalComboButtonDown(@KEY_NAMES.P_UP),
      () => @_onPhysicalComboButtonUp(@KEY_NAMES.P_UP))

    @keys.p_right = @key_bindings.bind(settings.BINDINGS.P_RIGHT,
      () => @_onPhysicalComboButtonDown(@KEY_NAMES.P_RIGHT),
      () => @_onPhysicalComboButtonUp(@KEY_NAMES.P_RIGHT))

    @keys.p_down = @key_bindings.bind(settings.BINDINGS.P_DOWN,
      () => @_onPhysicalComboButtonDown(@KEY_NAMES.P_DOWN),
      () => @_onPhysicalComboButtonUp(@KEY_NAMES.P_DOWN))

    @keys.e1 = @key_bindings.bind(settings.BINDINGS.E1,
      () => @_onEnergyComboButtonDown(@KEY_NAMES.E1),
      () => @_onEnergyComboButtonUp(@KEY_NAMES.E1))

    @keys.e2 = @key_bindings.bind(settings.BINDINGS.E2,
      () => @_onEnergyComboButtonDown(@KEY_NAMES.E2),
      () => @_onEnergyComboButtonUp(@KEY_NAMES.E2))

    @keys.e3 = @key_bindings.bind(settings.BINDINGS.E3,
      () => @_onEnergyComboButtonDown(@KEY_NAMES.E3),
      () => @_onEnergyComboButtonUp(@KEY_NAMES.E3))

    @keys.e4 = @key_bindings.bind(settings.BINDINGS.E4,
      () => @_onEnergyComboButtonDown(@KEY_NAMES.E4),
      () => @_onEnergyComboButtonUp(@KEY_NAMES.E4))

    # Bindings are set in US layout so set to user's preference after
    @key_bindings.layout = Bindings.COLEMAK
