_ = require 'underscore'
{Vector2, Vector3} = require './geometry'
mazes = require './mazes'


createInitialGridEntityState = (x, z, extra={}) ->
  _.extend extra, {
    origin: new Vector3(x * window.CELL_SIZE, 0, z * window.CELL_SIZE)
    targetCell: new Vector3(x, 0, z)
    direction: new Vector3(0, 0, -1)
    id: _.uniqueId()
  }


createBugA = (x, z) -> createInitialGridEntityState x, z, {type: 'A', cellVisits: {}}
createBugB = (x, z) -> createInitialGridEntityState x, z, {type: 'B', cellVisits: {}}
createBugC = (x, z) -> createInitialGridEntityState x, z, {type: 'C', cellVisits: {}}
createBugD = (x, z) -> createInitialGridEntityState x, z, {type: 'D', cellVisits: {}}


module.exports = stateFactories =
  splash: ->
    isTitleScreenVisible: true
    isGridVisible: false
    cameraPos: new Vector2(0, 0)

  level1: (oldState) ->
    {w, h, walls} = mazes.maze1

    score: 0
    isGridVisible: true
    boardSize: new Vector3(w, 0, h)
    cameraPos: new Vector2(0, 0)
    player: createInitialGridEntityState(w-1, Math.floor(h/2))
    #walls: getWalls([[9, 10], [10, 10], [11, 10], [12, 10], [13, 10]])
    walls: walls
    npcs: [
      createBugA(0, 0),
      createBugB(w-1, h-1),
      #createBugC(0, h-1),
      #createBugD(w-1, 0),
    ]
