keyCodeToName = require './keyCodeToName'
keyNameToCode = _.invert(keyCodeToName)

actionToKeyName =
  playerLeft: 'left'
  playerRight: 'right'
  playerUp: 'up'
  playerDown: 'down'
  action: 'space'

actionToKeyCode = _.objMap actionToKeyName, (name, key, dest) ->
  dest[key] = keyNameToCode[name]
keyCodeToAction = _.invert(actionToKeyCode)
allBoundKeys = _.values(actionToKeyCode)

actionKeyState = _.objMap actionToKeyCode, (val, actionName, dest) ->
  keyState = {
    downs: new Bacon.Bus(),
    ups: new Bacon.Bus(),
    isDown: false,
    keyPressesSinceLastCheckpoint: 0
  }
  keyState.downs.onValue ->
    keyState.isDown = true
    keyState.keyPressesSinceLastCheckpoint += 1
  keyState.ups.onValue -> keyState.isDown = false
  dest[actionName] = keyState

getIsKeyDown = (k) -> actionKeyState[k].isDown
getKeyDowns = (k) -> actionKeyState[k].downs
getKeyUps = (k) -> actionKeyState[k].ups
getKeyPressesSinceLastCheckpoint = (k) ->
  actionKeyState[k].keyPressesSinceLastCheckpoint
markKeyCheckpoint = ->
  _.each actionKeyState, (state) ->
    state.keyPressesSinceLastCheckpoint = 0


document.addEventListener 'keydown', (e) ->
  if e.keyCode of keyCodeToAction
    e.preventDefault()
    e.stopPropagation()
    actionName = keyCodeToAction[e.keyCode]
    unless getIsKeyDown(actionName)
      actionKeyState[actionName].downs.push()
    return false

document.addEventListener 'keyup', (e) ->
  if e.keyCode of keyCodeToAction
    e.preventDefault()
    e.stopPropagation()
    actionKeyState[keyCodeToAction[e.keyCode]].ups.push()
    return false


module.exports = {
  getIsKeyDown,
  getKeyDowns,
  getKeyUps,
  markKeyCheckpoint,
  getKeyPressesSinceLastCheckpoint,
}