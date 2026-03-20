import { memo } from 'react'
import { BaseEdge, getBezierPath, type EdgeProps } from '@xyflow/react'
import type { ConnectionType } from '@/shared/types/connection'
import { connectionStyles } from '@/shared/types/connection'

interface ConnectionLineData extends Record<string, unknown> {
  connectionType: ConnectionType
}

function ConnectionLineComponent(props: EdgeProps & { data?: ConnectionLineData }) {
  const { sourceX, sourceY, targetX, targetY, sourcePosition, targetPosition, data } = props
  const connectionType = data?.connectionType ?? 'relates'
  const style = connectionStyles[connectionType]

  const [edgePath] = getBezierPath({
    sourceX,
    sourceY,
    targetX,
    targetY,
    sourcePosition,
    targetPosition,
    curvature: 0.4,
  })

  const edgeId = `edge-${props.id}`
  const glowId = `glow-${props.id}`
  const animateId = `animate-${props.id}`

  return (
    <>
      <defs>
        {/* Glow filter for 'generates' connections */}
        {style.glow && (
          <filter id={glowId} x="-20%" y="-20%" width="140%" height="140%">
            <feGaussianBlur stdDeviation="4" result="blur" />
            <feComposite in="SourceGraphic" in2="blur" operator="over" />
          </filter>
        )}

        {/* Arrow marker */}
        {style.hasArrow && (
          <marker
            id={`arrow-${edgeId}`}
            viewBox="0 0 10 10"
            refX="8"
            refY="5"
            markerWidth="6"
            markerHeight="6"
            orient="auto-start-reverse"
          >
            <path d="M 0 0 L 10 5 L 0 10 z" fill={style.stroke} opacity={0.8} />
          </marker>
        )}
      </defs>

      {/* Glow underlay for 'generates' */}
      {style.glow && (
        <BaseEdge
          id={`${edgeId}-glow`}
          path={edgePath}
          style={{
            stroke: style.stroke,
            strokeWidth: style.strokeWidth + 4,
            fill: 'none',
            opacity: 0.25,
            filter: `url(#${glowId})`,
            animation: 'glow-line 4s ease-in-out infinite',
          }}
        />
      )}

      {/* Main edge */}
      <BaseEdge
        id={edgeId}
        path={edgePath}
        style={{
          stroke: style.stroke,
          strokeWidth: style.strokeWidth,
          strokeDasharray: style.dashArray || undefined,
          fill: 'none',
          opacity: style.glow ? undefined : 0.7,
          markerEnd: style.hasArrow ? `url(#arrow-${edgeId})` : undefined,
          animation: style.glow ? 'glow-line 4s ease-in-out infinite' : undefined,
        }}
      />

      {/* Animated flow dots for 'feeds' and 'generates' */}
      {style.animated && (
        <circle r="3" fill={style.stroke} opacity={0.8}>
          <animateMotion
            id={animateId}
            dur="3s"
            repeatCount="indefinite"
            path={edgePath}
          />
        </circle>
      )}
    </>
  )
}

export const ConnectionLineRenderer = memo(ConnectionLineComponent)
