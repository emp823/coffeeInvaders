do ->
  class Game
    constructor: (canvasId) ->
      @canvas = document.getElementById(canvasId)
      @screen = @canvas.getContext('2d')
      @gameSize = { x: @canvas.width, y: @canvas.height }
      @bodies = []
      @shootSound = document.getElementById('shoot-sound')
      @score = 0
      @gameState = 'start'
      @player = null

      @initScreens()

    initScreens: ->
      document.getElementById('start-button').onclick = =>
        @startGame()

      document.getElementById('restart-button').onclick = =>
        @startGame()

    startGame: ->
      @score = 0
      @bodies = createInvaders(@).concat(@player = new Player(@, @gameSize))
      @gameState = 'playing'
      @showScreen('screen')
      @tick()

    endGame: ->
      @gameState = 'gameover'
      document.getElementById('final-score').innerText = "Score: #{@score}"
      @showScreen('end-screen')

    showScreen: (screenId) ->
      document.getElementById('start-screen').style.display = 'none'
      document.getElementById('screen').style.display = 'none'
      document.getElementById('end-screen').style.display = 'none'
      document.getElementById(screenId).style.display = 'block'

    tick: =>
      if @gameState == 'playing'
        @update()
        @draw(@screen, @gameSize)
        requestAnimationFrame(@tick)

    update: ->
      bodies = @bodies
      notColliding = (b1) -> bodies.filter((b2) -> colliding(b1, b2)).length == 0
      inPlay = (b1) -> b1.center.y > 0 and b1.center.y < 300

      @bodies = bodies.filter(notColliding).filter(inPlay)
      for body in @bodies
        body.update()

      for body in bodies
        if body instanceof Invader and not notColliding(body)
          @score += 10

      if not @bodies.includes(@player)
        @endGame()

    draw: (screen, gameSize) ->
      screen.clearRect(0, 0, gameSize.x, gameSize.y)
      for body in @bodies
        drawRect(screen, body)
      @drawScore(screen)

    drawScore: (screen) ->
      screen.fillStyle = 'black'
      screen.font = '20px Arial'
      screen.fillText('Score: ' + @score, 10, 20)

    addBody: (body) ->
      @bodies.push body

    invadersBelow: (invader) ->
      @bodies.filter((b) ->
        b instanceof Invader and
        Math.abs(invader.center.x - b.center.x) < b.size.x and
        b.center.y > invader.center.y
      ).length > 0

  class Player
    constructor: (@game, gameSize) ->
      @size = { x: 15, y: 15 }
      @center = { x: gameSize.x / 2, y: gameSize.y - @size.x }
      @keyboarder = new Keyboarder
      @color = 'black'
      @canShoot = true

    update: ->
      if @keyboarder.isDown(@keyboarder.KEYS.LEFT)
        @center.x -= 2
      else if @keyboarder.isDown(@keyboarder.KEYS.RIGHT)
        @center.x += 2

      if @keyboarder.isDown(@keyboarder.KEYS.SPACE) and @canShoot
        @shoot()
        @canShoot = false
      if @keyboarder.isUp(@keyboarder.KEYS.SPACE)
        @canShoot = true

      for bullet in @game.bodies when bullet instanceof InvaderBullet
        if colliding(bullet, this)
          @game.bodies = @game.bodies.filter((b) -> b != this)

    shoot: ->
      bullet = new Bullet(
        {x: @center.x, y: @center.y - @size.x - 2},
        {x: 0, y: -6}
      )
      @game.addBody(bullet)
      @game.shootSound.load()
      @game.shootSound.play()

  class Invader
    constructor: (@game, @center) ->
      @size = {x: 15, y: 15}
      @patrolX = 0
      @speedX = 0.3
      @color = 'black'

    update: ->
      if @patrolX < 0 or @patrolX > 40 then @speedX = -@speedX
      @center.x += @speedX
      @patrolX += @speedX

      if Math.random() > 0.995 and not @game.invadersBelow(@)
        bullet = new InvaderBullet(
          {x: @center.x, y: @center.y + @size.x - 2},
          {x: Math.random() - 0.5, y: 2}
        )
        @game.addBody(bullet)

  class Bullet
    constructor: (center, velocity) ->
      @center = center
      @velocity = velocity
      @size = { x: 3, y: 3 }
      @color = 'red'

    update: ->
      @center.x += @velocity.x
      @center.y += @velocity.y

  class InvaderBullet extends Bullet
    constructor: (center, velocity) ->
      super(center, velocity)
      @color = 'green'

  class Keyboarder
    constructor: ->
      @keyState = {}
      window.onkeydown = (e) => @keyState[e.keyCode] = true
      window.onkeyup = (e) => @keyState[e.keyCode] = false

    isDown: (keyCode) -> @keyState[keyCode] == true
    isUp: (keyCode) -> @keyState[keyCode] == false

    KEYS: { LEFT: 37, RIGHT: 39, SPACE: 32 }

  createInvaders = (game) ->
    (new Invader(game, {x: 30 + (num % 8) * 30, y: 30 + (num % 3) * 30}) for num in [0..23])

  colliding = (b1, b2) ->
    not (b1 == b2 or
      b1.center.x + b1.size.x / 2 <= b2.center.x - b2.size.x / 2 or
      b1.center.y + b1.size.y / 2 <= b2.center.y - b2.size.y / 2 or
      b1.center.x - b1.size.x / 2 >= b2.center.x + b2.size.x / 2 or
      b1.center.y - b1.size.y / 2 >= b2.center.y + b2.size.y / 2)

  drawRect = (screen, body) ->
    screen.fillStyle = body.color
    screen.fillRect(
      body.center.x - body.size.x / 2,
      body.center.y - body.size.y / 2,
      body.size.x,
      body.size.y
    )

  loadSound = (url, callback) ->
    loaded = ->
      callback(sound)
      sound.removeEventListener('canplaythrough', loaded)

    sound = new Audio(url)
    sound.addEventListener('canplaythrough', loaded)
    sound.load()

  window.onload = ->
    game = new Game "screen"
    game.showScreen('start-screen')
