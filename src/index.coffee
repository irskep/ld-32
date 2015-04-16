# @cjsx React.DOM
window._ = require 'underscore'
window.React = React = require 'react/addons'
window.Bacon = require 'baconjs'
require './util'

{Vector2} = require './geometry'

applyInput = require './applyInput'
applyReact = require './applyReact'
applySprites = require './applySprites'

window.SIZE = new Vector2(500, 500)


state = {
  cameraPos: new Vector2(0, 0)
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
