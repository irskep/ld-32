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


state = {
  boardSize: new Vector3(16, 0, 16)
  cameraPos: new Vector2(0, 0)
  player:
    origin: new Vector3(8 * 32, 0, 8 * 32)
    targetCell: new Vector3(8, 0, 8)
    direction: new Vector3(1, 0, 0)
  npcs: []
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
