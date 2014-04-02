
boundedValue = (value, min, max) ->
  v = value - min
  if v < 0
    v = max + v
  else
    v = (v % (max - min)) + min
  return v
