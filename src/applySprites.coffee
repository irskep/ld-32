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


drawCircleFill = (ctx, originOffset, center, radius) ->
  center2 = world3ToWorld2(center).add(originOffset)
  ctx.beginPath()
  ctx.arc(center2.x, center2.y, radius, 0, Math.PI * 2, false)
  ctx.fill()

drawCircleStroke = (ctx, originOffset, center, radius) ->
  center2 = world3ToWorld2(center).add(originOffset)
  ctx.beginPath()
  ctx.arc(center2.x, center2.y, radius, 0, Math.PI * 2, false)
  ctx.stroke()


addSprite = (sprite) ->
  spriteRootEl.appendChild(sprite.el)
  sprites.push sprite


sortSprites = ->
  sprites.sort (a, b) -> if isInFront(a, b) then 1 else -1
  _.each sprites, (s, i) ->
    s.el.style.zIndex = i


getCircleVector = (axis1, axis2, radius, angle) ->
  v = new Vector3(0, 0, 0)
  v[axis1] = Math.cos(angle) * radius
  v[axis2] = Math.sin(angle) * radius
  v


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


getJoint = (t, size, onAxis, offAxis, [onAxisFraction, offAxisFraction]) ->
  pos = new Vector3(0, size.y / 4, 0)
  pos[onAxis] = size[onAxis] * onAxisFraction
  pos[offAxis] = size[offAxis] * offAxisFraction
  pos


getKnee = (t, size, onAxis, offAxis, isReversed, isMoving, [onAxisFraction, offAxisFraction, circleOffset]) ->
  period = 200
  pos = new Vector3(0, size.y / 2, 0)
  pos[onAxis] = size[onAxis] * onAxisFraction
  pos[offAxis] = size[offAxis] * offAxisFraction
  progress = (t % period) / period
  angle = Math.PI * 2 * progress + Math.PI * 2 * circleOffset
  if isReversed then angle *= -1
  if isMoving then pos.add getCircleVector(onAxis, 'y', 1, angle) else pos


getFoot = (t, size, onAxis, offAxis, isReversed, isMoving, [onAxisFraction, offAxisFraction, circleOffset]) ->
  period = 200
  pos = new Vector3(0, 2, 0)
  pos[onAxis] = size[onAxis] * onAxisFraction
  pos[offAxis] = size[offAxis] * offAxisFraction
  progress = (t % period) / period
  angle = Math.PI * 2 * progress + Math.PI * 2 * circleOffset
  if isReversed then angle *= -1
  if isMoving then pos.add getCircleVector(onAxis, 'y', 2, angle) else pos


getPlayerSprite = (origin) ->
  size = new Vector3(32, 32, 32)
  createCanvasSprite origin, size, ({originOffset, ctx, canvas, t, state}) ->
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    #canvas.style.border = '1px solid red'
    ctx.strokeStyle = '#fff'
    ctx.fillStyle = '#444'

    zero = new Vector3(0, 0, 0)
    centerTopFront = new Vector3(0, size.y, 0)
    centerTopBack = new Vector3(size.x, size.y, size.z)
    bottomX = new Vector3(size.x, 0, 0)
    bottomZ = new Vector3(0, 0, size.z)
    topX = new Vector3(size.x, size.y, 0)
    topZ = new Vector3(0, size.y, size.z)

    middle = topX.add(topZ).add(bottomX).add(bottomZ).multiply(1/4)

    isMoving = !!state?.isPlayerMoving
    onAxis = null
    offAxis = null
    if state?.playerDirection?.x
      [onAxis, offAxis] = ['x', 'z']
    else
      [onAxis, offAxis] = ['z', 'x']
    isReversed = false
    if state?.playerDirection?.x > 0 or state?.playerDirection?.z > 0
      isReversed = true

    jointsFront = [
      getJoint(t, size, onAxis, offAxis, [0.4, 0.3]),
      getJoint(t, size, onAxis, offAxis, [0.5, 0.3]),
      getJoint(t, size, onAxis, offAxis, [0.6, 0.3]),
    ]
    kneesFront = [
      getKnee(t, size, onAxis, offAxis, isReversed, isMoving, [0.3, 0.2, 0.66]),
      getKnee(t, size, onAxis, offAxis, isReversed, isMoving, [0.5, 0.2, 0.0]),
      getKnee(t, size, onAxis, offAxis, isReversed, isMoving, [0.7, 0.2, 0.33]),
    ]
    legsFront = [
      getFoot(t, size, onAxis, offAxis, isReversed, isMoving, [0.2, 0.1, 0.0]),
      getFoot(t, size, onAxis, offAxis, isReversed, isMoving, [0.5, 0.1, 0.33]),
      getFoot(t, size, onAxis, offAxis, isReversed, isMoving, [0.8, 0.1, 0.66]),
    ]

    jointsBack = [
      getJoint(t, size, onAxis, offAxis, [0.4, 0.7]),
      getJoint(t, size, onAxis, offAxis, [0.5, 0.7]),
      getJoint(t, size, onAxis, offAxis, [0.6, 0.7]),
    ]
    kneesBack = [
      getKnee(t, size, onAxis, offAxis, isReversed, isMoving, [0.3, 0.8, 0.0]),
      getKnee(t, size, onAxis, offAxis, isReversed, isMoving, [0.5, 0.8, 0.33]),
      getKnee(t, size, onAxis, offAxis, isReversed, isMoving, [0.7, 0.8, 0.66]),
    ]
    legsBack = [
      getFoot(t, size, onAxis, offAxis, isReversed, isMoving, [0.2, 0.9, 0.33]),
      getFoot(t, size, onAxis, offAxis, isReversed, isMoving, [0.5, 0.9, 0.66]),
      getFoot(t, size, onAxis, offAxis, isReversed, isMoving, [0.8, 0.9, 0.0]),
    ]

    ctx.strokeWidth = 1
    for legPos in legsBack
      drawCircleStroke(ctx, originOffset, legPos, 1)
    for kneePos in kneesBack
      drawCircleStroke(ctx, originOffset, kneePos, 1)
    for [kneePos, legPos] in _.zip(kneesBack, legsBack)
      drawLine(ctx, originOffset, legPos, kneePos)
    for [kneePos, jointPos] in _.zip(kneesBack, jointsBack)
      drawLine(ctx, originOffset, kneePos, jointPos)

    ctx.strokeWidth = 2
    drawCircleFill(ctx, originOffset, middle, 14)
    drawCircleStroke(ctx, originOffset, middle, 14)

    ctx.strokeWidth = 1
    for legPos in legsFront
      drawCircleStroke(ctx, originOffset, legPos, 1)
    for kneePos in kneesFront
      drawCircleStroke(ctx, originOffset, kneePos, 1)
    for [kneePos, legPos] in _.zip(kneesFront, legsFront)
      drawLine(ctx, originOffset, legPos, kneePos)
    for [kneePos, jointPos] in _.zip(kneesFront, jointsFront)
      drawLine(ctx, originOffset, kneePos, jointPos)


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
  playerSprite.redraw(t, state)
  sortSprites()
  for sprite in sprites
    p = world3ToWorld2(sprite.origin)
      .subtract(sprite.originOffset)
      .add(SIZE.multiply(1/2))
      .subtract(state.cameraPos)
    sprite.el.style.webkitTransform = "translate3d(#{p.x}px, #{p.y}px, 0px)"

  state

module.exports = applySprites