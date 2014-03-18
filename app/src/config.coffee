
settings = {
  DEBUG: true
  PRINT_INPUT: false
  FULL_SCREEN: false
  WIDTH: 900
  HEIGHT: 600
  PPM: 30  # pixels per meter

  BOX2D_TIME_STEP: 1 / 60
  BOX2D_VI: 10  # Velocity iterations
  BOX2D_PI: 10  # Position iterations
}

settings.ENERGY_BAR =
  width: settings.WIDTH * 0.6
  height: settings.WIDTH * 0.6 * 0.05
  x: settings.WIDTH / 2 -  settings.WIDTH * 0.6 / 2
  y: 15
