
#_require global

class DebugDraw extends b2Dynamics.b2DebugDraw

  constructor: () ->
    @_line_width = 1
    @_alpha = 0.5
    @_fill_alpha = 0.5
    @_scale = 1.0
    @m_sprite = {graphics: {clear: () -> }}

  SetSprite: (@_graphics) ->

  GetSprite: () ->
    return @_graphics

  DrawCircle: (center, radius, color) ->
    @_graphics.alpha = @_alpha
    @_graphics.lineStyle(@_line_width, color.color)
    @_graphics.drawCircle(center.x * @_scale, center.y * @_scale,
                        radius * @_scale)

  DrawPolygon: (vertices, vertexCount, color) ->
    @_graphics.lineStyle(@_line_width, color.color)
    @_graphics.alpha = @_alpha
    v0 = vertices[0]
    @_graphics.moveTo(v0.x * @_scale, v0.y * @_scale)
    for v in vertices[1..]
      @_graphics.lineTo(v.x * @_scale, v.y * @_scale)
    @_graphics.lineTo(v0.x * @_scale, v0.y * @_scale)

  DrawSegment: (p1, p2, color) ->
    @_graphics.lineStyle(@_line_width, color.color)
    @_graphics.alpha = @_alpha
    @_graphics.moveTo(p1.x * @_scale, p1.y * @_scale)
    @_graphics.lineTo(p2.x * @_scale, p2.y * @_scale)

  DrawSolidCircle: (center, radius, axis, color) ->
    @_graphics.beginFill(color.color)
    @_graphics.fillAlpha = @_fill_alpha
    @DrawCircle(center, radius, color)
    @_graphics.endFill()

    axis.Normalize()
    axis.Multiply(radius)
    edge = center.Copy()
    edge.Add(axis)
    @DrawSegment(center, edge, color)

  DrawSolidPolygon: (vertices, vertexCount, color) ->
    @_graphics.beginFill(color.color)
    @_graphics.fillAlpha = @_fill_alpha
    @DrawPolygon(vertices, vertexCount, color)
    @_graphics.endFill()

  GetAlpha: () ->
    return @_alpha

  GetDrawScale: () ->
    return @_scale

  GetFillAlpha: () ->
    return @_fill_alpha

  GetLineThickness: () ->
    return @_line_width

  SetAlpha: (@_alpha) ->

  SetDrawScale: (@_scale) ->

  SetLineThickness: (@_line_width) ->
