class Vector2
  constructor: (@x, @y) ->
    throw "NaN" if isNaN(@x) or isNaN(@y)
  floor: -> new Vector2(Math.floor(@x), Math.floor(@y))
  ceil: -> new Vector2(Math.ceil(@x), Math.ceil(@y))
  multiply: (factor) -> new Vector2(@x * factor, @y * factor)
  pairMultiply: (other) -> new Vector2(@x * other.x, @y * other.y)
  pairDivide: (other) -> new Vector2(@x / other.x, @y / other.y)
  isEqual: (other) -> @x == other.x and @y == other.y
  clone: -> new Vector2(@x, @y)
  add: (other) -> new Vector2(@x + other.x, @y + other.y)
  subtract: (other) -> new Vector2(@x - other.x, @y - other.y)
  getLength: -> Math.sqrt(@x * @x + @y * @y)


class Vector3
  constructor: (@x, @y, @z) ->
    throw "NaN" if isNaN(@x) or isNaN(@y) or isNaN(@z)
  floor: -> new Vector3(Math.floor(@x), Math.floor(@y), Math.floor(@z))
  ceil: -> new Vector3(Math.ceil(@x), Math.ceil(@y), Math.ceil(@z))
  multiply: (factor) -> new Vector3(@x * factor, @y * factor, @y * factor)
  pairMultiply: (other) ->
    new Vector3(@x * other.x, @y * other.y, @z * other.z)
  pairDivide: (other) -> new Vector3(@x / other.x, @y / other.y, @z / other.z)
  isEqual: (other) -> @x == other.x and @y == other.y and @z == other.z
  clone: -> new Vector3(@x, @y, @z)
  add: (other) -> new Vector3(@x + other.x, @y + other.y, @z + other.z)
  subtract: (other) -> new Vector3(@x - other.x, @y - other.y, @z - other.z)
  dot: (other) -> (@x * other.x + @y * other.y + @z * other.z)
  getLength: -> Math.sqrt(@dot(this))


class Rect2
  constructor: (@xmin, @ymin, @xmax, @ymax) ->
    throw "NaN" if isNaN(@xmin) or isNaN(@ymin) or isNaN(@xmax) or isNaN(@ymax)
  getMin: -> new Vector2(@xmin, @ymin)
  getMax: -> new Vector2(@xmax, @ymax)
  getSize: -> new Vector2(@xmax - @xmin, @ymax - @ymin)
  @fromCenter: (center, size) ->
    halfSize = size.multiply(0.5)
    new Rect2(
      center.x - halfSize.x, center.y - halfSize.y
      center.x + halfSize.x, center.y + halfSize.y)
  @minimumBoundingRect: (points) ->
    new Rect2(
      Math.min(_.pluck(points, 'x')...),
      Math.min(_.pluck(points, 'y')...),
      Math.max(_.pluck(points, 'x')...),
      Math.max(_.pluck(points, 'y')...),
    )


module.exports = {Vector2, Vector3, Rect2}