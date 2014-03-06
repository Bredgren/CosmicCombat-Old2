///<reference path="./jquery.d.ts"/>
///<reference path="./proton-1.0.0.d.ts"/>
//class Greeter {
//    element: HTMLElement;
//    span: HTMLElement;
//    timerToken: number;
//    constructor(element: HTMLElement) {
//        this.element = element;
//        this.element.innerHTML += "The time is: ";
//        this.span = document.createElement('span');
//        this.element.appendChild(this.span);
//        this.span.innerText = new Date().toUTCString();
//    }
//    start() {
//        this.timerToken = setInterval(() => this.span.innerHTML = new Date().toUTCString(), 500);
//    }
//    stop() {
//        clearTimeout(this.timerToken);
//    }
//}
//window.onload = () => {
//    var el = document.getElementById('content');
//    var greeter = new Greeter(el);
//    greeter.start();
//};
//declare function Proton(proParticleCount?, integrationType?): Proton;
var _canvas;
var _ctx;
var _emitter;
var _width = 700;
var _height = 500;
var _full_screen = true;

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
    if (e.layerX || e.layerX == 0) {
        _emitter.p.x = e.layerX;
        _emitter.p.y = e.layerY;
    } else if (e.offsetX || e.offsetX == 0) {
        _emitter.p.x = e.offsetX;
        _emitter.p.y = e.offsetY;
    }
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
    _proton.update();
}

function draw() {
}

function queue() {
    window.requestAnimationFrame(loop);
}
//# sourceMappingURL=app.js.map
