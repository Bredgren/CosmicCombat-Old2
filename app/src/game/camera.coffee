
#_require ../config

class Camera
  # x and y in world space
  # w and h in pixels
  constructor: (@x, @y, @w, @h, @zoom=1.0) ->

  worldToScreen: (point) ->
    return {
      x: (point.x - @x) * settings.PPM + @w / 2
      y: (point.y - @y) * settings.PPM + @h / 2
    }

  screenToWorld: (point) ->
    return {
      x: (point.x - @w / 2) / settings.PPM + @x
      y: (point.y - @h / 2) / settings.PPM + @y
    }

  copy: () ->
    return new Camera(@x, @y, @w, @h, @zoom)