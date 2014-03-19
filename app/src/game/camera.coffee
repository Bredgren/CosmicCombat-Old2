
#_require ../config

class Camera
  # x and y in world space
  # w and h in pixels
  constructor: (@x, @y, @w, @h, @zoom=1.0) ->

  # Converts a point in world space to it's corresponting point on the screen
  worldToScreen: (point) ->
    return {
      x: (point.x - @x) * settings.PPM + @w / 2
      y: (point.y - @y) * settings.PPM + @h / 2
    }

  # Converts a point on the screen to it's corresponting point in the world
  screenToWorld: (point) ->
    return {
      x: (point.x - @w / 2) / settings.PPM + @x
      y: (point.y - @h / 2) / settings.PPM + @y
    }

  # Converts a point's units from screen space to world space
  screenToWorldUnits: (point) ->
    return {
      x: point.x / settings.PPM
      y: point.y / settings.PPM
    }

  # Converts a point's units from world space to screen space
  worldToScreenUnits: (point) ->
    return {
      x: point.x * settings.PPM
      y: point.y * settings.PPM
    }

  # Checks if the given point (screen coords) is visible on the screen
  onScreen: (point) ->
    return 0 <= point.x <= settings.WIDTH and 0 <= point.y <= settings.HEIGHT

  copy: () ->
    return new Camera(@x, @y, @w, @h, @zoom)