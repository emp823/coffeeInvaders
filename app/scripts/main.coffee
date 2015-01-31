do ->
  class Game
    constructor: (canvasId) ->
      canvas = document.getElementById(canvasId)
      screen = canvas.getContext('2d')
      gameSize = { x: canvas.width, y: canvas.height }
      self = @
      tick = ->
        self.update()
        self.draw(screen, gameSize)
        requestAnimationFrame(tick)
      tick()

    update: () ->
      console.log "HI"

    draw: () ->

  window.onload = ->
    new Game "screen"
