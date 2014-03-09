# CoffeeScript

_canvas = null
_ctx = null;
_width = 700;
_height = 500;
_full_screen = true;

window.onload = () =>
    game_div = $('#game')
    if (_full_screen)
        _width = window.innerWidth
        _height = window.innerHeight

    game_div.width(_width)
    game_div.height(_height)

    main_canvas = $('<canvas>')
    main_canvas.attr('id', 'main-canvas')
    game_div.append(main_canvas)

    _canvas = main_canvas[0]
    _canvas.width = game_div.width()
    _canvas.height = game_div.height()
    _ctx = _canvas.getContext('2d')

    _canvas.addEventListener('mousemove', mousemoveHandler, false)

    loop();

mousemoveHandler = (e) =>
    //if (e.layerX || e.layerX == 0) {
    //    _emitter.p.x = e.layerX;
    //    _emitter.p.y = e.layerY;
    //} else if (e.offsetX || e.offsetX == 0) {
    //    _emitter.p.x = e.offsetX;
    //    _emitter.p.y = e.offsetY;
    //}

loop = () =>
    clear()
    update()
    draw()
    queue()

clear = () =>
    _ctx.clearRect(0, 0, _width, _height)

update = () =>

draw = () =>

queue() =>
    window.requestAnimationFrame(loop)