{Vector2, Vector3} = require './geometry'
keyboard = require './keyboard'
{getIsKeyDown} = keyboard
{world3ToWorld2} = require './projection'

getCellOrigin = (cellPos) -> cellPos.multiply(32)

getCirclePos = (t, period=1000, radius=256) ->
  period = 1000
  progress = (t % period) / period
  angle = Math.PI * 2 * progress
  new Vector2(Math.cos(angle) / 2 * 256, Math.sin(angle) / 2 * 256)

getIsCellAvailable = ({boardSize, player, npcs}, cellPos) ->
  return false if cellPos.x < 0
  return false if cellPos.z < 0
  return false if cellPos.x >= boardSize.x
  return false if cellPos.z >= boardSize.z
  return false if player.targetCell.isEqual(cellPos)
  for {targetCell} in npcs
    return false if targetCell.isEqual(cellPos)
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
  canChangeTargetCell = mutateGridEntityState(100, state, entityState, t, dt)

  # ^ may cascade
  if canChangeTargetCell
    fromCell = entityState.targetCell
    inputs = [
      ['playerLeft', new Vector3(0, 0, 1)],
      ['playerRight', new Vector3(0, 0, -1)],
      ['playerUp', new Vector3(1, 0, 0)],
      ['playerDown', new Vector3(-1, 0, 0)],
    ]
    for [keyName, directionVector] in inputs
      if getIsKeyDown(keyName) and getIsCellAvailable(state, fromCell.add directionVector)
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
  canChangeTargetCell = mutateGridEntityState(80, state, entityState, t, dt)

  # ^ may cascade
  if canChangeTargetCell
    fromCell = entityState.targetCell
    directions = _.filter DIRECTIONS, (d) ->
      getIsCellAvailable(state, fromCell.add(d))
    nextDirection = _.choice directions
    entityState.targetCell = fromCell.add nextDirection
    entityState.direction = nextDirection

  entityState.isMoving = true  # always moving
  entityState


applyInput = (state, t, dt) ->
  dt /= 1000  # in seconds, please

  state.player = getNextPlayerState(state, state.player, t, dt)
  state.cameraPos = world3ToWorld2(state.player.origin)

  for npcState in state.npcs
    mutateNPCState(state, npcState, t, dt)

  keyboard.markKeyCheckpoint()
  state

module.exports = applyInput