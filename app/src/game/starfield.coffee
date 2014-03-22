
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

  clear: () ->
    @_g.clear()

  draw: () ->
    for star in @_stars
      world_pos = @camera.screenToWorld(star)
      pos = {
        x: world_pos.x - @camera.x * star.z
        y: world_pos.y - @camera.y * star.z
      }
      pos = @camera.worldToScreen(pos)
      pos.x = pos.x % @camera.w
      pos.y = pos.y % @camera.h
      if pos.x < 0 then pos.x += @camera.w
      if pos.y < 0 then pos.y += @camera.h
      s = (star.z / (@min_depth - @max_depth)) * 2 + 1
      @_g.beginFill(0xFFFFFF)
      @_g.drawRect(pos.x, pos.y, s, s)
      @_g.endFill()
