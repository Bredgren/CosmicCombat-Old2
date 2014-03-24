
class StarField
  # max_depth < min_depth
  # max_depth = 0 means stars with depth 0 don't move on screen
  constructor: (@camera, @stage, @star_count, @min_depth, @max_depth) ->
    @_g = new PIXI.Graphics()
    @stage.addChild(@_g)
    @_stars = []
    for i in [0...@star_count]
      pos = {x: Math.random() * @camera.w, y: Math.random() * @camera.h}
      star = {
        x: pos.x
        y: pos.y
        z: (Math.random() * (@min_depth - @max_depth)) + @max_depth
      }
      @_stars.push(star)
      @_prev_camera_pos = {x: @camera.x, y: @camera.y}

  clear: () ->
    @_g.clear()

  draw: () ->
    dx = @camera.x - @_prev_camera_pos.x
    dy = @camera.y - @_prev_camera_pos.y
    # Fixes stars juming when camera wrapes. Hacky but works for now.
    if dx > 5 or dx < -5
      dx = 0
    if dy > 5 or dy < -5
      dy = 0

    for star in @_stars
      r = star.z / (@min_depth - @max_depth)
      star.x -= dx - (dx * r)
      star.y -= dy - (dy * r)
      star.x = star.x % @camera.w
      star.y = star.y % @camera.h
      if star.x < 0 then star.x += @camera.w
      if star.y < 0 then star.y += @camera.h
      s = settings.STAR_MAX_SIZE - r * settings.STAR_MAX_SIZE
      @_g.beginFill(0xFFFFFF)
      @_g.drawRect(Math.round(star.x), Math.round(star.y), s, s)
      @_g.endFill()

    @_prev_camera_pos = {x: @camera.x, y: @camera.y}
