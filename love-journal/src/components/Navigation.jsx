import { Heart, BookOpen, Layers, Compass, Moon, Sun, Download, Upload, ChevronLeft, Globe } from 'lucide-react'

const navItems = [
  { id: 'home', label: 'Home', icon: Heart },
  { id: 'gateway', label: 'Gateway', icon: Compass },
  { id: 'chapters', label: 'Chapters', icon: BookOpen },
  { id: 'integration', label: 'Integrate', icon: Layers },
]

export function BottomNav({ view, setView }) {
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 safe-bottom">
      <div className="max-w-2xl mx-auto px-3 pb-2">
        <div className="glass rounded-2xl px-2 py-1.5 flex justify-around items-center shadow-lg">
          {navItems.map(({ id, label, icon: Icon }) => (
            <button
              key={id}
              onClick={() => setView(id)}
              className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all duration-300 ${
                view === id
                  ? 'text-gold bg-gold/10'
                  : 'text-text-muted hover:text-text-main'
              }`}
            >
              <Icon size={20} strokeWidth={view === id ? 2 : 1.5} />
              <span className="text-[10px] font-medium">{label}</span>
            </button>
          ))}
        </div>
      </div>
    </nav>
  )
}

export function TopBar({ title, isDark, setIsDark, onBack, store, onLanding }) {
  return (
    <header className="sticky top-0 z-40 safe-top">
      <div className="glass px-4 py-3 flex items-center justify-between">
        <div className="flex items-center gap-2">
          {onBack && (
            <button
              onClick={onBack}
              className="p-1.5 rounded-lg hover:bg-gold/10 transition-colors text-text-muted"
            >
              <ChevronLeft size={20} />
            </button>
          )}
          <h1 className="font-serif text-lg font-semibold text-text-main truncate">
            {title}
          </h1>
        </div>
        <div className="flex items-center gap-1">
          {onLanding && (
            <button
              onClick={onLanding}
              className="p-2 rounded-lg hover:bg-gold/10 transition-colors text-text-muted"
              title="Landing page"
            >
              <Globe size={16} />
            </button>
          )}
          {store && (
            <>
              <button
                onClick={store.exportData}
                className="p-2 rounded-lg hover:bg-gold/10 transition-colors text-text-muted"
                title="Export journal"
              >
                <Download size={16} />
              </button>
              <label
                className="p-2 rounded-lg hover:bg-gold/10 transition-colors text-text-muted cursor-pointer"
                title="Import journal"
              >
                <Upload size={16} />
                <input
                  type="file"
                  accept=".json"
                  className="hidden"
                  onChange={(e) => {
                    if (e.target.files[0]) store.importData(e.target.files[0])
                  }}
                />
              </label>
            </>
          )}
          <button
            onClick={() => setIsDark(!isDark)}
            className="p-2 rounded-lg hover:bg-gold/10 transition-colors text-text-muted"
          >
            {isDark ? <Sun size={16} /> : <Moon size={16} />}
          </button>
        </div>
      </div>
    </header>
  )
}
