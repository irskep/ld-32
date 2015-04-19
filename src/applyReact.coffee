{Vector3} = require './geometry'
{world3ToWorld2} = require './projection'

ReactUpdates = require('react/lib/ReactUpdates')
injectBatchingStrategy = ReactUpdates.injection.injectBatchingStrategy
injectBatchingStrategy(
  isBatchingUpdates: true,
  batchedUpdates: (callback, args...) -> callback(args...)
)

COLORS = [
  '#f00',
  '#f80',
  '#ff0',
  '#8f0',
  '#0f0',
  '#0f8',
  '#0ff',
  '#08f',
  '#00f',
  '#80f',
  '#f0f',
  '#f08',
]

###
.outline-text {
  color: #000;
  text-shadow:
    -1px -1px 0 #fff,
    1px -1px 0 #fff,
    -1px 1px 0 #fff,
    1px 1px 0 #fff;
}
###


RainbowOutline = React.createClass
  displayName: 'RainbowOutline'
  render: ->
    <span>
      {_.map @props.children, (char, i) ->
        color = COLORS[i % COLORS.length]
        <span
            style={{
              color: '#000'
              textShadow: (
                "-1px -1px 0 #{color}," +
                "1px -1px 0 #{color}," +
                "-1px 1px 0 #{color}," +
                "1px 1px 0 #{color};")
            }}>
          {char}
        </span>
      }
    </span>


Rainbow = React.createClass
  displayName: 'Rainbow'
  render: ->
    <span>
      {_.map @props.children, (char, i) ->
        color = COLORS[i % COLORS.length]
        <span style={{color}}>{char}</span>
      }
    </span>


Spin = React.createClass
  displayName: 'Spin'
  render: ->
    <span className="spin">{@props.children}</span>


TitleScreen = React.createClass
  displayName: 'TitleScreen'
  render: ->
    <div>
      <div style={{fontSize: '96px'}}>
        <RainbowOutline>Scuttlebug</RainbowOutline>
      </div>
      <div>
        <Rainbow>
          <span>&uarr;</span>
          <span>&rarr;</span>
          <span>&darr;</span>
          <span>&larr;</span>
          <span> </span><span />
          <span>&lt;space&gt;</span></Rainbow>
      </div>
      <div style={{marginTop: 64, fontSize: '72px'}}>
        <a style={{cursor: 'pointer'}} onClick={-> console.log 'go'}>
          <RainbowOutline>
            G<Spin>O</Spin>
          </RainbowOutline>
        </a>
      </div>
    </div>

Root = React.createClass
  displayName: 'Root'
  render: ->
    state = @props.state
    <div style={{width: window.SIZE.x, height: window.SIZE.y, textAlign: 'center'}}>
      {state.isTitleScreenVisible && <TitleScreen />}
    </div>


reactRootEl = document.querySelectorAll('#react-root')[0]
applyReact = (state, t, dt) ->
  React.renderComponent(<Root state={state} />, reactRootEl)
  ReactUpdates.flushBatchedUpdates()
  state

module.exports = applyReact