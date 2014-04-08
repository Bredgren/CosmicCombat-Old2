
class EnergyAttack
  @KEY_NAMES:
    E1: 0
    E2: 1
    E3: 2
    E4: 3

  @combos: []

  combo: {}

  constructor: (@character) ->

  charge: () ->
    console.log("charge energy attack")

  release: () ->
    console.log("release energy attack")

  stop: () ->
    console.log("stop energy attack")

  # Generates a combo of the given length but will not produce a combo that is
  # already in use.
  _generate_combo: (length) ->
    combo = {}
    combo.keys = []
    combo.keys.push(EnergyAttack.KEY_NAMES.E1)
    combo.keys.push(EnergyAttack.KEY_NAMES.E2)
    combo.keys.push(EnergyAttack.KEY_NAMES.E3)

    EnergyAttack.combos.push(combo)

    return combo