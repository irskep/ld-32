{world3ToWorld2} = require './projection'
{createCanvasSprite} = require './sprites'
{Vector3} = require './geometry'
isInFront = require './isInFront'

sprites = window.sprites = []

spriteRootEl = document.querySelectorAll('#sprite-root')[0]


drawLine = (ctx, originOffset, point3A, point3B) ->
  ctx.beginPath()
  point1 = world3ToWorld2(point3A).add(originOffset)
  point2 = world3ToWorld2(point3B).add(originOffset)
  ctx.moveTo(point1.x, point1.y)
  ctx.lineTo(point2.x, point2.y)
  ctx.stroke()


drawPolygon = (ctx, originOffset, points) ->
  ctx.beginPath()
  firstPoint = world3ToWorld2(_.first(points)).add(originOffset)
  ctx.moveTo(firstPoint.x, firstPoint.y)

  for point3 in _.rest(points)
    point = world3ToWorld2(point3).add(originOffset)
    ctx.lineTo(point.x, point.y)
  ctx.fill()


addSprite = (sprite) ->
  spriteRootEl.appendChild(sprite.el)
  sprites.push sprite


sortSprites = ->
  sprites.sort (a, b) -> if isInFront(a, b) then 1 else -1
  _.each sprites, (s, i) ->
    s.el.style.zIndex = i


getGridSprite = (cellSize, numCells) ->
  length = cellSize * numCells
  p = new Vector3(-length / 2, 0, -length / 2)
  s = new Vector3(length, 0, length)

  createCanvasSprite p, s, ({originOffset, ctx, canvas}) ->
    #canvas.style.border = '1px solid red'
    ctx.strokeStyle = '#aaa'

    x = 0
    while x <= s.x
      drawLine(ctx, originOffset, new Vector3(x, 0, 0), new Vector3(x, 0, s.z))
      x += cellSize

    z = 0
    while z <= s.z
      drawLine(ctx, originOffset, new Vector3(0, 0, z), new Vector3(s.z, 0, z))
      z += cellSize


getBoxSprite = (origin, size) ->
  createCanvasSprite origin, size, ({originOffset, ctx, canvas}) ->
    #canvas.style.border = '1px solid red'
    ctx.strokeStyle = '#afa'
    ctx.strokeWidth = 2

    zero = new Vector3(0, 0, 0)
    centerTopFront = new Vector3(0, size.y, 0)
    centerTopBack = new Vector3(size.x, size.y, size.z)
    bottomX = new Vector3(size.x, 0, 0)
    bottomZ = new Vector3(0, 0, size.z)
    topX = new Vector3(size.x, size.y, 0)
    topZ = new Vector3(0, size.y, size.z)

    ctx.fillStyle = 'black'
    drawPolygon ctx, originOffset, [
      zero, bottomX, topX, centerTopBack, topZ, bottomZ
    ]

    # front 3
    drawLine(ctx, originOffset, zero, centerTopFront)
    drawLine(ctx, originOffset, zero, bottomX)
    drawLine(ctx, originOffset, zero, bottomZ)

    # side legs
    drawLine(ctx, originOffset, bottomX, topX)
    drawLine(ctx, originOffset, bottomZ, topZ)

    # top 2 front
    drawLine(ctx, originOffset, centerTopFront, topX)
    drawLine(ctx, originOffset, centerTopFront, topZ)

    # top 2 back
    drawLine(ctx, originOffset, centerTopBack, topX)
    drawLine(ctx, originOffset, centerTopBack, topZ)


getPlayerSprite = (origin) ->
  size = new Vector3(32, 32, 32)
  createCanvasSprite origin, size, ({originOffset, ctx, canvas}) ->
    #canvas.style.border = '1px solid red'
    ctx.strokeStyle = '#fff'
    ctx.fillStyle = '#444'
    ctx.strokeWidth = 2

    transform = (v) -> world3ToWorld2(v).add(originOffset)

    zero = transform new Vector3(0, 0, 0)
    centerTopFront = transform new Vector3(0, size.y, 0)
    centerTopBack = transform new Vector3(size.x, size.y, size.z)
    bottomX = transform new Vector3(size.x, 0, 0)
    bottomZ = transform new Vector3(0, 0, size.z)
    topX = transform new Vector3(size.x, size.y, 0)
    topZ = transform new Vector3(0, size.y, size.z)

    center = topX.add(topZ).add(bottomX).add(bottomZ).multiply(1/4)
    r = (bottomX.x - bottomZ.x) / 2 * 0.5

    ctx.beginPath()
    ctx.arc(center.x, center.y, r, 0, Math.PI * 2, false)
    ctx.fill()
    ctx.beginPath()
    ctx.arc(center.x, center.y, r, 0, Math.PI * 2, false)
    ctx.stroke()


playerSprite = null
addInitialSprites = ->
  addSprite getGridSprite(32, 16)
  for x in [0..5]
    addSprite getBoxSprite(new Vector3(x * 32, 0, 32), new Vector3(32, 28, 32))

  playerSprite = getPlayerSprite(new Vector3(-32, 0, -32))
  addSprite playerSprite


applySprites = (state, t, dt) ->
  unless sprites.length
    addInitialSprites()

  playerSprite.origin = state.playerPos
  sortSprites()
  for sprite in sprites
    p = world3ToWorld2(sprite.origin)
      .subtract(sprite.originOffset)
      .add(SIZE.multiply(1/2))
      .subtract(state.cameraPos)
    sprite.el.style.webkitTransform = "translate3d(#{p.x}px, #{p.y}px, 0px)"

  state

module.exports = applySprites