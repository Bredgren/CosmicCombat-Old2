///<reference path="./jquery.d.ts"/>
///<reference path="./proton-1.0.0.d.ts"/>
///<reference path="./box2dweb.d.ts"/>
///<reference path="./clipper.d.ts"/>
var b2Common = Box2D.Common;
var b2Math = Box2D.Common.Math;
var b2Collision = Box2D.Collision;
var b2Shapes = Box2D.Collision.Shapes;
var b2Dynamics = Box2D.Dynamics;
var b2Contacts = Box2D.Dynamics.Contacts;
var b2Controllers = Box2D.Dynamics.Controllers;
var b2Joints = Box2D.Dynamics.Joints;

var _canvas;
var _ctx;
var _world;
var _emitter;
var _width = 700;
var _height = 500;
var _full_screen = true;

var _body;

var _proton;

window.onload = function () {
    var game_div = $('#game');
    if (_full_screen) {
        _width = window.innerWidth;
        _height = window.innerHeight;
    }
    game_div.width(_width);
    game_div.height(_height);

    var main_canvas = $('<canvas>');
    main_canvas.attr('id', 'main-canvas');
    game_div.append(main_canvas);

    _canvas = main_canvas[0];
    _canvas.width = game_div.width();
    _canvas.height = game_div.height();
    _ctx = _canvas.getContext('2d');

    _canvas.addEventListener('mousemove', mousemoveHandler, false);

    //var x = [1, 2, 3];
    //var y = Array(1, 2, 3);
    //var ground: ClipperLib.Paths = [[{ X: 0, Y: 0 }, { X: 10, Y: 0 }, { X: 10, Y: 1 }, { X: 0, Y: 1 }]];
    //var clip: ClipperLib.Paths = [[{ X: 5, Y: -0.2 }, { X: 7, Y: -0.2 }, { X: 7, Y: 0.2 }, { X: 5, Y: 0.2 }]];
    //var cpr = new ClipperLib.Clipper();
    //cpr.AddPaths(ground, ClipperLib.PolyType.ptSubject, true);
    //cpr.AddPaths(clip, ClipperLib.PolyType.ptClip, true);
    //var ground_fillType = ClipperLib.PolyFillType.pftNonZero;
    //var clip_fillType = ClipperLib.PolyFillType.pftNonZero;
    //var clipType = ClipperLib.ClipType.ctDifference;
    //var solution_path = new ClipperLib.Paths();
    //cpr.Execute(clipTypes[i], solution_paths, subject_fillType, clip_fillType);
    //var x = new Array();
    _world = new b2Dynamics.b2World(new b2Common.Math.b2Vec2(0, 10), true);
    var fixDef = new b2Dynamics.b2FixtureDef;
    fixDef.density = 1.0;
    fixDef.friction = 0.5;
    fixDef.restitution = 0.2;

    var bodyDef = new b2Dynamics.b2BodyDef;

    bodyDef.type = b2Dynamics.b2Body.b2_staticBody;
    bodyDef.position.x = 9;
    bodyDef.position.y = 13;
    fixDef.shape = new b2Collision.Shapes.b2PolygonShape;
    var s = fixDef.shape;
    s.SetAsBox(10, 1);
    _world.CreateBody(bodyDef).CreateFixture(fixDef);
    console.log(s.GetVertices());

    bodyDef.type = b2Dynamics.b2Body.b2_dynamicBody;
    for (var i = 0; i < 10; i++) {
        if (Math.random() > 0.5) {
            fixDef.shape = new b2Collision.Shapes.b2PolygonShape;
            fixDef.shape.SetAsBox(Math.random() + 0.1, Math.random() + 0.1);
        } else {
            fixDef.shape = new b2Collision.Shapes.b2CircleShape(Math.random() + 0.1);
        }
        bodyDef.position.x = Math.random() * 10;
        bodyDef.position.y = Math.random() * 10;
        _body = _world.CreateBody(bodyDef);
        _body.CreateFixture(fixDef);
    }

    var debugDraw = new b2Dynamics.b2DebugDraw();
    debugDraw.SetSprite(_ctx);
    debugDraw.SetDrawScale(30.0);
    debugDraw.SetFillAlpha(0.3);
    debugDraw.SetLineThickness(1.0);
    debugDraw.SetFlags(b2Dynamics.b2DebugDraw.e_shapeBit | b2Dynamics.b2DebugDraw.e_jointBit);
    _world.SetDebugDraw(debugDraw);

    _proton = new Proton();
    _emitter = new Proton.Emitter();

    //set Rate
    _emitter.rate = new Proton.Rate(Proton.getSpan(10, 20), 0.1);

    //add Initialize
    _emitter.addInitialize(new Proton.Radius(1, 12));
    _emitter.addInitialize(new Proton.Life(2, 4));
    _emitter.addInitialize(new Proton.Velocity(3, Proton.getSpan(0, 360), 'polar'));

    //add Behaviour
    _emitter.addBehaviour(new Proton.Color('ff0000', 'random'));
    _emitter.addBehaviour(new Proton.Alpha(1, 0));

    //set emitter position
    _emitter.p.x = _canvas.width / 2;
    _emitter.p.y = _canvas.height / 2;
    _emitter.emit();

    //add emitter to the proton
    _proton.addEmitter(_emitter);

    // add canvas renderer
    var renderer = new Proton.Renderer('canvas', _proton, _canvas);
    renderer.start();

    loop();
};

function mousemoveHandler(e) {
    //if (e.layerX || e.layerX == 0) {
    //    _emitter.p.x = e.layerX;
    //    _emitter.p.y = e.layerY;
    //} else if (e.offsetX || e.offsetX == 0) {
    //    _emitter.p.x = e.offsetX;
    //    _emitter.p.y = e.offsetY;
    //}
}

function loop() {
    clear();
    update();
    draw();
    queue();
}

function clear() {
    _ctx.clearRect(0, 0, _width, _height);
}

function update() {
    _world.Step(1 / 60, 10, 10);
    _world.ClearForces();

    _emitter.p.x = _body.GetPosition().x * 30;
    _emitter.p.y = _body.GetPosition().y * 30;
}

function draw() {
    _world.DrawDebugData();
    _proton.update();
}

function queue() {
    window.requestAnimationFrame(loop);
}
//# sourceMappingURL=app_old.js.map
