{world3ToWorld2} = require './projection'
{createCanvasSprite} = require './sprites'
{Vector3, Vector2} = require './geometry'
sprites = []

spriteRootEl = document.querySelectorAll('#sprite-root')[0]


addSprite = (sprite) ->
  spriteRootEl.appendChild(sprite.el)
  sprites.push sprite


addInitialSprites = ->
  p = new Vector3(-100, 0, -100)
  s = new Vector3(200, 0, 200)
  addSprite createCanvasSprite p, s, ({originOffset, ctx, canvas}) ->
    points = [
      new Vector3(0, 0, 0),
      new Vector3(s.x, 0, 0),
      new Vector3(s.x, 0, s.z),
      new Vector3(0, 0, s.z),
    ]
    ctx.beginPath()
    ctx.moveTo(points[0].x + originOffset.x, points[0].y + originOffset.y)
    for point3 in _.rest(points)
      point2 = world3ToWorld2(point3).add(originOffset)
      ctx.lineTo(point2.x, point2.y)
    ctx.fillStyle = 'white'
    ctx.fill()


applySprites = (state, t, dt) ->
  unless sprites.length
    addInitialSprites()
  for sprite in sprites
    p = world3ToWorld2(sprite.originPosition)
      .subtract(sprite.originOffset)
      .add(SIZE.multiply(1/2))
      .subtract(state.cameraPos)
    sprite.el.style.webkitTransform = "translate3d(#{p.x}px, #{p.y}px, 0px)"

  state

module.exports = applySprites