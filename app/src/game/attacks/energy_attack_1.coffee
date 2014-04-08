
#_require ./energy_attack

class EnergyAttack1 extends EnergyAttack
  @combo: null

  constructor: (character) ->
    super(character)
    if not EnergyAttack1.combo
      EnergyAttack1.combo = @_generate_combo(3)

  combo: () ->
    return EnergyAttack1.combo

  charge: (time) =>
    p = @character.body.GetPosition()
    console.log("charge energy attack 1 (#{time}) #{p.x}")

  release: () ->
    console.log("release energy attack 1")

  stop: () ->
    console.log("stop energy attack 1")
