{Vector2, Vector3} = require './geometry'
keyboard = require './keyboard'
{getIsKeyDown} = keyboard

getCirclePos = (t, period=1000, radius=256) ->
  period = 1000
  progress = (t % period) / period
  angle = Math.PI * 2 * progress
  new Vector2(Math.cos(angle) / 2 * 256, Math.sin(angle) / 2 * 256)


applyInput = (state, t, dt) ->
  dt /= 1000  # in seconds, please

  dPlayerPos = new Vector3(0, 0, 0)
  if getIsKeyDown('playerLeft') then dPlayerPos.z += 100 * dt
  if getIsKeyDown('playerRight') then dPlayerPos.z -= 100 * dt
  if getIsKeyDown('playerUp') then dPlayerPos.x += 100 * dt
  if getIsKeyDown('playerDown') then dPlayerPos.x -= 100 * dt
  state.playerPos = state.playerPos.add(dPlayerPos)

  dCameraPos = new Vector2(0, 0)
  if getIsKeyDown('cameraLeft') then dCameraPos.x -= 300 * dt
  if getIsKeyDown('cameraRight') then dCameraPos.x += 300 * dt
  if getIsKeyDown('cameraUp') then dCameraPos.y -= 300 * dt
  if getIsKeyDown('cameraDown') then dCameraPos.y += 300 * dt
  state.cameraPos = state.cameraPos.add(dCameraPos)

  keyboard.markKeyCheckpoint()
  return state

module.exports = applyInput