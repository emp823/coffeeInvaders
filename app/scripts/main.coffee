do ->
  class Game
    constructor: (canvasId) ->
      canvas = document.getElementById(canvasId)
      screen = canvas.getContext('2d')
      gameSize = { x: canvas.width, y: canvas.height }

      @bodies = [new Player(@, gameSize)]

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

  class Keyboarder
    constructor: ->
      keyState = {}

      window.onkeydown = (e) ->
        keyState[e.keyCode] = true;
      window.onkeyup = (e) ->
        keyState[e.keyCode] = false;

      @isDown = (keyCode) ->
        keyState[keyCode] is true

      @KEYS = { LEFT: 37, RIGHT: 39, SPACE: 32 }

  drawRect = (screen, body) ->
    screen.fillRect(
      body.center.x - body.size.x / 2,
      body.center.y - body.size.y / 2,
      body.size.x,
      body.size.y
    )

  window.onload = ->
    new Game "screen"
