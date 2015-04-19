{Vector2, Rect2, Vector3} = require './geometry'
{world3ToWorld2} = require './projection'

spriteIdToSprite = {}

createCanvasSprite = (layer, initialState, origin, size, draw) ->
  canvas = document.createElement('canvas')
  sizePoints = [
    new Vector3(0, 0, 0),
    new Vector3(size.x, 0, 0),
    new Vector3(0, size.y, 0),
    new Vector3(0, 0, size.z),
    new Vector3(size.x, size.y, size.z),
  ]
  boundingRect = Rect2.minimumBoundingRect(_.map(sizePoints, world3ToWorld2))
  originOffset = new Vector2(-boundingRect.xmin, -boundingRect.ymin)
  size2 = boundingRect.getSize()
  canvas.width = size2.x
  canvas.height = size2.y
  canvas.className = 'sprite'
  canvas.style.width = "#{size2.x}px"
  canvas.style.height = "#{size2.y}px"
  ctx = canvas.getContext('2d')

  redraw = (t, state) -> draw({originOffset, ctx, canvas, t, state})
  redraw(0, initialState)

  sprite = {origin, originOffset, size, el: canvas, id: _.uniqueId(), redraw, layer}
  spriteIdToSprite[sprite.id] = sprite
  sprite


module.exports = {createCanvasSprite, spriteIdToSprite}