import type { LuminousNode } from '@/shared/types/node'
import { X, Clock, Plus } from 'lucide-react'

interface NodeCalendarProps {
  node: LuminousNode
  onClose: () => void
}

const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
const HOURS = Array.from({ length: 12 }, (_, i) => i + 7) // 7am to 6pm

function getWeekDates(): Date[] {
  const now = new Date()
  const dayOfWeek = now.getDay()
  const monday = new Date(now)
  monday.setDate(now.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1))
  return Array.from({ length: 7 }, (_, i) => {
    const d = new Date(monday)
    d.setDate(monday.getDate() + i)
    return d
  })
}

export function NodeCalendar({ node, onClose }: NodeCalendarProps) {
  const weekDates = getWeekDates()

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center" onClick={onClose}>
      <div className="absolute inset-0 bg-black/20 backdrop-blur-sm" />

      <div
        className="relative glass-panel rounded-2xl p-5 max-w-lg w-full mx-4"
        style={{
          boxShadow: 'var(--shadow-glass)',
          animation: 'fade-in 0.2s ease-out',
        }}
        onClick={e => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="font-serif text-lg font-semibold" style={{ color: 'var(--color-text-main)' }}>
              {node.title}
            </h3>
            <p className="font-sans text-xs" style={{ color: 'var(--color-text-muted)' }}>
              This Week
            </p>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full hover:bg-[var(--color-bg-glass)] transition-colors"
          >
            <X size={16} style={{ color: 'var(--color-text-muted)' }} />
          </button>
        </div>

        {/* Week grid */}
        <div className="grid grid-cols-8 gap-px rounded-xl overflow-hidden" style={{ background: 'var(--color-border-light)' }}>
          {/* Time column header */}
          <div className="p-2" style={{ background: 'var(--color-bg-glass-heavy)' }} />

          {/* Day headers */}
          {DAYS.map((day, i) => (
            <div
              key={day}
              className="p-2 text-center"
              style={{ background: 'var(--color-bg-glass-heavy)' }}
            >
              <div className="font-sans text-[9px] uppercase tracking-widest" style={{ color: 'var(--color-text-light)' }}>
                {day}
              </div>
              <div className="font-sans text-xs font-semibold" style={{ color: 'var(--color-text-main)' }}>
                {weekDates[i].getDate()}
              </div>
            </div>
          ))}

          {/* Time rows */}
          {HOURS.map(hour => (
            <>
              <div
                key={`time-${hour}`}
                className="p-1 text-right pr-2"
                style={{ background: 'var(--color-bg-glass-heavy)' }}
              >
                <span className="font-sans text-[9px]" style={{ color: 'var(--color-text-light)' }}>
                  {hour > 12 ? `${hour - 12}p` : `${hour}a`}
                </span>
              </div>
              {DAYS.map((day, dayIdx) => {
                // Check if any events fall on this day/hour
                const hasEvent = node.calendar.events.some(evt => {
                  const evtDate = new Date(evt.start)
                  return evtDate.getDay() === (dayIdx + 1) % 7 && evtDate.getHours() === hour
                })
                const isGoldenHour = hour >= 16 // Last hours are golden

                return (
                  <div
                    key={`${day}-${hour}`}
                    className="min-h-[24px] relative cursor-pointer hover:bg-[var(--color-bg-glass)] transition-colors"
                    style={{
                      background: hasEvent
                        ? 'rgba(197, 160, 89, 0.15)'
                        : 'var(--color-bg-glass-heavy)',
                    }}
                  >
                    {hasEvent && (
                      <div
                        className="absolute inset-0.5 rounded-sm"
                        style={{
                          background: 'rgba(197, 160, 89, 0.3)',
                          border: '1px solid rgba(197, 160, 89, 0.4)',
                        }}
                      />
                    )}
                    {isGoldenHour && !hasEvent && (
                      <div
                        className="absolute inset-0"
                        style={{ background: 'rgba(197, 160, 89, 0.04)' }}
                      />
                    )}
                  </div>
                )
              })}
            </>
          ))}
        </div>

        {/* Events list */}
        {node.calendar.events.length > 0 && (
          <div className="mt-3 space-y-1.5">
            <span className="font-sans text-[9px] uppercase tracking-widest" style={{ color: 'var(--color-text-light)' }}>
              Events
            </span>
            {node.calendar.events.map(evt => (
              <div key={evt.id} className="flex items-center gap-2 px-2 py-1.5 rounded-lg" style={{ background: 'var(--color-bg-glass)' }}>
                <Clock size={12} style={{ color: 'var(--color-gold-primary)' }} />
                <span className="font-sans text-xs" style={{ color: 'var(--color-text-main)' }}>{evt.title}</span>
                <span className="font-sans text-[10px] ml-auto" style={{ color: 'var(--color-text-light)' }}>
                  {new Date(evt.start).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                </span>
              </div>
            ))}
          </div>
        )}

        {/* Golden Hour info */}
        <div className="mt-3 flex items-center gap-2 px-3 py-2 rounded-lg" style={{ background: 'rgba(197, 160, 89, 0.08)', border: '1px solid rgba(197, 160, 89, 0.15)' }}>
          <div className="w-2 h-2 rounded-full" style={{ background: 'var(--color-gold-primary)' }} />
          <span className="font-sans text-xs" style={{ color: 'var(--color-gold-dark)' }}>
            Golden Hour: {node.calendar.goldenHourMinutes} min sessions
          </span>
        </div>

        {/* Add time block button */}
        <button className="mt-3 w-full py-2 rounded-xl flex items-center justify-center gap-2 hover:bg-[var(--color-bg-glass)] transition-colors" style={{ border: '1px dashed var(--color-border-light)' }}>
          <Plus size={14} style={{ color: 'var(--color-text-muted)' }} />
          <span className="font-sans text-xs" style={{ color: 'var(--color-text-muted)' }}>Assign Time Block</span>
        </button>
      </div>
    </div>
  )
}
