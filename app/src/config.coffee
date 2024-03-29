
settings = {
  DEBUG: true
  PRINT_INPUT: false
  FULL_SCREEN: false
  WIDTH: 1000
  HEIGHT: 700
  PPM: 30  # pixels per meter
  TILE_SIZE: 512

  STAR_COUNT: 50
  STAR_MIN_DEPTH: 1
  STAR_MAX_DEPTH: 0
  STAR_MAX_SIZE: 2

  BOX2D_TIME_STEP: 1 / 60
  BOX2D_VI: 10  # Velocity iterations
  BOX2D_PI: 10  # Position iterations

  COLLISION_CATEGORY:
    TERRAIN:   0x0001
    CHARACTER: 0x0002

  COLLISION_GROUP:
    CHARACTER: -1

  PHYSICAL_COMBO_MIN_TIME: 150

  BINDINGS:
    LEFT:  65 # A
    RIGHT: 68 # D
    UP:    87 # W
    DOWN:  83 # S
    POWER_UP:   69 # E
    POWER_DOWN: 81 # Q
    BLOCK: 32 # SPACE
    PAUSE: 27 # ESC
    INTERACT: 67 # C
    FLY: 16 # SHIFT
    #Items
    #Physical Attacks
    P_LEFT: 37
    P_UP: 38
    P_RIGHT: 39
    P_DOWN: 40
    #Energy Attacks
    E1: 85 # U
    E2: 73 # I
    E3: 79 # O
    E4: 80 # P
}

settings.ENERGY_BAR =
  text:
    size: 8
    pad: 1
  width: settings.WIDTH * 0.6
  height: settings.WIDTH * 0.6 * 0.06
  x: settings.WIDTH / 2 -  settings.WIDTH * 0.6 / 2
  y: 15
