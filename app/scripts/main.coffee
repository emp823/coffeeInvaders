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

    draw: (screen, gameSize) ->
      drawRect(screen, body) for body in @bodies

  class Player
    constructor: (@game, gameSize) ->
      @size = { x: 15, y: 15 }
      @center = { x: gameSize.x / 2, y: gameSize.y - @size.x }

    update: ->

  drawRect = (screen, body) ->
    screen.fillRect(
      body.center.x - body.size.x / 2,
      body.center.y - body.size.y / 2,
      body.size.x,
      body.size.y
    )

  Keyboarder = () ->
    keyState = {}
    
    window.onkeydown = (e) ->
      keyState[e.keyCode] = true;
    window.onkeyup = (e) ->
      keyState[e.keyCode] = false;

  window.onload = ->
    new Game "screen"
