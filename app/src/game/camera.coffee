
class Camera
  constructor: (@x, @y, @w, @h, @zoom=1.0) ->

  worldToScreen: (point) ->
    return {
      x: point.x - @x + @w / 2
      y: point.y - @y + @h / 2
    }

  screenToWorld: (point) ->
    return {
      x: point.x + @x - @w / 2
      y: point.y + @y - @h / 2
    }