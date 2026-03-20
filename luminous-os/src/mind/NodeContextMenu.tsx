import { type FC } from 'react'
import {
  Calendar, Clock, ArrowRightCircle, Sprout, Leaf, Sun,
  Flower2, Apple, Recycle, Trash2, Edit3, Copy
} from 'lucide-react'
import type { LuminousNode, NodeStatus } from '@/shared/types/node'
import { statusConfig } from '@/shared/design/lexicon'

interface ContextMenuProps {
  node: LuminousNode
  position: { x: number; y: number }
  onClose: () => void
  onStatusChange: (id: string, status: NodeStatus) => void
  onEnterRoom: (taskId: string) => void
  onDelete: (id: string) => void
  onShowCalendar: (node: LuminousNode) => void
}

const statusIcons: Record<NodeStatus, FC<{ size?: number }>> = {
  dormant: Sprout,
  germinating: Leaf,
  growing: Sun,
  flowering: Flower2,
  harvested: Apple,
  composting: Recycle,
}

export function NodeContextMenu({
  node, position, onClose, onStatusChange, onEnterRoom, onDelete, onShowCalendar
}: ContextMenuProps) {
  const allStatuses: NodeStatus[] = ['dormant', 'germinating', 'growing', 'flowering', 'harvested', 'composting']

  return (
    <>
      {/* Backdrop */}
      <div className="fixed inset-0 z-40" onClick={onClose} />

      {/* Menu */}
      <div
        className="fixed z-50 glass-panel rounded-xl shadow-lg overflow-hidden"
        style={{
          left: position.x,
          top: position.y,
          minWidth: 220,
          animation: 'fade-in 0.15s ease-out',
        }}
      >
        {/* Header */}
        <div className="px-3 py-2 border-b" style={{ borderColor: 'var(--color-border-light)' }}>
          <div className="font-serif font-semibold text-sm" style={{ color: 'var(--color-text-main)' }}>
            {node.title}
          </div>
          <div className="font-sans text-[9px] uppercase tracking-widest" style={{ color: 'var(--color-text-light)' }}>
            {node.type} · {statusConfig[node.status].label}
          </div>
        </div>

        {/* Actions */}
        <div className="py-1">
          {/* This Week */}
          <button
            className="w-full px-3 py-2 flex items-center gap-2 hover:bg-[var(--color-bg-glass)] transition-colors text-left"
            onClick={() => { onShowCalendar(node); onClose() }}
          >
            <Calendar size={14} style={{ color: 'var(--color-gold-primary)' }} />
            <span className="font-sans text-xs" style={{ color: 'var(--color-text-main)' }}>This Week</span>
          </button>

          {/* Enter Room (tasks only) */}
          {node.type === 'task' && (
            <button
              className="w-full px-3 py-2 flex items-center gap-2 hover:bg-[var(--color-bg-glass)] transition-colors text-left"
              onClick={() => { onEnterRoom(node.id); onClose() }}
            >
              <ArrowRightCircle size={14} style={{ color: 'var(--color-gold-primary)' }} />
              <span className="font-sans text-xs" style={{ color: 'var(--color-text-main)' }}>Enter Room</span>
            </button>
          )}

          {/* Timeline */}
          <button
            className="w-full px-3 py-2 flex items-center gap-2 hover:bg-[var(--color-bg-glass)] transition-colors text-left"
            onClick={onClose}
          >
            <Clock size={14} style={{ color: 'var(--color-text-muted)' }} />
            <span className="font-sans text-xs" style={{ color: 'var(--color-text-main)' }}>Timeline</span>
          </button>

          <div className="mx-3 my-1 border-t" style={{ borderColor: 'var(--color-border-light)' }} />

          {/* Status submenu */}
          <div className="px-3 py-1">
            <span className="font-sans text-[9px] uppercase tracking-widest" style={{ color: 'var(--color-text-light)' }}>
              Change Status
            </span>
          </div>
          {allStatuses.map(s => {
            const StatusIcon = statusIcons[s]
            const cfg = statusConfig[s]
            const isActive = node.status === s
            return (
              <button
                key={s}
                className={`w-full px-3 py-1.5 flex items-center gap-2 hover:bg-[var(--color-bg-glass)] transition-colors text-left ${isActive ? 'opacity-100' : 'opacity-60 hover:opacity-100'}`}
                onClick={() => { onStatusChange(node.id, s); onClose() }}
              >
                <StatusIcon size={12} />
                <span className="font-sans text-xs" style={{ color: 'var(--color-text-main)' }}>
                  {cfg.label}
                </span>
                {isActive && (
                  <span className="ml-auto text-[8px]" style={{ color: 'var(--color-gold-primary)' }}>●</span>
                )}
              </button>
            )
          })}

          <div className="mx-3 my-1 border-t" style={{ borderColor: 'var(--color-border-light)' }} />

          {/* Edit / Duplicate / Delete */}
          <button
            className="w-full px-3 py-2 flex items-center gap-2 hover:bg-[var(--color-bg-glass)] transition-colors text-left"
            onClick={onClose}
          >
            <Edit3 size={14} style={{ color: 'var(--color-text-muted)' }} />
            <span className="font-sans text-xs" style={{ color: 'var(--color-text-main)' }}>Edit Node</span>
          </button>
          <button
            className="w-full px-3 py-2 flex items-center gap-2 hover:bg-[var(--color-bg-glass)] transition-colors text-left"
            onClick={onClose}
          >
            <Copy size={14} style={{ color: 'var(--color-text-muted)' }} />
            <span className="font-sans text-xs" style={{ color: 'var(--color-text-main)' }}>Duplicate</span>
          </button>
          <button
            className="w-full px-3 py-2 flex items-center gap-2 hover:bg-[var(--color-bg-glass)] transition-colors text-left"
            onClick={() => { onDelete(node.id); onClose() }}
          >
            <Trash2 size={14} style={{ color: '#C45050' }} />
            <span className="font-sans text-xs" style={{ color: '#C45050' }}>Delete</span>
          </button>
        </div>
      </div>
    </>
  )
}
