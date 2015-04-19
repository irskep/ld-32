{Vector2, Vector3} = require './geometry'
keyboard = require './keyboard'
{getIsKeyDown} = keyboard
{world3ToWorld2} = require './projection'
stateFactories = require './stateFactories'


###
BUG TYPES
* A
  * Moves randomly
  * If player is in line of sight, beeline
  * Destroyed on contact with B
* B
  * Avoids player
  * Destroyed on contact with A
* C
  * Stays near black holes
  * Destroyed when black hole is full
* D
  * Stays near edges
  * Must be thrown into black hole
###


getWeightedDirection = (state, pos, directions, getWeight) ->


chooseNPCDirection = (state, entityState, validAdjacentDirections) ->
  playerPos = state.player.targetCell
  entityPos = entityState.targetCell

  switch entityState.type
    when 'A'
      # if we see the player, beeline
      # (walls, whatever)
      if playerPos.x == entityPos.x
        if playerPos.z > entityPos.z and getCanBeelineToCell(state, entityPos, playerPos, new Vector3(0, 0, 1))
          return new Vector3(0, 0, 1)
        if playerPos.z < entityPos.z and getCanBeelineToCell(state, entityPos, playerPos, new Vector3(0, 0, -1))
          return new Vector3(0, 0, -1)
      if playerPos.z == entityPos.z
        if playerPos.x > entityPos.x and getCanBeelineToCell(state, entityPos, playerPos, new Vector3(1, 0, 0))
          return new Vector3(1, 0, 0)
        if playerPos.x < entityPos.x and getCanBeelineToCell(state, entityPos, playerPos, new Vector3(-1, 0, 0))
          return new Vector3(-1, 0, 0)

      maxVisits = 0
      sortedDirections = _.sortBy validAdjacentDirections, (d) ->
        p = entityPos.add(d)
        entityState.cellVisits["#{p.x},#{p.y}"] ?= 0
        visits = entityState.cellVisits["#{p.x},#{p.y}"]
        maxVisits = Math.max(maxVisits, visits)
        -visits
      weights = _.map sortedDirections, (d, i) ->
        p = entityPos.add(d)
        maxVisits + 1 - entityState.cellVisits["#{p.x},#{p.y}"]
      return _.choice sortedDirections, weights
    when 'B'
      directionsILike = _.filter validAdjacentDirections, (d) ->
        not entityPos.add(d).isEqual(playerPos)
      if directionsILike.length == 0
        _.choice validAdjacentDirections

      currentDistFromPlayer = playerPos.subtract(entityPos).getLength()
      weights = _.map directionsILike, (d) ->
        if playerPos.subtract(entityPos.add(d)).getLength() < currentDistFromPlayer
          return 1  # closer :-(
        else
          return 4  # farther away :-)
      return _.choice directionsILike, weights


getCellOrigin = (cellPos) -> cellPos.multiply(window.CELL_SIZE)
getOriginCell = (origin) ->
  new Vector3(
    Math.floor(origin.x / window.CELL_SIZE),
    0,
    Math.floor(origin.z / window.CELL_SIZE))

getCirclePos = (t, period=1000, radius=256) ->
  period = 1000
  progress = (t % period) / period
  angle = Math.PI * 2 * progress
  new Vector2(Math.cos(angle) / 2 * 256, Math.sin(angle) / 2 * 256)

getCanBeelineToCell = (state, from, to, stepVector) ->
  while true
    return true if from.isEqual(to)
    from = from.add(stepVector)
    return false unless getIsCellWalkable(state, from)

getIsCellWalkable = ({boardSize, player, npcs, walls}, cellPos) ->
  return false if "#{cellPos.x},#{cellPos.z}" of walls
  return false if cellPos.x < 0
  return false if cellPos.z < 0
  return false if cellPos.x >= boardSize.x
  return false if cellPos.z >= boardSize.z
  return true


mutateGridEntityState = (speed, state, entityState, t, dt) ->
  movementThisFrame = speed * dt
  entityState.isMoving = false
  if not getCellOrigin(entityState.targetCell).isEqual(entityState.origin)
    entityState.isMoving = true
    cellOrigin = getCellOrigin(entityState.targetCell)
    targetDifference = cellOrigin.subtract(entityState.origin)
    if targetDifference.getLength() <= movementThisFrame
      entityState.origin = cellOrigin
    else
      posChange = targetDifference.normalized().multiply(movementThisFrame)
      entityState.origin = entityState.origin.add(posChange)
  getCellOrigin(entityState.targetCell).isEqual(entityState.origin)


getNextPlayerState = (state, entityState, t, dt) ->
  canChangeTargetCell = mutateGridEntityState(window.PLAYER_SPEED, state, entityState, t, dt)

  if entityState.tongue
    changeAmt = window.TONGUE_SPEED * dt
    if entityState.tongue.isExtending
      entityState.tongue.length += changeAmt
      tongueVector = entityState.direction.multiply(entityState.tongue.length)
      unless getIsCellWalkable(state, getOriginCell(entityState.origin.add(tongueVector)))
        console.log 'bump'
        entityState.tongue.isExtending = false
    else
      if entityState.tongue.length <= changeAmt
        entityState.tongue.length = 0
        unless entityState.tongue.npcId
          console.log 'shloop'
          entityState.tongue = null
      else
        entityState.tongue.length -= changeAmt


  # ^ may cascade
  if canChangeTargetCell and not entityState.tongue
    if keyboard.getIsKeyDown('action')
      console.log ':-P'

      maxLength = 0
      tongueTest = entityState.targetCell
      while true
        tongueTest = tongueTest.add entityState.direction
        if getIsCellWalkable(state, tongueTest)
          maxLength += window.CELL_SIZE
        else
          break
      entityState.tongue =
        length: 0
        npcId: null
        isExtending: true
        maxLength: maxLength
    else
      fromCell = entityState.targetCell
      inputs = [
        ['playerLeft', new Vector3(0, 0, 1)],
        ['playerRight', new Vector3(0, 0, -1)],
        ['playerUp', new Vector3(1, 0, 0)],
        ['playerDown', new Vector3(-1, 0, 0)],
      ]
      for [keyName, directionVector] in inputs
        if getIsKeyDown(keyName) and getIsCellWalkable(state, fromCell.add directionVector)
          entityState.targetCell = fromCell.add directionVector
          entityState.direction = directionVector
          entityState.isMoving = true

  entityState


DIRECTIONS = [
  new Vector3(0, 0, 1), new Vector3(0, 0, -1),
  new Vector3(1, 0, 0), new Vector3(-1, 0, 0),
]
mutateNPCState = (state, entityState, t, dt) ->
  # TODO: leg animation speed should depend on entity speed
  canChangeTargetCell = mutateGridEntityState(window.NPC_SPEED, state, entityState, t, dt)

  # ^ may cascade
  if canChangeTargetCell
    fromCell = entityState.targetCell
    directions = _.filter DIRECTIONS, (d) ->
      toCell = fromCell.add(d)
      return false unless getIsCellWalkable(state, toCell)
      for npcState in state.npcs
        if npcState.targetCell.isEqual(toCell)
          return false
      return true
    nextDirection = chooseNPCDirection(state, entityState, directions)
    entityState.targetCell = fromCell.add nextDirection
    entityState.direction = nextDirection
    {x, z} = entityState.targetCell
    entityState.cellVisits["#{x},#{z}"] ?= 0
    entityState.cellVisits["#{x},#{z}"] += 1

  entityState.isMoving = true  # always moving
  entityState


applyInput = (state, t, dt) ->
  dt /= 1000  # in seconds, please

  if state.player
    state.player = getNextPlayerState(state, state.player, t, dt)
    state.cameraPos = world3ToWorld2(getCellOrigin(new Vector3(state.boardSize.x / 2, 0, state.boardSize.z / 2)))

  if state.npcs
    for npcState in state.npcs
      mutateNPCState(state, npcState, t, dt)

  if state.isTitleScreenVisible and keyboard.getKeyPressesSinceLastCheckpoint('action') > 0
    console.log 'go to level 1'
    state = stateFactories.level1()

  keyboard.markKeyCheckpoint()
  state

module.exports = applyInput