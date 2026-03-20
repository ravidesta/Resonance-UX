import { memo, type FC } from 'react'
import { Handle, Position, type NodeProps } from '@xyflow/react'
import * as Icons from 'lucide-react'
import type { LuminousNode, NodeType } from '@/shared/types/node'
import { nodeTypeConfig } from '@/shared/types/node'
import { statusConfig } from '@/shared/design/lexicon'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type LucideIcon = FC<any>

function getIcon(iconName: string): LucideIcon {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const Icon = (Icons as any)[iconName] as LucideIcon | undefined
  return Icon || Icons.Circle
}

function getNodeShape(type: NodeType): 'circle' | 'rounded' {
  switch (type) {
    case 'portfolio':
    case 'person':
    case 'album':
      return 'circle'
    default:
      return 'rounded'
  }
}

export interface MindNodeData extends Record<string, unknown> {
  node: LuminousNode
  altitude: number
  onEnterRoom?: (taskId: string) => void
}

function MindNodeComponent({ data }: NodeProps & { data: MindNodeData }) {
  const { node, altitude } = data
  const config = nodeTypeConfig[node.type]
  const status = statusConfig[node.status]
  const IconComponent = getIcon(node.icon || config.defaultIcon)
  const shape = getNodeShape(node.type)

  // Scale node size based on altitude and type
  const altitudeScale = Math.max(0.5, 1 - (altitude * 0.08))
  const baseSize = config.baseSize * altitudeScale
  const isCircle = shape === 'circle'

  // Show detail based on altitude
  const showTitle = altitude <= 4
  const showMeta = altitude <= 2
  const showToolBadges = altitude <= 1 && node.type === 'task'
  const showDescription = altitude <= 1

  // Status-based styling
  const isAnimated = status.animate && (node.status === 'growing' || node.status === 'flowering')
  const isComposting = node.status === 'composting'

  return (
    <div
      className="relative group"
      style={{ width: baseSize, height: isCircle ? baseSize : 'auto', minHeight: isCircle ? baseSize : baseSize * 0.6 }}
    >
      {/* Glow ring */}
      {status.glowColor !== 'transparent' && (
        <div
          className={`absolute inset-[-4px] ${isCircle ? 'rounded-full' : 'rounded-[20px]'} ${isAnimated ? 'animate-pulse-gold' : ''}`}
          style={{
            background: status.glowColor,
            filter: 'blur(8px)',
            opacity: isAnimated ? 1 : 0.6,
          }}
        />
      )}

      {/* Main node body */}
      <div
        className={`
          relative glass-card cursor-pointer
          ${isCircle ? 'rounded-full' : 'rounded-[16px]'}
          flex flex-col items-center justify-center gap-1 p-3
          transition-all duration-300 ease-out
          hover:shadow-[var(--shadow-node-hover)]
          ${isComposting ? 'opacity-40' : ''}
        `}
        style={{
          width: '100%',
          height: isCircle ? '100%' : 'auto',
          minHeight: isCircle ? '100%' : baseSize * 0.6,
          borderColor: status.borderColor,
          boxShadow: 'var(--shadow-node)',
          background: `${status.bgTint}, var(--color-bg-glass-card)`,
        }}
        onDoubleClick={() => {
          if (node.type === 'task' && data.onEnterRoom) {
            data.onEnterRoom(node.id)
          }
        }}
      >
        {/* Icon */}
        <div
          className="flex items-center justify-center rounded-full"
          style={{
            width: Math.max(28, baseSize * 0.3),
            height: Math.max(28, baseSize * 0.3),
            background: `${config.color}20`,
          }}
        >
          <IconComponent
            size={Math.max(16, baseSize * 0.17)}
            className="transition-colors duration-300"
            strokeWidth={1.5}
            color={config.color}
          />
        </div>

        {/* Title */}
        {showTitle && (
          <span
            className="font-serif font-semibold text-center leading-tight"
            style={{
              fontSize: Math.max(10, Math.min(14, baseSize * 0.1)),
              color: 'var(--color-text-main)',
              maxWidth: baseSize - 16,
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              display: '-webkit-box',
              WebkitLineClamp: 2,
              WebkitBoxOrient: 'vertical',
            }}
          >
            {node.title}
          </span>
        )}

        {/* Status label */}
        {showMeta && (
          <span
            className="font-sans uppercase tracking-widest"
            style={{
              fontSize: 8,
              color: 'var(--color-text-light)',
              letterSpacing: '0.12em',
            }}
          >
            {status.label}
          </span>
        )}

        {/* Description */}
        {showDescription && node.description && (
          <span
            className="font-sans text-center"
            style={{
              fontSize: 9,
              color: 'var(--color-text-muted)',
              maxWidth: baseSize - 20,
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
            }}
          >
            {node.description}
          </span>
        )}

        {/* Tool badges for tasks */}
        {showToolBadges && node.aiContext.suggestedTools.length > 0 && (
          <div className="flex gap-1 flex-wrap justify-center mt-1">
            {node.aiContext.suggestedTools.slice(0, 3).map((tool, i) => (
              <span
                key={i}
                className="font-sans px-1.5 py-0.5 rounded-full"
                style={{
                  fontSize: 7,
                  background: 'var(--color-bg-glass)',
                  color: 'var(--color-text-muted)',
                  border: '1px solid var(--color-border-light)',
                }}
              >
                {tool}
              </span>
            ))}
          </div>
        )}

        {/* Children count badge */}
        {node.children.length > 0 && altitude >= 2 && (
          <div
            className="absolute -bottom-1 -right-1 rounded-full flex items-center justify-center font-sans font-semibold"
            style={{
              width: 18,
              height: 18,
              fontSize: 9,
              background: config.color,
              color: '#fff',
              boxShadow: '0 2px 6px rgba(0,0,0,0.15)',
            }}
          >
            {node.children.length}
          </div>
        )}

        {/* Task enter-room indicator */}
        {node.type === 'task' && altitude <= 1 && (
          <div
            className="absolute -bottom-2 left-1/2 -translate-x-1/2 font-sans uppercase tracking-widest opacity-0 group-hover:opacity-100 transition-opacity"
            style={{
              fontSize: 7,
              color: 'var(--color-gold-primary)',
              whiteSpace: 'nowrap',
            }}
          >
            double-click to enter room
          </div>
        )}
      </div>

      {/* Handles for connections */}
      <Handle type="target" position={Position.Top} className="!bg-transparent !border-0 !w-3 !h-3" />
      <Handle type="source" position={Position.Bottom} className="!bg-transparent !border-0 !w-3 !h-3" />
      <Handle type="target" position={Position.Left} id="left" className="!bg-transparent !border-0 !w-3 !h-3" />
      <Handle type="source" position={Position.Right} id="right" className="!bg-transparent !border-0 !w-3 !h-3" />
    </div>
  )
}

export const MindNodeRenderer = memo(MindNodeComponent)
