import { useState, useEffect } from 'react'
import { ArrowLeft, PanelRightClose, PanelRightOpen } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import * as Icons from 'lucide-react'
import type { LuminousNode } from '@/shared/types/node'
import type { RoomVibe } from '@/shared/types/room'
import { roomVibes } from '@/shared/types/room'
import { statusConfig } from '@/shared/design/lexicon'
import { GoldenHourTimer } from './GoldenHourTimer'
import { OrganicBlobs, PaperNoise } from '@/shared/design/GlobalStyles'
import { ShareButton } from '@/shared/components/ShareButton'
import { shareableFromRoomVibe, shareableFromGoldenHour } from '@/shared/services/shareService'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type LucideIcon = React.FC<any>

function getIcon(name: string): LucideIcon {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (Icons as any)[name] as LucideIcon || Icons.Circle
}

interface RoomProps {
  taskNode: LuminousNode
  onExit: () => void
}

export function Room({ taskNode, onExit }: RoomProps) {
  const [contextOpen, setContextOpen] = useState(true)
  const [activeApp, setActiveApp] = useState(0)
  const [vibe, setVibe] = useState<RoomVibe>(taskNode.backgroundEnvironment as RoomVibe || 'smooth-vellum')
  const [entered, setEntered] = useState(false)

  const vibeConfig = roomVibes[vibe]
  const apps = taskNode.links.apps.length > 0
    ? taskNode.links.apps
    : taskNode.aiContext.suggestedTools.length > 0
      ? taskNode.aiContext.suggestedTools
      : ['Sanctuary Writer', 'Claude', 'Notes']

  // Entrance animation
  useEffect(() => {
    const timer = setTimeout(() => setEntered(true), 100)
    return () => clearTimeout(timer)
  }, [])

  return (
    <AnimatePresence>
      <motion.div
        className="fixed inset-0 z-50 flex flex-col overflow-hidden"
        style={{ background: vibeConfig.bgGradient }}
        initial={{ opacity: 0, scale: 1.5 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.8 }}
        transition={{ duration: 1.5, ease: [0.165, 0.84, 0.44, 1] }}
      >
        {/* Living background */}
        <OrganicBlobs />
        <PaperNoise />

        {/* Header bar */}
        <motion.div
          className="relative z-20 flex items-center justify-between px-6 py-4"
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: entered ? 1 : 0, y: entered ? 0 : -20 }}
          transition={{ delay: 0.5, duration: 0.5 }}
        >
          <div className="flex items-center gap-3">
            <button
              onClick={onExit}
              className="p-2 rounded-xl glass-card hover:bg-[var(--color-bg-glass)] transition-colors"
            >
              <ArrowLeft size={16} style={{ color: 'var(--color-text-main)' }} />
            </button>
            <div>
              <h2 className="font-serif text-lg font-semibold" style={{ color: 'var(--color-text-main)' }}>
                {taskNode.title}
              </h2>
              <div className="flex items-center gap-2">
                <span
                  className="font-sans text-[10px] uppercase tracking-widest"
                  style={{ color: statusConfig[taskNode.status].borderColor }}
                >
                  {statusConfig[taskNode.status].label}
                </span>
                <span className="font-sans text-[10px]" style={{ color: 'var(--color-text-light)' }}>·</span>
                <span className="font-sans text-[10px]" style={{ color: 'var(--color-text-light)' }}>
                  {taskNode.calendar.goldenHourMinutes}m session
                </span>
              </div>
            </div>
          </div>

          {/* Vibe selector */}
          <div className="flex items-center gap-1">
            {(Object.keys(roomVibes) as RoomVibe[]).map(v => (
              <button
                key={v}
                onClick={() => setVibe(v)}
                className={`w-5 h-5 rounded-full transition-all ${v === vibe ? 'ring-2 ring-offset-1 scale-110' : 'opacity-50 hover:opacity-100'}`}
                style={{
                  background: roomVibes[v].accentColor,
                  borderColor: v === vibe ? roomVibes[v].accentColor : undefined,
                }}
                title={roomVibes[v].label}
              />
            ))}
          </div>
        </motion.div>

        {/* Main content area */}
        <div className="relative z-10 flex flex-1 overflow-hidden">
          {/* App Dock (left) */}
          <motion.div
            className="flex flex-col gap-2 p-3"
            initial={{ opacity: 0, x: -40 }}
            animate={{ opacity: entered ? 1 : 0, x: entered ? 0 : -40 }}
            transition={{ delay: 0.7, duration: 0.5 }}
          >
            {apps.map((app, i) => {
              const isActive = i === activeApp
              return (
                <button
                  key={app}
                  onClick={() => setActiveApp(i)}
                  className={`p-3 rounded-xl transition-all duration-300 ${isActive ? 'glass-panel' : 'hover:bg-[var(--color-bg-glass)]'}`}
                  style={{
                    boxShadow: isActive ? 'var(--shadow-card)' : 'none',
                    border: isActive ? `1px solid ${vibeConfig.accentColor}40` : '1px solid transparent',
                  }}
                  title={app}
                >
                  <div
                    className="w-8 h-8 rounded-lg flex items-center justify-center font-sans text-xs font-bold"
                    style={{
                      background: isActive ? `${vibeConfig.accentColor}20` : 'var(--color-bg-glass)',
                      color: isActive ? vibeConfig.accentColor : 'var(--color-text-muted)',
                    }}
                  >
                    {app.charAt(0).toUpperCase()}
                  </div>
                </button>
              )
            })}
          </motion.div>

          {/* Primary Workspace (center) */}
          <motion.div
            className="flex-1 m-2 rounded-2xl glass-panel overflow-hidden relative"
            style={{ boxShadow: 'var(--shadow-glass)' }}
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: entered ? 1 : 0, scale: entered ? 1 : 0.95 }}
            transition={{ delay: 0.8, duration: 0.6 }}
          >
            {/* App content placeholder */}
            <div className="flex flex-col items-center justify-center h-full gap-4">
              <div
                className="w-16 h-16 rounded-2xl flex items-center justify-center"
                style={{ background: `${vibeConfig.accentColor}15` }}
              >
                <span className="font-serif text-2xl" style={{ color: vibeConfig.accentColor }}>
                  {apps[activeApp]?.charAt(0).toUpperCase() || '?'}
                </span>
              </div>
              <div className="text-center">
                <h3 className="font-serif text-lg" style={{ color: 'var(--color-text-main)' }}>
                  {apps[activeApp] || 'Workspace'}
                </h3>
                <p className="font-sans text-xs" style={{ color: 'var(--color-text-muted)' }}>
                  App workspace ready
                </p>
              </div>

              {/* Inline writing area */}
              <div className="w-full max-w-xl px-8">
                <textarea
                  className="w-full h-48 bg-transparent border-none outline-none resize-none font-serif text-base leading-relaxed"
                  style={{ color: 'var(--color-text-main)', caretColor: vibeConfig.accentColor }}
                  placeholder="Begin writing here... your room is assembled."
                />
              </div>
            </div>
          </motion.div>

          {/* Context Panel (right) */}
          <AnimatePresence>
            {contextOpen && (
              <motion.div
                className="w-72 p-3 flex flex-col gap-3 overflow-y-auto hide-scrollbar"
                initial={{ opacity: 0, x: 40 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 40 }}
                transition={{ duration: 0.3 }}
              >
                {/* Toggle button */}
                <button
                  onClick={() => setContextOpen(false)}
                  className="self-end p-1.5 rounded-lg hover:bg-[var(--color-bg-glass)] transition-colors"
                >
                  <PanelRightClose size={14} style={{ color: 'var(--color-text-muted)' }} />
                </button>

                {/* Timer */}
                <div className="glass-card rounded-2xl p-4">
                  <GoldenHourTimer totalMinutes={taskNode.calendar.goldenHourMinutes} taskTitle={taskNode.title} />
                </div>

                {/* Links */}
                {taskNode.links.urls.length > 0 && (
                  <div className="glass-card rounded-xl p-3">
                    <h4 className="font-sans text-[9px] uppercase tracking-widest mb-2" style={{ color: 'var(--color-text-light)' }}>
                      Links
                    </h4>
                    {taskNode.links.urls.map((link, i) => (
                      <a
                        key={i}
                        href={link.href}
                        className="block py-1.5 px-2 rounded-lg hover:bg-[var(--color-bg-glass)] transition-colors font-sans text-xs"
                        style={{ color: 'var(--color-text-main)' }}
                      >
                        {link.label}
                      </a>
                    ))}
                  </div>
                )}

                {/* AI Suggestions */}
                {taskNode.aiContext.suggestedTools.length > 0 && (
                  <div className="glass-card rounded-xl p-3">
                    <h4 className="font-sans text-[9px] uppercase tracking-widest mb-2" style={{ color: 'var(--color-text-light)' }}>
                      AI Recommendations
                    </h4>
                    <div className="space-y-1">
                      {taskNode.aiContext.suggestedTools.map((tool, i) => (
                        <div key={i} className="flex items-center gap-2 py-1">
                          <div className="w-1.5 h-1.5 rounded-full" style={{ background: vibeConfig.accentColor }} />
                          <span className="font-sans text-xs" style={{ color: 'var(--color-text-main)' }}>{tool}</span>
                        </div>
                      ))}
                    </div>
                    {taskNode.aiContext.estimatedMinutes > 0 && (
                      <div className="mt-2 pt-2 border-t" style={{ borderColor: 'var(--color-border-light)' }}>
                        <span className="font-sans text-[10px]" style={{ color: 'var(--color-text-light)' }}>
                          Estimated: {Math.round(taskNode.aiContext.estimatedMinutes / 60)}h {taskNode.aiContext.estimatedMinutes % 60}m
                        </span>
                      </div>
                    )}
                  </div>
                )}

                {/* Description */}
                {taskNode.description && (
                  <div className="glass-card rounded-xl p-3">
                    <h4 className="font-sans text-[9px] uppercase tracking-widest mb-2" style={{ color: 'var(--color-text-light)' }}>
                      About This Task
                    </h4>
                    <p className="font-sans text-xs leading-relaxed" style={{ color: 'var(--color-text-muted)' }}>
                      {taskNode.description}
                    </p>
                  </div>
                )}

                {/* Vibe info */}
                <div className="glass-card rounded-xl p-3">
                  <div className="flex items-center justify-between mb-2">
                    <h4 className="font-sans text-[9px] uppercase tracking-widest" style={{ color: 'var(--color-text-light)' }}>
                      Room Vibe
                    </h4>
                    <ShareButton
                      content={shareableFromRoomVibe(vibe, taskNode.title)}
                      compact
                    />
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-4 h-4 rounded-full" style={{ background: vibeConfig.accentColor }} />
                    <div>
                      <div className="font-sans text-xs font-medium" style={{ color: 'var(--color-text-main)' }}>
                        {vibeConfig.label}
                      </div>
                      <div className="font-sans text-[10px]" style={{ color: 'var(--color-text-light)' }}>
                        {vibeConfig.description}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Share this session */}
                <ShareButton
                  content={shareableFromGoldenHour(taskNode.title, taskNode.calendar.goldenHourMinutes, 'morning')}
                  label="Share Session"
                />
              </motion.div>
            )}
          </AnimatePresence>

          {/* Context panel toggle (when closed) */}
          {!contextOpen && (
            <button
              onClick={() => setContextOpen(true)}
              className="absolute right-3 top-3 p-2 rounded-xl glass-card hover:bg-[var(--color-bg-glass)] transition-colors z-20"
            >
              <PanelRightOpen size={14} style={{ color: 'var(--color-text-muted)' }} />
            </button>
          )}
        </div>

        {/* Bottom bar */}
        <motion.div
          className="relative z-20 flex items-center justify-between px-6 py-3 border-t"
          style={{ borderColor: 'var(--color-border-light)' }}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: entered ? 1 : 0, y: entered ? 0 : 20 }}
          transition={{ delay: 1, duration: 0.4 }}
        >
          <GoldenHourTimer totalMinutes={taskNode.calendar.goldenHourMinutes} taskTitle={taskNode.title} compact />

          <div className="flex items-center gap-3">
            {/* Quick links */}
            {taskNode.links.urls.slice(0, 3).map((link, i) => (
              <a
                key={i}
                href={link.href}
                className="font-sans text-[10px] px-2 py-1 rounded-full hover:bg-[var(--color-bg-glass)] transition-colors"
                style={{ color: 'var(--color-text-muted)', border: '1px solid var(--color-border-light)' }}
              >
                {link.label}
              </a>
            ))}
          </div>
        </motion.div>

        {/* Gold shimmer on entrance */}
        {!entered && (
          <motion.div
            className="absolute inset-0 pointer-events-none z-30"
            initial={{ opacity: 0.6 }}
            animate={{ opacity: 0 }}
            transition={{ delay: 1.2, duration: 0.8 }}
            style={{
              background: 'radial-gradient(ellipse at center, rgba(197, 160, 89, 0.15) 0%, transparent 70%)',
            }}
          />
        )}
      </motion.div>
    </AnimatePresence>
  )
}
