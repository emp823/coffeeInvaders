do ->
  class Game
    constructor: (canvasId) ->
      canvas = document.getElementById(canvasId)
      screen = canvas.getContext('2d')
      gameSize = { x: canvas.width, y: canvas.height }

      @bodies = createInvaders(@).concat(new Player(@, gameSize))

      self = @
      tick = ->
        self.update()
        self.draw(screen, gameSize)
        requestAnimationFrame(tick)
      tick()

    update: () ->
      body.update() for body in @bodies

    draw: (screen, gameSize) ->
      screen.clearRect(0, 0, gameSize.x, gameSize.y)
      drawRect(screen, body) for body in @bodies

    addBody: (body) ->
      @bodies.push body

  class Player
    constructor: (@game, gameSize) ->
      @size = { x: 15, y: 15 }
      @center = { x: gameSize.x / 2, y: gameSize.y - @size.x }
      @keyboarder = new Keyboarder

    update: ->
      if @keyboarder.isDown(@keyboarder.KEYS.LEFT)
        @center.x -= 2
      else if @keyboarder.isDown(@keyboarder.KEYS.RIGHT)
        @center.x += 2

      if @keyboarder.isDown(@keyboarder.KEYS.SPACE)
        bullet = new Bullet(
          {x: @center.x, y: @center.y - @size.x - 2},
          {x: 0, y: -6}
        )
        @game.addBody(bullet)

  class Invader
    constructor: (@game, @center) ->
      @size = {x: 15, y: 15}
      @patrolX = 0
      @speedX = 0.3

    update: ->
      if @patrolX < 0 or @patrolX > 40 then @speedX = -@speedX
      @center.x += @speedX
      @patrolX += @speedX

  class Bullet
    constructor: (@center, @velocity) ->
      @size = { x: 3, y: 3 }

    update: ->
      @center.x += @velocity.x
      @center.y += @velocity.y

  class Keyboarder
    constructor: ->
      @keyState = keyState = {}
      window.onkeydown = (e) -> keyState[e.keyCode] = true
      window.onkeyup = (e) -> keyState[e.keyCode] = false

    isDown: (keyCode) -> @keyState[keyCode] is true

    KEYS: { LEFT: 37, RIGHT: 39, SPACE: 32 }

  createInvaders = (game) ->
    (new Invader(
      game,
      {x: 30 + (num % 8) * 30, y: 30 + (num % 3) * 30}
    ) for num in [0..23])

  drawRect = (screen, body) ->
    screen.fillRect(
      body.center.x - body.size.x / 2,
      body.center.y - body.size.y / 2,
      body.size.x,
      body.size.y
    )

  window.onload = ->
    new Game "screen"
