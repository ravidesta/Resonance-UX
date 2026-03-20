import { useState, useCallback } from 'react'
import { Sun, Moon, CreditCard } from 'lucide-react'
import { AnimatePresence } from 'framer-motion'

import { MindMap } from '@/mind/MindMap'
import { Room } from '@/rooms/Room'
import { mockNodes, mockConnections } from '@/shared/services/mockData'
import { pricingTiers } from '@/shared/services/appRegistry'
import type { LuminousNode } from '@/shared/types/node'

type View = 'mind' | 'room'

export default function App() {
  const [view, setView] = useState<View>('mind')
  const [theme, setTheme] = useState<'sunlit' | 'deep-rest'>('sunlit')
  const [activeRoomTask, setActiveRoomTask] = useState<LuminousNode | null>(null)
  const [showPricing, setShowPricing] = useState(false)

  const handleEnterRoom = useCallback((taskId: string) => {
    const task = mockNodes.find(n => n.id === taskId)
    if (task) {
      setActiveRoomTask(task)
      setView('room')
    }
  }, [])

  const handleExitRoom = useCallback(() => {
    setView('mind')
    setActiveRoomTask(null)
  }, [])

  const toggleTheme = useCallback(() => {
    setTheme(prev => {
      const next = prev === 'sunlit' ? 'deep-rest' : 'sunlit'
      if (next === 'deep-rest') document.documentElement.classList.add('theme-deep')
      else document.documentElement.classList.remove('theme-deep')
      return next
    })
  }, [])

  return (
    <div className="w-screen h-screen relative overflow-hidden" style={{ background: 'var(--color-bg-base)' }}>
      {/* Mind Map (primary view) */}
      {view === 'mind' && (
        <MindMap
          initialNodes={mockNodes}
          initialConnections={mockConnections}
          onEnterRoom={handleEnterRoom}
        />
      )}

      {/* Room overlay */}
      <AnimatePresence>
        {view === 'room' && activeRoomTask && (
          <Room taskNode={activeRoomTask} onExit={handleExitRoom} />
        )}
      </AnimatePresence>

      {/* Theme toggle */}
      <button
        onClick={toggleTheme}
        className="fixed bottom-6 right-6 z-40 p-3 rounded-full glass-panel transition-all hover:shadow-[var(--shadow-card-hover)]"
        style={{ boxShadow: 'var(--shadow-card)' }}
        title={theme === 'sunlit' ? 'Switch to Deep Rest' : 'Switch to Sunlit'}
      >
        {theme === 'sunlit'
          ? <Moon size={16} style={{ color: 'var(--color-green-700)' }} />
          : <Sun size={16} style={{ color: 'var(--color-gold-primary)' }} />
        }
      </button>

      {/* Pricing dropdown */}
      <button
        onClick={() => setShowPricing(!showPricing)}
        className="fixed bottom-6 right-20 z-40 px-3 py-2.5 rounded-full glass-panel transition-all hover:shadow-[var(--shadow-card-hover)] flex items-center gap-2"
        style={{ boxShadow: 'var(--shadow-card)' }}
      >
        <CreditCard size={14} style={{ color: 'var(--color-gold-primary)' }} />
        <span className="font-sans text-[10px] font-medium" style={{ color: 'var(--color-text-main)' }}>
          Upgrade
        </span>
      </button>

      {showPricing && (
        <>
          <div className="fixed inset-0 z-50 bg-black/20 backdrop-blur-sm" onClick={() => setShowPricing(false)} />
          <div
            className="fixed bottom-20 right-6 z-50 glass-panel rounded-2xl p-4 w-80"
            style={{ boxShadow: 'var(--shadow-glass)', animation: 'fade-in 0.2s ease-out' }}
          >
            <h3 className="font-serif text-base font-semibold mb-3" style={{ color: 'var(--color-text-main)' }}>
              Luminous Plans
            </h3>
            <div className="space-y-2">
              {pricingTiers.map(tier => (
                <div
                  key={tier.id}
                  className="p-3 rounded-xl cursor-pointer hover:bg-[var(--color-bg-glass)] transition-colors"
                  style={{ border: '1px solid var(--color-border-light)' }}
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="font-sans text-xs font-semibold" style={{ color: 'var(--color-text-main)' }}>
                        {tier.name}
                      </div>
                      <div className="font-sans text-[10px]" style={{ color: 'var(--color-text-light)' }}>
                        {tier.description}
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="font-sans text-sm font-bold" style={{ color: 'var(--color-gold-primary)' }}>
                        ${tier.price}
                      </div>
                      {tier.price > 0 && (
                        <div className="font-sans text-[9px]" style={{ color: 'var(--color-text-light)' }}>/month</div>
                      )}
                    </div>
                  </div>
                  <div className="mt-2 flex flex-wrap gap-1">
                    {tier.features.slice(0, 3).map((f, i) => (
                      <span
                        key={i}
                        className="font-sans text-[8px] px-1.5 py-0.5 rounded-full"
                        style={{
                          background: 'var(--color-bg-glass)',
                          color: 'var(--color-text-muted)',
                        }}
                      >
                        {f}
                      </span>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </>
      )}
    </div>
  )
}
