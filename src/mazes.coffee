{Vector3} = require './geometry'

MAZE1 = "
. . . . . . . . . . .
. # # . # # # . # # .
. # . . . . . . . # .
. . . # # . # # . . .
. # . # . . . # . # .
. # . . . . . . . # .
. # . # . . . # . # .
. . . # # . # # . . .
. # . . . . . . . # .
. # # . # # # . # # .
. . . . . . . . . . .
"

parseMaze = (s, w, h) ->
  walls = {}
  x = 0
  z = 0
  for char in s
    if char != ' '
      if char == '#'
        walls["#{x},#{z}"] = new Vector3(x, 0, z)
      x += 1
      if x >= w
        x = 0
        z += 1
  {w, h, walls}

module.exports = mazes =
  maze1: parseMaze(MAZE1, 11, 11)