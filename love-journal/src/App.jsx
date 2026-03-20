import { useState, useEffect } from 'react'
import { useJournalStore } from './hooks/useJournalStore'
import { BottomNav, TopBar } from './components/Navigation'
import { Home } from './pages/Home'
import { Gateway } from './pages/Gateway'
import { ChapterList, ChapterDetail } from './pages/Chapters'
import { Integration } from './pages/Integration'

const viewTitles = {
  home: 'Love Journal',
  gateway: 'Opening Gateway',
  chapters: 'Chapter Companions',
  integration: 'Integration & Depth',
}

function App() {
  const store = useJournalStore()
  const [view, setView] = useState('home')
  const [isDark, setIsDark] = useState(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('love-journal-dark')
      if (saved !== null) return saved === 'true'
      return window.matchMedia('(prefers-color-scheme: dark)').matches
    }
    return false
  })
  const [selectedChapter, setSelectedChapter] = useState(null)

  useEffect(() => {
    localStorage.setItem('love-journal-dark', isDark)
  }, [isDark])

  const handleSelectChapter = (chId) => {
    setSelectedChapter(chId)
    setView('chapter-detail')
  }

  const handleBack = () => {
    if (view === 'chapter-detail') {
      setView('chapters')
      setSelectedChapter(null)
    }
  }

  const topTitle = view === 'chapter-detail'
    ? `Chapter ${selectedChapter}`
    : viewTitles[view] || 'Love Journal'

  return (
    <div className={`min-h-dvh paper-texture transition-colors duration-800 ${isDark ? 'theme-deep' : ''}`}>
      {/* Background breathing blobs */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div
          className="absolute -top-32 -left-32 w-96 h-96 rounded-full animate-breathe"
          style={{
            background: `radial-gradient(circle, ${isDark ? 'rgba(197,160,89,0.08)' : 'rgba(197,160,89,0.15)'}, transparent 70%)`,
          }}
        />
        <div
          className="absolute -bottom-48 -right-48 w-[500px] h-[500px] rounded-full animate-breathe-slow"
          style={{
            background: `radial-gradient(circle, ${isDark ? 'rgba(27,64,46,0.12)' : 'rgba(27,64,46,0.1)'}, transparent 70%)`,
            animationDelay: '-8s',
          }}
        />
        <div
          className="absolute top-1/3 right-0 w-72 h-72 rounded-full animate-breathe"
          style={{
            background: `radial-gradient(circle, ${isDark ? 'rgba(197,160,89,0.05)' : 'rgba(230,208,161,0.12)'}, transparent 70%)`,
            animationDelay: '-12s',
          }}
        />
      </div>

      {/* Content */}
      <div className="relative z-10 max-w-2xl mx-auto min-h-dvh">
        <TopBar
          title={topTitle}
          isDark={isDark}
          setIsDark={setIsDark}
          onBack={view === 'chapter-detail' ? handleBack : null}
          store={store}
        />

        <main className="pb-4">
          {view === 'home' && <Home setView={setView} store={store} />}
          {view === 'gateway' && <Gateway store={store} />}
          {view === 'chapters' && <ChapterList onSelect={handleSelectChapter} store={store} />}
          {view === 'chapter-detail' && (
            <ChapterDetail chapterId={selectedChapter} store={store} onBack={handleBack} />
          )}
          {view === 'integration' && <Integration store={store} />}
        </main>

        <BottomNav view={view === 'chapter-detail' ? 'chapters' : view} setView={setView} />
      </div>
    </div>
  )
}

export default App
