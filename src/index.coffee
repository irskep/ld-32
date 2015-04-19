# @cjsx React.DOM
window._ = require 'underscore'
window.React = React = require 'react/addons'
window.Bacon = require 'baconjs'
require './util'

{Vector2, Vector3} = require './geometry'
stateFactories = require './stateFactories'

applyInput = require './applyInput'
applyReact = require './applyReact'
applySprites = require './applySprites'

window.SIZE = new Vector2(700, 500)
window.CELL_SIZE = 32
window.PLAYER_SPEED = window.CELL_SIZE * (100 / 32)
window.NPC_SPEED = window.CELL_SIZE * (80 / 32)

spriteRoot = document.querySelectorAll('#sprite-root')[0]
spriteRoot.style.width = SIZE.x + 'px'
spriteRoot.style.height = SIZE.y + 'px'


### it's run time! ###

onAnimationFrame = (callback) ->
  animationFrameCallback = (t) ->
    callback(t)
    window.requestAnimationFrame animationFrameCallback
  window.requestAnimationFrame animationFrameCallback


state = stateFactories.level1()

lastT = null
onAnimationFrame (t) ->
  lastT ?= t
  dt = t - lastT
  lastT = t

  state = applyInput(state, t, dt)
  state = applyReact(state, t, dt)
  state = applySprites(state, t, dt)


module.exports = {}
