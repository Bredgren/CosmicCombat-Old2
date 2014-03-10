# The main script for the game

#_require ./config
#_require ./global
#_require ./debug_draw

# Execute after document is loaded
$ ->
  DOM_LOADED = true
  #main()
  # a = new AttractionDemo()
  # a = new ClothDemo()
  # a = new BalloonDemo()
  # a = new BoundsDemo()
  # a = new ChainDemo()
  a = new CollisionDemo()
  a.init($('body')[0])

  queue = ->
    a.step()
    window.requestAnimationFrame(queue)
  queue()

W = 0
H = 0

# The main method for the game
main = ->
  W = if settings.FULL_SCREEN then window.innerWidth else settings.WIDTH
  H = if settings.FULL_SCREEN then window.innerHeight else settings.HEIGHT

  body = $('body')

  container = $('<div>')
  body.append(container)

  black = 0x000000
  stage = new PIXI.Stage(black)
  renderer = PIXI.autoDetectRenderer(W, H)

  container.append(renderer.view)

  canvas = $('canvas')[0]

  graphics = new PIXI.Graphics()
  stage.addChild(graphics)


  world = new b2Dynamics.b2World(new b2Math.b2Vec2(0, 10), true)
  fixDef = new b2Dynamics.b2FixtureDef()
  fixDef.density = 1.0
  fixDef.friction = 0.5
  fixDef.restitution = 0.2

  bodyDef = new b2Dynamics.b2BodyDef()

  bodyDef.type = b2Dynamics.b2Body.b2_staticBody
  bodyDef.position.x = W / 2 / 30
  bodyDef.position.y = 13
  fixDef.shape = new b2Shapes.b2PolygonShape()
  s = fixDef.shape
  s.SetAsBox(10, 1)
  world.CreateBody(bodyDef).CreateFixture(fixDef)

  bodyDef.type = b2Dynamics.b2Body.b2_dynamicBody
  for i in [0..10]
    if (Math.random() > 0.5)
      fixDef.shape = new b2Shapes.b2PolygonShape()
      fixDef.shape.SetAsBox(Math.random() + 0.1, Math.random() + 0.1)
    else
      fixDef.shape = new b2Collision.Shapes.b2CircleShape(Math.random() + 0.1)
    bodyDef.position.x = Math.random() * 10 + W / 2 / 30 - 5
    bodyDef.position.y = Math.random() * 10
    world.CreateBody(bodyDef).CreateFixture(fixDef)

  if settings.DEBUG
    debugDraw = new DebugDraw()
    debugDraw.SetSprite(graphics)
    debugDraw.SetDrawScale(30.0)
    debugDraw.SetFillAlpha(0.3)
    debugDraw.SetLineThickness(1.0)
    debugDraw.SetFlags(b2Dynamics.b2DebugDraw.e_shapeBit |
      b2Dynamics.b2DebugDraw.e_jointBit)
    world.SetDebugDraw(debugDraw)

  ##############################################################################
  # Set event handlers

  onResize = ->
    console.log("resize")

  keyDownListener = (e) ->
    console.log("key:", e.keyCode)

  # Catch accidental leaving
  onBeforeUnload = (e) ->
    console.log("leaving")

    # if (not e)
    #   e = window.event
    # e.cancelBubble = true
    # if (e.stopPropagation)
    #   e.stopPropagation()
    #   e.preventDefault()
    #   return "Warning: Progress my be lost."
    # return null

  mouseMoveHandler = (e) ->
    x = e.clientX
    y = e.clientY
    console.log("mouse:", x, y)

  clickHandler = (e) ->
    x = e.clientX
    y = e.clientY
    console.log("click:", x, y)

  mouseDownHandler = (e) ->
    console.log("mouse down")

  mouseUpHandler = (e) ->
    console.log("mouse up")

  mouseOutHandler = (e) ->
    console.log("mouse out")

  mouseWheelHandler = (e) ->
    delta = Math.max(-1, Math.min(1, (e.wheelDelta or -e.detail)))
    console.log("mouse wheel: ", delta)

  focusHandler = (e) ->
    console.log("focus")

  blurHandler = (e) ->
    console.log("blur")

  event_catcher = canvas

  window.onresize = onResize
  document.body.addEventListener('keydown', keyDownListener, false)
  window.onbeforeunload = onBeforeUnload
  event_catcher.addEventListener('mousemove', mouseMoveHandler, false)
  event_catcher.addEventListener('click', clickHandler, false)
  event_catcher.addEventListener('mousedown', mouseDownHandler, false)
  event_catcher.addEventListener('mouseup', mouseUpHandler, false)
  event_catcher.addEventListener('mouseout', mouseOutHandler, false)
  event_catcher.addEventListener('DOMMouseScroll', mouseWheelHandler, false)
  event_catcher.addEventListener('mousewheel', mouseWheelHandler, false)
  event_catcher.addEventListener('focus', focusHandler, false)
  event_catcher.addEventListener('blur', blurHandler, false)

  ##############################################################################
  # Game loop

  main_loop = ->
    update()
    clear()
    draw()
    queue()

   update = ->
    world.Step(1 / 60, 10, 10)
    world.ClearForces()

  clear = ->
    graphics.clear()

  draw = ->
    if settings.DEBUG
      world.DrawDebugData()
    renderer.render(stage)

  queue = ->
    window.requestAnimationFrame(main_loop)

  main_loop()

### Base Renderer ###
class Renderer

    constructor: ->

        @width = 0
        @height = 0

        @renderParticles = true
        @renderSprings = true
        @renderMouse = true
        @initialized = false
        @renderTime = 0

    init: (physics) ->

        @initialized = true

    render: (physics) ->

        if not @initialized then @init physics

    setSize: (@width, @height) =>

    destroy: ->

### WebGL Renderer ###

class WebGLRenderer extends Renderer

    # Particle vertex shader source.
    @PARTICLE_VS = '''

        uniform vec2 viewport;
        attribute vec3 position;
        attribute float radius;
        attribute vec4 colour;
        varying vec4 tint;

        void main() {

            // convert the rectangle from pixels to 0.0 to 1.0
            vec2 zeroToOne = position.xy / viewport;
            zeroToOne.y = 1.0 - zeroToOne.y;

            // convert from 0->1 to 0->2
            vec2 zeroToTwo = zeroToOne * 2.0;

            // convert from 0->2 to -1->+1 (clipspace)
            vec2 clipSpace = zeroToTwo - 1.0;

            tint = colour;

            gl_Position = vec4(clipSpace, 0, 1);
            gl_PointSize = radius * 2.0;
        }
    '''

    # Particle fragent shader source.
    @PARTICLE_FS = '''

        precision mediump float;

        uniform sampler2D texture;
        varying vec4 tint;

        void main() {
            gl_FragColor = texture2D(texture, gl_PointCoord) * tint;
        }
    '''

    # Spring vertex shader source.
    @SPRING_VS = '''

        uniform vec2 viewport;
        attribute vec3 position;

        void main() {

            // convert the rectangle from pixels to 0.0 to 1.0
            vec2 zeroToOne = position.xy / viewport;
            zeroToOne.y = 1.0 - zeroToOne.y;

            // convert from 0->1 to 0->2
            vec2 zeroToTwo = zeroToOne * 2.0;

            // convert from 0->2 to -1->+1 (clipspace)
            vec2 clipSpace = zeroToTwo - 1.0;

            gl_Position = vec4(clipSpace, 0, 1);
        }
    '''

    # Spring fragent shader source.
    @SPRING_FS = '''

        void main() {
            gl_FragColor = vec4(1.0, 1.0, 1.0, 0.1);
        }
    '''

    constructor: (@usePointSprites = true) ->

        super

        @particlePositionBuffer = null
        @particleRadiusBuffer = null
        @particleColourBuffer = null
        @particleTexture = null
        @particleShader = null

        @springPositionBuffer = null
        @springShader = null

        @canvas = document.createElement 'canvas'

        # Init WebGL.
        try @gl = @canvas.getContext 'experimental-webgl' catch error
        finally return new CanvasRenderer() if not @gl

        # Set the DOM element.
        @domElement = @canvas

    init: (physics) ->

        super physics

        @initShaders()
        @initBuffers physics

        # Create particle texture from canvas.
        @particleTexture = do @createParticleTextureData

        # Use additive blending.
        @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE

        # Enable the other shit we need from WebGL.
        #@gl.enable @gl.VERTEX_PROGRAM_POINT_SIZE
        #@gl.enable @gl.TEXTURE_2D
        @gl.enable @gl.BLEND

    initShaders: ->

        # Create shaders.
        @particleShader = @createShaderProgram WebGLRenderer.PARTICLE_VS, WebGLRenderer.PARTICLE_FS
        @springShader = @createShaderProgram WebGLRenderer.SPRING_VS, WebGLRenderer.SPRING_FS

        # Store particle shader uniform locations.
        @particleShader.uniforms =
            viewport: @gl.getUniformLocation @particleShader, 'viewport'

        # Store spring shader uniform locations.
        @springShader.uniforms =
            viewport: @gl.getUniformLocation @springShader, 'viewport'

        # Store particle shader attribute locations.
        @particleShader.attributes =
            position: @gl.getAttribLocation @particleShader, 'position'
            radius: @gl.getAttribLocation @particleShader, 'radius'
            colour: @gl.getAttribLocation @particleShader, 'colour'

        # Store spring shader attribute locations.
        @springShader.attributes =
            position: @gl.getAttribLocation @springShader, 'position'

        console.log @particleShader

    initBuffers: (physics) ->

        colours = []
        radii = []

        # Create buffers.
        @particlePositionBuffer = do @gl.createBuffer
        @springPositionBuffer = do @gl.createBuffer
        @particleColourBuffer = do @gl.createBuffer
        @particleRadiusBuffer = do @gl.createBuffer

        # Create attribute arrays.
        for particle in physics.particles

            # Break the colour string into RGBA components.
            rgba = (particle.colour or '#FFFFFF').match(/[\dA-F]{2}/gi)

            # Parse into integers.
            r = (parseInt rgba[0], 16) or 255
            g = (parseInt rgba[1], 16) or 255
            b = (parseInt rgba[2], 16) or 255
            a = (parseInt rgba[3], 16) or 255

            # Prepare for adding to the colour buffer.
            colours.push r / 255, g / 255, b / 255, a / 255

            # Prepare for adding to the radius buffer.
            radii.push particle.radius or 32

        # Init Particle colour buffer.
        @gl.bindBuffer @gl.ARRAY_BUFFER, @particleColourBuffer
        @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(colours), @gl.STATIC_DRAW

        # Init Particle radius buffer.
        @gl.bindBuffer @gl.ARRAY_BUFFER, @particleRadiusBuffer
        @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(radii), @gl.STATIC_DRAW

        ## console.log @particleColourBuffer

    # Creates a generic texture for particles.
    createParticleTextureData: (size = 128) ->

        canvas = document.createElement 'canvas'
        canvas.width = canvas.height = size
        ctx = canvas.getContext '2d'
        rad = size * 0.5

        ctx.beginPath()
        ctx.arc rad, rad, rad, 0, Math.PI * 2, false
        ctx.closePath()

        ctx.fillStyle = '#FFF'
        ctx.fill()

        texture = @gl.createTexture()
        @setupTexture texture, canvas

        texture

    # Creates a WebGL texture from an image path or data.
    loadTexture: (source) ->

        texture = @gl.createTexture()
        texture.image = new Image()

        texture.image.onload = =>

            @setupTexture texture, texture.image

        texture.image.src = source
        texture

    setupTexture: (texture, data) ->

        @gl.bindTexture @gl.TEXTURE_2D, texture
        @gl.texImage2D @gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, data
        @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR
        @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR
        @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE
        @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE
        @gl.generateMipmap @gl.TEXTURE_2D
        @gl.bindTexture @gl.TEXTURE_2D, null

        texture

    # Creates a shader program from vertex and fragment shader sources.
    createShaderProgram: (_vs, _fs) ->

        vs = @gl.createShader @gl.VERTEX_SHADER
        fs = @gl.createShader @gl.FRAGMENT_SHADER

        @gl.shaderSource vs, _vs
        @gl.shaderSource fs, _fs

        @gl.compileShader vs
        @gl.compileShader fs

        if not @gl.getShaderParameter vs, @gl.COMPILE_STATUS
            alert @gl.getShaderInfoLog vs
            null

        if not @gl.getShaderParameter fs, @gl.COMPILE_STATUS
            alert @gl.getShaderInfoLog fs
            null

        prog = do @gl.createProgram

        @gl.attachShader prog, vs
        @gl.attachShader prog, fs
        @gl.linkProgram prog

        ## console.log 'Vertex Shader Compiled', @gl.getShaderParameter vs, @gl.COMPILE_STATUS
        ## console.log 'Fragment Shader Compiled', @gl.getShaderParameter fs, @gl.COMPILE_STATUS
        ## console.log 'Program Linked', @gl.getProgramParameter prog, @gl.LINK_STATUS

        prog

    # Sets the size of the viewport.
    setSize: (@width, @height) =>

        ## console.log 'resize', @width, @height

        super @width, @height

        @canvas.width = @width
        @canvas.height = @height
        @gl.viewport 0, 0, @width, @height

        # Update shader uniforms.
        @gl.useProgram @particleShader
        @gl.uniform2fv @particleShader.uniforms.viewport, new Float32Array [@width, @height]

        # Update shader uniforms.
        @gl.useProgram @springShader
        @gl.uniform2fv @springShader.uniforms.viewport, new Float32Array [@width, @height]

    # Renders the current physics state.
    render: (physics) ->

        super

        # Clear the viewport.
        @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT

        # Draw particles.
        if @renderParticles

            vertices = []

            # Update particle positions.
            for p in physics.particles
                vertices.push p.pos.x, p.pos.y, 0.0

            # Bind the particle texture.
            @gl.activeTexture @gl.TEXTURE0
            @gl.bindTexture @gl.TEXTURE_2D, @particleTexture

            # Use the particle program.
            @gl.useProgram @particleShader

            # Setup vertices.
            @gl.bindBuffer @gl.ARRAY_BUFFER, @particlePositionBuffer
            @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW
            @gl.vertexAttribPointer @particleShader.attributes.position, 3, @gl.FLOAT, false, 0, 0
            @gl.enableVertexAttribArray @particleShader.attributes.position

            # Setup colours.
            @gl.bindBuffer @gl.ARRAY_BUFFER, @particleColourBuffer
            @gl.enableVertexAttribArray @particleShader.attributes.colour
            @gl.vertexAttribPointer @particleShader.attributes.colour, 4, @gl.FLOAT, false, 0, 0

            # Setup radii.
            @gl.bindBuffer @gl.ARRAY_BUFFER, @particleRadiusBuffer
            @gl.enableVertexAttribArray @particleShader.attributes.radius
            @gl.vertexAttribPointer @particleShader.attributes.radius, 1, @gl.FLOAT, false, 0, 0

            # Draw particles.
            @gl.drawArrays @gl.POINTS, 0, vertices.length / 3

        # Draw springs.
        if @renderSprings and physics.springs.length > 0

            vertices = []

            # Update spring positions.
            for s in physics.springs
                vertices.push s.p1.pos.x, s.p1.pos.y, 0.0
                vertices.push s.p2.pos.x, s.p2.pos.y, 0.0

            # Use the spring program.
            @gl.useProgram @springShader

            # Setup vertices.
            @gl.bindBuffer @gl.ARRAY_BUFFER, @springPositionBuffer
            @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW
            @gl.vertexAttribPointer @springShader.attributes.position, 3, @gl.FLOAT, false, 0, 0
            @gl.enableVertexAttribArray @springShader.attributes.position

            # Draw springs.
            @gl.drawArrays @gl.LINES, 0, vertices.length / 3

    destroy: ->

        ## console.log 'Destroy'
### Demo ###
class Demo

	@COLOURS = ['DC0048', 'F14646', '4AE6A9', '7CFF3F', '4EC9D9', 'E4272E']

	constructor: ->

		@physics = new Physics()
		@mouse = new Particle()
		@mouse.fixed = true
		@height = window.innerHeight
		@width = window.innerWidth

		@renderTime = 0
		@counter = 0

	setup: (full = yes) ->

		### Override and add paticles / springs here ###

	### Initialise the demo (override). ###
	init: (@container, @renderer = new WebGLRenderer()) ->

		# Build the scene.
		@setup @renderer.gl?

		# Give the particles random colours.
		for particle in @physics.particles
			particle.colour ?= Random.item Demo.COLOURS

		# Add event handlers.
		document.addEventListener 'touchmove', @mousemove, false
		document.addEventListener 'mousemove', @mousemove, false
		document.addEventListener 'resize', @resize, false

		# Add to render output to the DOM.
		@container.appendChild @renderer.domElement

		# Prepare the renderer.
		@renderer.mouse = @mouse
		@renderer.init @physics

		# Resize for the sake of the renderer.
		do @resize

	### Handler for window resize event. ###
	resize: (event) =>

		@width = window.innerWidth
		@height = window.innerHeight
		@renderer.setSize @width, @height

	### Update loop. ###
	step: ->

		#console.profile 'physics'

		# Step physics.
		do @physics.step

		#console.profileEnd()

		#console.profile 'render'

		# Render.

		# Render every frame for WebGL, or every 3 frames for canvas.
		@renderer.render @physics if @renderer.gl? or ++@counter % 3 is 0

		#console.profileEnd()

	### Clean up after yourself. ###
	destroy: ->

		## console.log @, 'destroy'

		# Remove event handlers.
		document.removeEventListener 'touchmove', @mousemove, false
		document.removeEventListener 'mousemove', @mousemove, false
		document.removeEventListener 'resize', @resize, false

		# Remove the render output from the DOM.
		try container.removeChild @renderer.domElement
		catch error

		do @renderer.destroy
		do @physics.destroy

		@renderer = null
		@physics = null
		@mouse = null

	### Handler for window mousemove event. ###
	mousemove: (event) =>

		do event.preventDefault

		if event.touches and !!event.touches.length

			touch = event.touches[0]
			@mouse.pos.set touch.pageX, touch.pageY

		else

			@mouse.pos.set event.clientX, event.clientY

class AttractionDemo extends Demo
  setup: (full = yes) ->
    super full

    min = new Vector 0.0, 0.0
    max = new Vector @width, @height

    bounds = new EdgeBounce min, max
    @physics.integrator = new Verlet()

    attraction = new Attraction @mouse.pos, 1200, 1200
    repulsion = new Attraction @mouse.pos, 200, -2000
    #collide = new Collision()

    max = if full then 400 else 200
    for i in [0..max]

      p = new Particle (Random 0.1, 3.0)
      p.setRadius p.mass * 4

      p.moveTo new Vector (Random @width), (Random @height)

      p.behaviours.push attraction
      p.behaviours.push repulsion
      p.behaviours.push bounds
      #p.behaviours.push collide

      #collide.pool.push p

      @physics.particles.push p

class ClothDemo extends Demo

	setup: (full = yes) ->

		super

		# Only render springs.
		@renderer.renderParticles = false

		@physics.integrator = new Verlet()
		@physics.timestep = 1.0 / 200
		@mouse.setMass 10

		# Add gravity to the simulation.
		@gravity = new ConstantForce new Vector 0.0, 80.0
		@physics.behaviours.push @gravity

		stiffness = 0.5
		size = if full then 8 else 10
		rows = if full then 30 else 25
		cols = if full then 55 else 40
		cell = []

		sx = @width * 0.5 - cols * size * 0.5
		sy = @height * 0.5 - rows * size * 0.5

		for x in [0..cols]

			cell[x] = []

			for y in [0..rows]

				p = new Particle(0.1)

				p.fixed = (y is 0)

				# Always set initial position using moveTo for Verlet
				p.moveTo new Vector (sx + x * size), (sy + y * size)

				if x > 0
					s = new Spring p, cell[x-1][y], size, stiffness
					@physics.springs.push s

				if y > 0
					s = new Spring p, cell[x][y - 1], size, stiffness
					@physics.springs.push s

				@physics.particles.push p
				cell[x][y] = p

		p = cell[Math.floor cols / 2][Math.floor rows / 2]
		s = new Spring @mouse, p, 10, 1.0
		@physics.springs.push s

		cell[0][0].fixed = true
		cell[cols - 1][0].fixed = true

	step: ->

		super

		@gravity.force.x = 50 * Math.sin new Date().getTime() * 0.0005

### BalloonDemo ###
class BalloonDemo extends Demo

	setup: (full = yes) ->

		super

		@physics.integrator = new ImprovedEuler()
		attraction = new Attraction @mouse.pos

		max = if full then 400 else 200

		for i in [0..max]

			p = new Particle (Random 0.25, 4.0)
			p.setRadius p.mass * 8

			p.behaviours.push new Wander 0.2
			p.behaviours.push attraction

			p.moveTo new Vector (Random @width), (Random @height)

			s = new Spring @mouse, p, (Random 30, 300), 1.0

			@physics.particles.push p
			@physics.springs.push s

### BoundsDemo ###
class BoundsDemo extends Demo

	setup: ->

		super

		min = new Vector 0.0, 0.0
		max = new Vector @width, @height

		edge = new EdgeWrap min, max

		for i in [0..200]

			p = new Particle (Random 0.5, 4.0)
			p.setRadius p.mass * 5

			p.moveTo new Vector (Random @width), (Random @height)

			p.behaviours.push new Wander 0.2, 120, Random 1.0, 2.0
			p.behaviours.push edge

			@physics.particles.push p

class ChainDemo extends Demo

	setup: (full = yes) ->

		super

		@stiffness = 1.0
		@spacing = 2.0

		@physics.integrator = new Verlet()
		@physics.viscosity = 0.0001
		@mouse.setMass 1000

		gap = 50.0
		min = new Vector -gap, -gap
		max = new Vector @width + gap, @height + gap

		edge = new EdgeBounce min, max

		center = new Vector @width * 0.5, @height * 0.5

		#@renderer.renderParticles = no

		wander = new Wander 0.05, 100.0, 80.0

		max = if full then 2000 else 600

		for i in [0..max]

			p = new Particle 6.0
			p.colour = '#FFFFFF'
			p.moveTo center
			p.setRadius 1.0

			p.behaviours.push wander
			p.behaviours.push edge

			@physics.particles.push p

			if op? then s = new Spring op, p, @spacing, @stiffness
			else s = new Spring @mouse, p, @spacing, @stiffness

			@physics.springs.push s

			op = p

		@physics.springs.push new Spring @mouse, p, @spacing, @stiffness

### CollisionDemo ###
class CollisionDemo extends Demo

    setup: (full = yes) ->

        super

        # Verlet gives us collision responce for free!
        @physics.integrator = new Verlet()

        min = new Vector 0.0, 0.0
        max = new Vector @width, @height

        bounds = new EdgeBounce min, max
        collide = new Collision
        attraction = new Attraction @mouse.pos, 2000, 1400

        max = if full then 350 else 150
        prob = if full then 0.35 else 0.5

        for i in [0..max]

            p = new Particle (Random 0.5, 4.0)
            p.setRadius p.mass * 4

            p.moveTo new Vector (Random @width), (Random @height)

            # Connect to spring or move free.
            if Random.bool prob
                s = new Spring @mouse, p, (Random 120, 180), 0.8
                @physics.springs.push s
            else
                p.behaviours.push attraction

            # Add particle to collision pool.
            collide.pool.push p

            # Allow particle to collide.
            p.behaviours.push collide
            p.behaviours.push bounds

            @physics.particles.push p

    onCollision: (p1, p2) =>

        # Respond to collision.