import { Heart, Compass, BookOpen, Layers, Feather, Clock, Sparkles } from 'lucide-react'

const journeySections = [
  { id: 'gateway', icon: Compass, title: 'Opening Gateway', desc: 'Begin your journey with love', color: 'from-gold/20 to-gold-light/10' },
  { id: 'chapters', icon: BookOpen, title: 'Chapter Companions', desc: '13 chapters of guided reflection', color: 'from-forest-light/10 to-forest-mid/5' },
  { id: 'integration', icon: Layers, title: 'Integration & Depth', desc: 'Hubs, shadow work, and closing', color: 'from-gold-dark/10 to-gold/5' },
]

export function Home({ setView, store }) {
  const totalKeys = Object.keys(store.data).length
  const hasStarted = totalKeys > 0

  return (
    <div className="animate-fade-in px-4 pb-28">
      {/* Hero */}
      <div className="text-center pt-8 pb-6">
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-gradient-to-br from-gold/30 to-gold-light/20 mb-4">
          <Sparkles className="text-gold" size={28} />
        </div>
        <h1 className="font-serif text-3xl md:text-4xl font-semibold text-text-main leading-tight">
          The Universal Law<br />of Love
        </h1>
        <p className="text-text-muted text-sm mt-3 max-w-sm mx-auto leading-relaxed italic">
          Your living companion to transformation and connection. Center your wisdom, your timing, and your nervous system.
        </p>
        <div className="mt-4 mx-auto w-20 h-px bg-gradient-to-r from-transparent via-gold to-transparent" />
      </div>

      {/* Progress */}
      {hasStarted && (
        <div className="glass rounded-2xl p-4 mb-6">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gold/10 flex items-center justify-center">
              <Feather className="text-gold" size={18} />
            </div>
            <div className="flex-1">
              <p className="text-sm font-medium text-text-main">Your Journey</p>
              <p className="text-xs text-text-muted">{totalKeys} reflections written</p>
            </div>
            <Clock className="text-text-light" size={16} />
          </div>
        </div>
      )}

      {/* Invitation */}
      <div className="glass rounded-2xl p-5 mb-6 text-center">
        <p className="font-serif text-base text-text-main leading-relaxed">
          This journal is not here to judge how "good" you are at manifestation. It is here to notice how deeply loved you already are, and to help you practice partnering with that love in ways that feel kind, grounded, and real.
        </p>
      </div>

      {/* Navigation Cards */}
      <div className="space-y-3">
        {journeySections.map(({ id, icon: Icon, title, desc, color }) => (
          <button
            key={id}
            onClick={() => setView(id)}
            className={`w-full glass rounded-2xl p-4 flex items-center gap-4 text-left transition-all duration-300 hover:scale-[1.01] active:scale-[0.99] bg-gradient-to-r ${color}`}
          >
            <div className="w-11 h-11 rounded-xl bg-bg-surface/60 flex items-center justify-center flex-shrink-0">
              <Icon className="text-gold" size={20} />
            </div>
            <div>
              <p className="font-medium text-text-main text-sm">{title}</p>
              <p className="text-text-muted text-xs mt-0.5">{desc}</p>
            </div>
          </button>
        ))}
      </div>

      {/* Self Agreement */}
      {!hasStarted && (
        <div className="mt-8 text-center">
          <button
            onClick={() => setView('gateway')}
            className="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-gradient-to-r from-gold to-gold-dark text-white font-medium text-sm shadow-lg shadow-gold/20 transition-all hover:shadow-xl hover:shadow-gold/30 active:scale-[0.98]"
          >
            <Heart size={16} />
            Begin Your Journey
          </button>
        </div>
      )}
    </div>
  )
}
