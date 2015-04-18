{Vector3} = require './geometry'
{world3ToWorld2} = require './projection'

svgUtils =
  translate: ({x, y}) -> "translate(#{x}, #{y})"

ReactUpdates = require('react/lib/ReactUpdates')
injectBatchingStrategy = ReactUpdates.injection.injectBatchingStrategy
injectBatchingStrategy(
  isBatchingUpdates: true,
  batchedUpdates: (callback, args...) -> callback(args...)
)

reactRootEl = document.querySelectorAll('#react-root')[0]
Root = React.createClass
  displayName: 'Root'
  render: ->
    LINES = [
      {x1: -1, z1: -1, x2: -1, z2: 1, color: '#f00'},
      {x1: -1, z1: 1, x2: 1, z2: 1, color: '#ff0'},
      {x1: 1, z1: 1, x2: 1, z2: -1, color: '#0f0'},
      {x1: 1, z1: -1, x2: -1, z2: -1, color: '#0ff'},
    ]
    transform = svgUtils.translate(
      SIZE.multiply(1/2).subtract(this.props.state.cameraPos))
    <svg width={SIZE.x} height={SIZE.y} viewBox={"0 0 #{SIZE.x} #{SIZE.y}"}
        style={{border: "1px solid white;"}}>
      <g transform={transform}>
        {_.map LINES, ({x1, z1, x2, z2, color}) ->
          p1 = world3ToWorld2(new Vector3(x1 * 100, 0, z1 * 100))
          p2 = world3ToWorld2(new Vector3(x2 * 100, 0, z2 * 100))
          <line x1={p1.x} y1={p1.y} x2={p2.x} y2={p2.y} stroke={color}
            strokeWidth="2"/>
        }
      </g>
    </svg>


applyReact = (state, t, dt) ->
  #React.renderComponent(<Root state={state} />, reactRootEl)
  ReactUpdates.flushBatchedUpdates()
  state

module.exports = applyReact