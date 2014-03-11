
# Particle:
#   pos:
#     x: number
#     y: number
#   vel:
#     x: number
#     y: number
#   acl:
#     x: number
#     y: number
#   life: number

# Emitter:
#   pos:
#     x: number
#     y: number
#   rate: number
#   active: boolean
#   particle_fn:() -> Particle - function that creates a new Particle

# Field:
#   pos:
#     x: number
#     y: number
#   strength: number

class ParticleSystem
  #
  # update_fn = (Particle, {x:, y}) -> void  - second param is accel from fields
  # draw_fn = (Particle) -> void
  constructor: (@max_particles, @update_fn, @draw_fn) ->
    @particles = []
    @emitters = []
    @fields = []

  # Updates each particle, and adds new particles. Automatically handles aging
  # and destroying particles.
  update: () ->
    @_emit(e) for e in @emitters
    @_updateParticle(p) for p in @particles

  draw: () ->
    @draw_fn(p) for p in @particles

  addEmitter: (emitter) ->
    @emitters.push(emitter)

  addField: (field) ->
    @fields.push(field)

  removeEmitter: (emitter) ->
    @emitters = @emitters.filter((e) -> e isnt emitter)

  removeField: (field) ->
    @fields = @fields.filter((f) -> f isnt field)

  _addParticle: (particle) ->
    # TODO replace old ones?
    if @particles.length < @max_particles
      @particles.push(particle)

  _emit: (e) ->
    if not e.active then return
    for i in [0..e.rate]
      @_addParticle(e.particle_fn())

  _updateParticle: (p) ->
    field_acl = {x: 0, y: 0}
    for f in @fields
      dir_x = f.pos.x - p.pos.x
      dir_y = f.pos.y - p.pos.y
      force = f.strength / Math.pow(dir_x * dir_x + dir_y * dir_y, 1.5)
      field_acl.x += dir_x * force
      field_acl.y += dir_y * force

    @update_fn(p, field_acl)
    p.life--
    # TODO find better way to remove, or fake removing with a buffer
    if p.life <= 0
      @particles = @particles.filter((par)-> par isnt p)

# class Emitter
#   #
#   # position [{x, y}]
#   # rate [number]
#   # particle_fn [() -> Particle] function that creates a new Particle
#   constructor: (@position, @rate, @particle_fn) ->
#     @active = true

#   emit: (system) ->
#     if not @active then return
#     for i in [0..@rate]
#       system.addParticle(@particle_fn())

# class Field
#   constructor: (@position, @strength) ->