{Vector2, Vector3} = require './geometry'
keyboard = require './keyboard'
{getIsKeyDown} = keyboard
{world3ToWorld2} = require './projection'

getCirclePos = (t, period=1000, radius=256) ->
  period = 1000
  progress = (t % period) / period
  angle = Math.PI * 2 * progress
  new Vector2(Math.cos(angle) / 2 * 256, Math.sin(angle) / 2 * 256)


updateStateFreeInput = (entityState, t, dt) ->
  dPlayerPos = new Vector3(0, 0, 0)
  entityState.isMoving = false
  if getIsKeyDown('playerLeft')
    dPlayerPos = new Vector3(0, 0, 100 * dt)
    entityState.direction = new Vector3(0, 0, 1)
    entityState.isMoving = true
  if getIsKeyDown('playerRight')
    dPlayerPos = new Vector3(0, 0, -100 * dt)
    entityState.direction = new Vector3(0, 0, -1)
    entityState.isMoving = true
  if getIsKeyDown('playerUp')
    dPlayerPos = new Vector3(100 * dt, 0, 0)
    entityState.direction = new Vector3(1, 0, 0)
    entityState.isMoving = true
  if getIsKeyDown('playerDown')
    dPlayerPos = new Vector3(-100 * dt, 0, 0)
    entityState.direction = new Vector3(-1, 0, 0)
    entityState.isMoving = true
  entityState.origin = entityState.origin.add(dPlayerPos)
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