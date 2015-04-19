# @cjsx React.DOM
window._ = require 'underscore'
window.React = React = require 'react/addons'
window.Bacon = require 'baconjs'
require './util'

{Vector2, Vector3} = require './geometry'

applyInput = require './applyInput'
applyReact = require './applyReact'
applySprites = require './applySprites'

window.SIZE = new Vector2(600, 700)

spriteRoot = document.querySelectorAll('#sprite-root')[0]
spriteRoot.style.width = SIZE.x + 'px'
spriteRoot.style.height = SIZE.y + 'px'


createInitialGridEntityState = (x, z, extra={}) ->
  _.extend extra, {
    origin: new Vector3(x * 32, 0, z * 32)
    targetCell: new Vector3(x, 0, z)
    direction: new Vector3(1, 0, 0)
    id: _.uniqueId()
  }


getWalls = (listOfXZPairs) ->
  walls = {}
  for [x, z] in listOfXZPairs
    walls["#{x},#{z}"] = new Vector3(x, 0, z)
  walls


state = {
  boardSize: new Vector3(16, 0, 16)
  cameraPos: new Vector2(0, 0)
  player: createInitialGridEntityState(8, 8)
  walls: getWalls([[9, 10], [10, 10], [11, 10], [12, 10], [13, 10]])
  npcs: [
    createInitialGridEntityState(0, 0, {team: 1, color: '#822'}),
    createInitialGridEntityState(15, 15, {team: 1, color: '#822'}),
    createInitialGridEntityState(0, 15, {team: 2, color: '#228'}),
    createInitialGridEntityState(15, 0, {team: 2, color: '#228'}),
  ]
}


### it's run time! ###

onAnimationFrame = (callback) ->
  animationFrameCallback = (t) ->
    callback(t)
    window.requestAnimationFrame animationFrameCallback
  window.requestAnimationFrame animationFrameCallback


lastT = null
onAnimationFrame (t) ->
  lastT ?= t
  dt = t - lastT
  lastT = t

  state = applyInput(state, t, dt)
  state = applyReact(state, t, dt)
  state = applySprites(state, t, dt)


module.exports = {}
