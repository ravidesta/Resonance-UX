import { useState } from 'react'
import { Sparkles, Users, Hand, ChevronDown, Plus } from 'lucide-react'
import type { NodeType } from '@/shared/types/node'
import { nodeTypeConfig } from '@/shared/types/node'

export type CreationMode = 'generate' | 'together' | 'myself'

interface CreationModeSelectorProps {
  mode: CreationMode
  onModeChange: (mode: CreationMode) => void
  onCreateNode: (type: NodeType, title: string) => void
}

const modeConfig: Record<CreationMode, { label: string; description: string; icon: typeof Sparkles }> = {
  generate: { label: 'Generate for me', description: 'AI creates the structure', icon: Sparkles },
  together: { label: "Let's do this together", description: 'AI suggests, you decide', icon: Users },
  myself: { label: 'All by myself', description: 'Full manual control', icon: Hand },
}

export function CreationModeSelector({ mode, onModeChange, onCreateNode }: CreationModeSelectorProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [showCreate, setShowCreate] = useState(false)
  const [newTitle, setNewTitle] = useState('')
  const [newType, setNewType] = useState<NodeType>('task')
  const current = modeConfig[mode]
  const ModeIcon = current.icon

  const nodeTypes: NodeType[] = ['portfolio', 'campaign', 'project', 'task', 'app', 'person', 'document', 'book', 'course', 'album']

  return (
    <div className="fixed top-6 right-6 z-30 flex flex-col items-end gap-2">
      {/* Mode selector */}
      <div className="relative">
        <button
          onClick={() => setIsOpen(!isOpen)}
          className="glass-panel rounded-2xl px-4 py-2.5 flex items-center gap-2 hover:shadow-[var(--shadow-card-hover)] transition-all"
          style={{ boxShadow: 'var(--shadow-card)' }}
        >
          <ModeIcon size={14} style={{ color: 'var(--color-gold-primary)' }} />
          <span className="font-sans text-xs font-medium" style={{ color: 'var(--color-text-main)' }}>
            {current.label}
          </span>
          <ChevronDown size={12} style={{ color: 'var(--color-text-light)', transform: isOpen ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s' }} />
        </button>

        {isOpen && (
          <>
            <div className="fixed inset-0 z-40" onClick={() => setIsOpen(false)} />
            <div
              className="absolute right-0 mt-2 z-50 glass-panel rounded-xl overflow-hidden"
              style={{ boxShadow: 'var(--shadow-glass)', minWidth: 240, animation: 'fade-in 0.15s ease-out' }}
            >
              {(Object.keys(modeConfig) as CreationMode[]).map(m => {
                const cfg = modeConfig[m]
                const Icon = cfg.icon
                const isActive = mode === m
                return (
                  <button
                    key={m}
                    className={`w-full px-4 py-3 flex items-center gap-3 hover:bg-[var(--color-bg-glass)] transition-colors text-left ${isActive ? 'bg-[var(--color-bg-glass)]' : ''}`}
                    onClick={() => { onModeChange(m); setIsOpen(false) }}
                  >
                    <Icon size={16} style={{ color: isActive ? 'var(--color-gold-primary)' : 'var(--color-text-muted)' }} />
                    <div>
                      <div className="font-sans text-xs font-medium" style={{ color: 'var(--color-text-main)' }}>{cfg.label}</div>
                      <div className="font-sans text-[10px]" style={{ color: 'var(--color-text-light)' }}>{cfg.description}</div>
                    </div>
                    {isActive && <span className="ml-auto text-[10px]" style={{ color: 'var(--color-gold-primary)' }}>●</span>}
                  </button>
                )
              })}
            </div>
          </>
        )}
      </div>

      {/* Create node button */}
      <button
        onClick={() => setShowCreate(!showCreate)}
        className="glass-panel rounded-full w-12 h-12 flex items-center justify-center hover:shadow-[var(--shadow-card-hover)] transition-all"
        style={{ boxShadow: 'var(--shadow-card)', background: 'var(--color-gold-primary)' }}
      >
        <Plus size={20} className="text-white" style={{ transform: showCreate ? 'rotate(45deg)' : 'none', transition: 'transform 0.2s' }} />
      </button>

      {/* Create node panel */}
      {showCreate && (
        <>
          <div className="fixed inset-0 z-30" onClick={() => setShowCreate(false)} />
          <div
            className="relative z-40 glass-panel rounded-xl p-4"
            style={{ boxShadow: 'var(--shadow-glass)', width: 280, animation: 'fade-in 0.15s ease-out' }}
          >
            <div className="font-serif text-sm font-semibold mb-3" style={{ color: 'var(--color-text-main)' }}>
              Create New Node
            </div>

            {/* Node type grid */}
            <div className="grid grid-cols-5 gap-1.5 mb-3">
              {nodeTypes.map(type => {
                const cfg = nodeTypeConfig[type]
                const isSelected = newType === type
                return (
                  <button
                    key={type}
                    onClick={() => setNewType(type)}
                    className={`flex flex-col items-center gap-0.5 p-2 rounded-lg transition-all ${isSelected ? 'ring-1' : 'hover:bg-[var(--color-bg-glass)]'}`}
                    style={{
                      background: isSelected ? `${cfg.color}15` : undefined,
                      borderColor: isSelected ? cfg.color : undefined,
                    }}
                  >
                    <div
                      className="w-6 h-6 rounded-full flex items-center justify-center"
                      style={{ background: `${cfg.color}20` }}
                    >
                      <span style={{ fontSize: 10 }}>
                        {cfg.label.charAt(0)}
                      </span>
                    </div>
                    <span className="font-sans text-[7px]" style={{ color: 'var(--color-text-light)' }}>
                      {cfg.label}
                    </span>
                  </button>
                )
              })}
            </div>

            {/* Title input */}
            <input
              type="text"
              value={newTitle}
              onChange={e => setNewTitle(e.target.value)}
              placeholder={nodeTypeConfig[newType].humorousLabel}
              className="w-full px-3 py-2 rounded-lg font-sans text-xs mb-3 outline-none"
              style={{
                background: 'var(--color-bg-glass)',
                border: '1px solid var(--color-border-light)',
                color: 'var(--color-text-main)',
              }}
              onKeyDown={e => {
                if (e.key === 'Enter' && newTitle.trim()) {
                  onCreateNode(newType, newTitle.trim())
                  setNewTitle('')
                  setShowCreate(false)
                }
              }}
              autoFocus
            />

            {/* Create button */}
            <button
              onClick={() => {
                if (newTitle.trim()) {
                  onCreateNode(newType, newTitle.trim())
                  setNewTitle('')
                  setShowCreate(false)
                }
              }}
              className="w-full py-2 rounded-lg font-sans text-xs font-medium transition-all"
              style={{
                background: newTitle.trim() ? 'var(--color-gold-primary)' : 'var(--color-bg-glass)',
                color: newTitle.trim() ? '#fff' : 'var(--color-text-light)',
              }}
            >
              {mode === 'generate' ? 'Generate' : mode === 'together' ? 'Create Together' : 'Create'}
            </button>
          </div>
        </>
      )}
    </div>
  )
}
