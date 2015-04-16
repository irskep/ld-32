{Vector2, Vector3} = require './geometry'

module.exports =
  world3ToWorld2: (p) -> new Vector2(p.x - p.z, -p.y - (p.x + p.z) / 2)

  world2ToWorld3WithX: (p, x) ->
    new Vector3(x, (-2 * p.y + p.x - 2 * x) / 2, x - p.x)
  world2ToWorld3WithY: (p, y) ->
    # worlfram alpha: solve r=x-z, q=-y-(x+z)/2 for x,z
    # where p.x := r and p.y := q
    new Vector3((p.x - 2 * p.y - 2 * y) / 2, y, -(2 * p.y + 2 * y + p.x) / 2)
  world2ToWorld3WithZ: (p, z) ->
    new Vector3(p.x + z, -p.y - p.x / 2 - z, z)

