{Vector2} = require './geometry'
keyboard = require './keyboard'
{getIsKeyDown} = keyboard

getCirclePos = (t, period=1000, radius=256) ->
  period = 1000
  progress = (t % period) / period
  angle = Math.PI * 2 * progress
  new Vector2(Math.cos(angle) / 2 * 256, Math.sin(angle) / 2 * 256)


applyInput = (state, t, dt) ->
  dt /= 1000  # in seconds, please
  dp = new Vector2(0, 0)
  if getIsKeyDown('playerLeft') then dp.x -= 300 * dt
  if getIsKeyDown('playerRight') then dp.x += 300 * dt
  if getIsKeyDown('playerUp') then dp.y -= 300 * dt
  if getIsKeyDown('playerDown') then dp.y += 300 * dt
  state.cameraPos = state.cameraPos.add(dp)

  keyboard.markKeyCheckpoint()
  return state

module.exports = applyInput