{Vector2, Rect2, Vector3} = require './geometry'
{world3ToWorld2} = require './projection'

createCanvasSprite = (originPosition, size, draw) ->
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
  size = boundingRect.getSize()
  canvas.width = size.x
  canvas.height = size.y
  canvas.className = 'sprite'
  canvas.style.width = "#{size.x}px"
  canvas.style.height = "#{size.y}px"
  ctx = canvas.getContext('2d')
  draw({originOffset, ctx, canvas})

  {originPosition, originOffset, size, el: canvas, id: _.uniqueId()}


module.exports = {createCanvasSprite}