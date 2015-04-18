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


moveGridEntity = (speed, entityState, t, dt) ->
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


updateStateFreeInput = (entityState, t, dt) ->
  canChangeTargetCell = moveGridEntity(100, entityState, t, dt)

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
      if getIsKeyDown(keyName)
        entityState.targetCell = fromCell.add directionVector
        entityState.direction = directionVector
        entityState.isMoving = true

  entityState


applyInput = (state, t, dt) ->
  dt /= 1000  # in seconds, please

  state.player = updateStateFreeInput(state.player, t, dt)
  state.cameraPos = world3ToWorld2(state.player.origin)

  ###
  dCameraPos = new Vector2(0, 0)
  if getIsKeyDown('cameraLeft') then dCameraPos.x -= 300 * dt
  if getIsKeyDown('cameraRight') then dCameraPos.x += 300 * dt
  if getIsKeyDown('cameraUp') then dCameraPos.y -= 300 * dt
  if getIsKeyDown('cameraDown') then dCameraPos.y += 300 * dt
  state.cameraPos = state.cameraPos.add(dCameraPos)
  ###

  keyboard.markKeyCheckpoint()
  state

module.exports = applyInput