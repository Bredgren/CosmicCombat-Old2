
#_require ../../global
#_require ../../config

class Character
  constructor: (@universe) ->
    @stand = PIXI.Sprite.fromFrame("jackie_stand_01")
    # @stand.position.x = 32
    # @stand.position.y = 64
    @stand.anchor.x = .5
    @stand.anchor.y = .5
    @universe.game.stage.addChild(@stand)

    bodyDef = new b2Dynamics.b2BodyDef()
    bodyDef.type = b2Dynamics.b2Body.b2_dynamicBody
    bodyDef.position.x = -8
    bodyDef.position.y = -10

    fixDef = new b2Dynamics.b2FixtureDef()
    fixDef.density = 1.0
    fixDef.friction = 0.5
    fixDef.restitution = 0.2
    # fixDef.shape = new b2Shapes.b2CircleShape(.8)
    fixDef.shape = new b2Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(.7, .8)

    @body = @universe._world.CreateBody(bodyDef)
    @body.CreateFixture(fixDef)

  update: () ->
    pos = @body.GetPosition()
    pos = {x: pos.x * settings.PPM, y: pos.y * settings.PPM}
    pos = @universe.game.camera.worldToScreen(pos)
    @stand.position.x = pos.x
    @stand.position.y = pos.y

  draw: () ->