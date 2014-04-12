
boundedValue = (value, min, max) ->
  v = value - min
  if v < 0
    v = max + v
  else
    v = (v % (max - min)) + min
  return v

createCircle = (precision, origin, radius) ->
  angle = 2 * Math.PI / precision
  circleArray = []
  for i in [0...precision]
    v =
      x: origin.x + radius * Math.cos(angle * i)
      y: origin.y + radius * Math.sin(angle * i)
    circleArray.push(v)
  return circleArray

toCapitalCoords = (array) ->
  result = []
  for e in array
    result.push({X: e.x, Y: e.y})
  return result

toLowerCoords = (array) ->
  result = []
  for e in array
    result.push({x: e.X, y: e.Y})
  return result
