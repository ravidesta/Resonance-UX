import { ZoomIn, ZoomOut, Maximize2, Layers } from 'lucide-react'
import { useReactFlow } from '@xyflow/react'

interface ZoomControllerProps {
  altitude: number
}

const altitudeLabels: Record<number, string> = {
  5: 'My Whole Life',
  4: 'Portfolios & Campaigns',
  3: 'Projects & Apps',
  2: 'This Week\'s Work',
  1: 'Task Detail',
  0: 'Enter Room',
}

export function ZoomController({ altitude }: ZoomControllerProps) {
  const { zoomIn, zoomOut, fitView } = useReactFlow()

  return (
    <div
      className="fixed bottom-6 left-6 z-30 glass-panel rounded-2xl p-2 flex flex-col items-center gap-1"
      style={{ boxShadow: 'var(--shadow-card)' }}
    >
      {/* Altitude indicator */}
      <div className="px-3 py-1.5 mb-1">
        <div className="flex items-center gap-1.5">
          <Layers size={12} style={{ color: 'var(--color-gold-primary)' }} />
          <span className="font-sans text-[10px] font-semibold" style={{ color: 'var(--color-text-main)' }}>
            ALT {altitude}
          </span>
        </div>
        <div className="font-sans text-[8px] text-center" style={{ color: 'var(--color-text-light)' }}>
          {altitudeLabels[altitude] || ''}
        </div>
      </div>

      {/* Altitude dots */}
      <div className="flex flex-col gap-1 mb-2">
        {[5, 4, 3, 2, 1, 0].map(a => (
          <div
            key={a}
            className="w-1.5 h-1.5 rounded-full transition-all duration-300"
            style={{
              background: a === altitude
                ? 'var(--color-gold-primary)'
                : a < altitude
                  ? 'var(--color-green-300)'
                  : 'var(--color-border-light)',
              transform: a === altitude ? 'scale(1.5)' : 'scale(1)',
            }}
          />
        ))}
      </div>

      {/* Zoom buttons */}
      <button
        onClick={() => zoomIn({ duration: 300 })}
        className="p-2 rounded-xl hover:bg-[var(--color-bg-glass)] transition-colors"
        title="Zoom In (deeper)"
      >
        <ZoomIn size={16} style={{ color: 'var(--color-text-muted)' }} />
      </button>
      <button
        onClick={() => zoomOut({ duration: 300 })}
        className="p-2 rounded-xl hover:bg-[var(--color-bg-glass)] transition-colors"
        title="Zoom Out (higher)"
      >
        <ZoomOut size={16} style={{ color: 'var(--color-text-muted)' }} />
      </button>
      <button
        onClick={() => fitView({ duration: 500, padding: 0.2 })}
        className="p-2 rounded-xl hover:bg-[var(--color-bg-glass)] transition-colors"
        title="Fit All"
      >
        <Maximize2 size={16} style={{ color: 'var(--color-text-muted)' }} />
      </button>
    </div>
  )
}
