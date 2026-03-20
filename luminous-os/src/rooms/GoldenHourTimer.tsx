import { useGoldenHour } from '@/shared/hooks/useGoldenHour'
import { Play, Pause, RotateCcw, Sun, Sunset, Sparkles } from 'lucide-react'
import type { TimerPhase } from '@/shared/types/room'
import { ShareButton } from '@/shared/components/ShareButton'
import { shareableFromGoldenHour } from '@/shared/services/shareService'

interface GoldenHourTimerProps {
  totalMinutes: number
  compact?: boolean
  taskTitle?: string
}

const phaseConfig: Record<TimerPhase, {
  label: string
  icon: typeof Sun
  color: string
  bgColor: string
  description: string
}> = {
  morning: {
    label: 'Morning',
    icon: Sun,
    color: '#5C9C78',
    bgColor: 'rgba(92, 156, 120, 0.1)',
    description: 'Fresh, expansive. Begin.',
  },
  'full-day': {
    label: 'Full Day',
    icon: Sun,
    color: '#3F7A5A',
    bgColor: 'rgba(63, 122, 90, 0.08)',
    description: 'Steady, focused, sustained.',
  },
  'golden-hour': {
    label: 'Golden Hour',
    icon: Sunset,
    color: '#C5A059',
    bgColor: 'rgba(197, 160, 89, 0.12)',
    description: 'The light is beautiful right now.',
  },
  complete: {
    label: 'Complete',
    icon: Sparkles,
    color: '#C5A059',
    bgColor: 'rgba(197, 160, 89, 0.15)',
    description: 'Your work here is complete.',
  },
}

function pad(n: number): string {
  return String(n).padStart(2, '0')
}

export function GoldenHourTimer({ totalMinutes, compact = false, taskTitle = 'Deep Work' }: GoldenHourTimerProps) {
  const timer = useGoldenHour(totalMinutes)
  const config = phaseConfig[timer.phase]
  const PhaseIcon = config.icon

  // Arc for circular progress
  const radius = compact ? 28 : 56
  const circumference = 2 * Math.PI * radius
  const strokeDashoffset = circumference * (1 - timer.progress)

  // Golden hour warmth transition
  const warmth = timer.cssVars['--gh-warmth']
  const goldOpacity = timer.cssVars['--gh-gold-opacity']

  if (compact) {
    return (
      <button
        onClick={timer.toggle}
        className="relative flex items-center gap-2 px-3 py-2 rounded-full transition-all duration-500"
        style={{
          background: config.bgColor,
          border: `1px solid ${config.color}30`,
        }}
      >
        {/* Mini circular progress */}
        <div className="relative w-8 h-8">
          <svg className="w-8 h-8 -rotate-90" viewBox="0 0 64 64">
            <circle
              cx="32" cy="32" r={radius}
              fill="none"
              stroke="var(--color-border-light)"
              strokeWidth="3"
            />
            <circle
              cx="32" cy="32" r={radius}
              fill="none"
              stroke={config.color}
              strokeWidth="3"
              strokeDasharray={circumference}
              strokeDashoffset={strokeDashoffset}
              strokeLinecap="round"
              className="transition-all duration-1000"
            />
          </svg>
          <div className="absolute inset-0 flex items-center justify-center">
            <PhaseIcon size={12} style={{ color: config.color }} />
          </div>
        </div>

        <div className="text-left">
          <div className="font-sans text-[10px] font-medium" style={{ color: config.color }}>
            {config.label}
          </div>
          <div className="font-sans text-xs font-semibold tabular-nums" style={{ color: 'var(--color-text-main)' }}>
            {pad(timer.remainingMinutes)}:{pad(timer.remainingSeconds)}
          </div>
        </div>
      </button>
    )
  }

  return (
    <div
      className="flex flex-col items-center gap-4 p-6 rounded-2xl transition-all duration-[2000ms]"
      style={{
        background: `linear-gradient(135deg, ${config.bgColor}, transparent)`,
        boxShadow: timer.phase === 'golden-hour' || timer.phase === 'complete'
          ? `0 0 60px rgba(197, 160, 89, ${goldOpacity})`
          : 'none',
      }}
    >
      {/* Golden hour ambient overlay */}
      {(timer.phase === 'golden-hour' || timer.phase === 'complete') && (
        <div
          className="absolute inset-0 rounded-2xl pointer-events-none transition-opacity duration-[120000ms]"
          style={{
            background: `radial-gradient(ellipse at center, rgba(197, 160, 89, ${goldOpacity}) 0%, transparent 70%)`,
          }}
        />
      )}

      {/* Circular progress */}
      <div className="relative">
        <svg className="-rotate-90" width={160} height={160} viewBox="0 0 160 160">
          {/* Background track */}
          <circle
            cx="80" cy="80" r={radius}
            fill="none"
            stroke="var(--color-border-light)"
            strokeWidth="4"
            opacity={0.4}
          />
          {/* Progress arc */}
          <circle
            cx="80" cy="80" r={radius}
            fill="none"
            stroke={config.color}
            strokeWidth="4"
            strokeDasharray={circumference}
            strokeDashoffset={strokeDashoffset}
            strokeLinecap="round"
            className="transition-all duration-1000"
            style={{
              filter: timer.phase === 'golden-hour' || timer.phase === 'complete'
                ? `drop-shadow(0 0 8px ${config.color}80)`
                : 'none',
            }}
          />
          {/* Phase markers */}
          {[0.4, 0.8].map((mark, i) => {
            const angle = mark * 2 * Math.PI - Math.PI / 2
            const x = 80 + radius * Math.cos(angle)
            const y = 80 + radius * Math.sin(angle)
            return (
              <circle key={i} cx={x} cy={y} r="3" fill={config.color} opacity={0.4} />
            )
          })}
        </svg>

        {/* Center content */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <PhaseIcon
            size={24}
            style={{
              color: config.color,
              filter: timer.phase === 'golden-hour'
                ? 'brightness(1.1) drop-shadow(0 0 12px rgba(197, 160, 89, 0.4))'
                : 'none',
            }}
            className={timer.phase === 'complete' ? 'animate-shimmer' : ''}
          />
          <div className="font-sans text-2xl font-bold tabular-nums mt-1" style={{ color: 'var(--color-text-main)' }}>
            {pad(timer.remainingMinutes)}:{pad(timer.remainingSeconds)}
          </div>
          <div className="font-sans text-[10px] uppercase tracking-widest" style={{ color: config.color }}>
            {config.label}
          </div>
        </div>
      </div>

      {/* Phase description */}
      <p className="font-serif text-sm italic text-center" style={{ color: 'var(--color-text-muted)' }}>
        {config.description}
      </p>

      {/* Phase progress bar */}
      <div className="w-full flex gap-1">
        {['morning', 'full-day', 'golden-hour', 'complete'].map((phase) => {
          const phaseIdx = ['morning', 'full-day', 'golden-hour', 'complete'].indexOf(phase)
          const currentIdx = ['morning', 'full-day', 'golden-hour', 'complete'].indexOf(timer.phase)
          const isActive = phaseIdx === currentIdx
          const isPast = phaseIdx < currentIdx
          const pConfig = phaseConfig[phase as TimerPhase]

          return (
            <div
              key={phase}
              className="flex-1 h-1.5 rounded-full transition-all duration-1000"
              style={{
                background: isPast ? pConfig.color : isActive ? `${pConfig.color}80` : 'var(--color-border-light)',
                boxShadow: isActive ? `0 0 8px ${pConfig.color}40` : 'none',
              }}
            />
          )
        })}
      </div>

      {/* Controls */}
      <div className="flex items-center gap-3">
        <button
          onClick={timer.reset}
          className="p-2 rounded-full hover:bg-[var(--color-bg-glass)] transition-colors"
          title="Reset"
        >
          <RotateCcw size={16} style={{ color: 'var(--color-text-muted)' }} />
        </button>

        <button
          onClick={timer.toggle}
          className="p-4 rounded-full transition-all duration-300"
          style={{
            background: config.color,
            boxShadow: `0 4px 20px ${config.color}40`,
          }}
        >
          {timer.isRunning
            ? <Pause size={20} className="text-white" />
            : timer.phase === 'complete'
              ? <RotateCcw size={20} className="text-white" />
              : <Play size={20} className="text-white ml-0.5" />
          }
        </button>

        <div className="p-2">
          <span className="font-sans text-[10px] tabular-nums" style={{ color: 'var(--color-text-light)' }}>
            {pad(timer.elapsedMinutes)}:{pad(timer.elapsedSeconds)} elapsed
          </span>
        </div>
      </div>

      {/* Golden hour announcement */}
      {timer.phase === 'golden-hour' && timer.progress >= 0.8 && timer.progress < 0.82 && (
        <div
          className="px-4 py-2 rounded-full"
          style={{
            background: 'rgba(197, 160, 89, 0.15)',
            border: '1px solid rgba(197, 160, 89, 0.3)',
            animation: 'fade-in 1s ease-out',
          }}
        >
          <div className="flex items-center gap-2">
            <span className="font-serif text-xs italic" style={{ color: 'var(--color-gold-primary)' }}>
              Golden Hour has begun
            </span>
            <ShareButton
              content={shareableFromGoldenHour(taskTitle, totalMinutes, 'golden-hour')}
              compact
            />
          </div>
        </div>
      )}

      {/* Completion prompt */}
      {timer.phase === 'complete' && (
        <div
          className="text-center"
          style={{ animation: 'fade-in 1.5s ease-out' }}
        >
          <p className="font-serif text-sm" style={{ color: 'var(--color-gold-primary)' }}>
            Your work here is complete.
          </p>
          <p className="font-sans text-[10px] mt-1" style={{ color: 'var(--color-text-light)' }}>
            Preserve and return to the map?
          </p>
          <div className="mt-3">
            <ShareButton
              content={shareableFromGoldenHour(taskTitle, totalMinutes, 'complete')}
              label="Share Completion"
            />
          </div>
        </div>
      )}
    </div>
  )
}
