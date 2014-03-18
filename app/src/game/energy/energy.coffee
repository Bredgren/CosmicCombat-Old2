
# max >= current >= strength >= 0
class Energy

  constructor: (@_max) ->
    @_current = @_max
    @_strength = @_max

  # Increase strength but not past current.
  # Returns the amount strength increased by.
  incStrength: (amount) ->
    if amount < 0 then return -@decStrength(-amount)
    prev = @_strength
    @_strength = Math.min(@_strength + amount, @_current)
    return @_strength - prev

  # Decrease strength but not past 0.
  # Returns the amount strength decreased by.
  decStrength: (amount) ->
    if amount < 0 then return -@incStrength(-amount)
    prev = @_strength
    @_strength = Math.max(@_strength - amount, 0)
    return prev - @_strength

  # Sets strength to the given value, but not more that current.
  # Returns the amount strength changed by.
  setStrength: (value) ->
    dif = value - @_strength
    @incStrength(dif)

  # Increase current but not past max.
  # Returns the amount current increased by.
  incCurrent: (amount) ->
    if amount < 0 then return -@decCurrent(-amount)
    prev = @_current
    @_current = Math.min(@_current + amount, @_max)
    return @_current - prev

  # Decrease current but not past 0. Auto decreases strength if necessary.
  # Returns the amount current decreased by.
  decCurrent: (amount) ->
    if amount < 0 then return -@incCurrent(-amount)
    prev = @_current
    @_current = Math.max(@_current - amount, 0)
    if @_strength > @_current then @_strength = @_current
    return prev - @_current

  # Sets current to the given value, changing strength if necessary.
  # Returns the amount current changed by.
  setCurrent: (value) ->
    dif = value - @_current
    @incCurrent(dif)

  # Increases max.
  # Returns the amount max increased by.
  incMax: (amount) ->
    if amount < 0 then return -@decMax(-amount)
    @_max += amount
    return amount

  # Decreases max but not past 0. Auto decreases the other levels if necessary.
  # Returns the amount max decreased by.
  decMax: (amount) ->
    if amount < 0 then return -@incMax(-amount)
    prev = @_max
    @_max = Math.max(@_max - amount, 0)
    if @_current > @_max then @_current = @_max
    if @_strength > @_current then @_strength = @_current
    return prev - @_max

  # Sets max to the given value, changing the other levels if necessary.
  # Returns the amount current changed by.
  setMax: (value) ->
    dif = value - @_max
    @incMax(dif)
