
settings = {
  DEBUG: true
  PRINT_INPUT: false
  FULL_SCREEN: false
  WIDTH: 1000
  HEIGHT: 700
  PPM: 30  # pixels per meter

  STAR_COUNT: 50
  STAR_MIN_DEPTH: 0.01
  STAR_MAX_DEPTH: 0

  BOX2D_TIME_STEP: 1 / 60
  BOX2D_VI: 10  # Velocity iterations
  BOX2D_PI: 10  # Position iterations

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
    #Items
    #Physical Attacks
    #Energy Attacks
}

settings.ENERGY_BAR =
  text:
    size: 8
    pad: 1
  width: settings.WIDTH * 0.6
  height: settings.WIDTH * 0.6 * 0.06
  x: settings.WIDTH / 2 -  settings.WIDTH * 0.6 / 2
  y: 15
