{Vector3} = require './geometry'
{world3ToWorld2} = require './projection'

viewerNormal = new Vector3(-1, 0, -1)

isInFront = (spriteA, spriteB) ->
  return spriteA.layer > spriteB.layer if spriteA.layer isnt spriteB.layer

  return world3ToWorld2(spriteA.origin).y > world3ToWorld2(spriteB.origin).y

  minA = spriteA.origin
  minB = spriteB.origin
  maxA = spriteA.origin.add(spriteA.size)
  maxB = spriteB.origin.add(spriteB.size)

  compareY = minA.y isnt minB.y or minA.y isnt maxA.y or
    minB.y isnt maxB.y
  compareX = minA.x isnt minB.x or minA.x isnt maxA.x or
    minB.x isnt maxB.x
  compareZ = minA.z isnt minB.z or minA.z isnt maxA.z or
    minB.z isnt maxB.z

  # if flat objects at same y height don't intersect in x or z,
  # they don't _actually_ overlap, and thus aren't comparable
  if not compareY and (maxA.x <= minB.x or maxA.x <= minB.x or
      maxA.z <= minB.z or maxA.z <= minB.z)
    # return a junk but stable value
    return minA.x + minA.y > minB.x + minB.y
    #return null

  return true if (compareY and minA.y >= maxB.y) or
    (compareX and maxA.x <= minB.x) or
    (compareZ and maxA.z <= minB.z)
  return false if (compareY and maxA.y <= minB.y) or
    (compareX and minA.x >= maxB.x) or
    (compareZ and minA.z >= maxB.z)

  #if not compareY
  #  return spriteA.node.lastMoved > spriteB.node.lastMoved

  # Boxes collide. heuristic: look at centers of boxes, and decide based on
  # that normal to plane facing viewer
  # want the distance from the center to the plane, aka the projection
  # of vector to center along the normal of the plane
  centerBaseA = new Vector3(
    (maxA.x + minA.x) / 2, minA.y, (maxA.z + minA.z) / 2)
  centerBaseB = new Vector3(
    (maxB.x + minB.x) / 2, minB.y, (maxB.z + minB.z) / 2)

  # dot product
  score1 = viewerNormal.dot(centerBaseA)
  score2 = viewerNormal.dot(centerBaseB)

  return score1 > score2  unless score1 is score2

  return false
  #spriteA.node.lastMoved > spriteB.node.lastMoved

module.exports = isInFront
