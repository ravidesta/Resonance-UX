import { BookOpen, ChevronRight } from 'lucide-react'
import { chapters } from '../data/chapters'
import { JournalPrompt, SectionDivider } from '../components/JournalPrompt'

export function ChapterList({ onSelect, store }) {
  return (
    <div className="animate-fade-in px-4 pb-28">
      <SectionDivider
        title="Chapter Companions"
        subtitle="Each chapter offers a repeating pattern: First Impressions, Key Insights, Personal Connections, Integration Ideas, and Creative Space."
        icon="✦"
      />

      <div className="space-y-2">
        {chapters.map((ch) => {
          const filledCount = Object.keys(store.data).filter(k => k.startsWith(`ch${ch.id}-`)).length
          const totalPrompts = ch.sections.reduce((acc, s) => acc + s.prompts.length, 0)

          return (
            <button
              key={ch.id}
              onClick={() => onSelect(ch.id)}
              className="w-full glass rounded-xl p-4 flex items-center gap-3 text-left transition-all duration-300 hover:scale-[1.005] active:scale-[0.995]"
            >
              <div className="w-10 h-10 rounded-xl bg-gold/10 flex items-center justify-center flex-shrink-0">
                <span className="font-serif text-gold font-semibold text-sm">{ch.id}</span>
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-medium text-text-main text-sm truncate">{ch.title}</p>
                <p className="text-text-muted text-xs mt-0.5">{ch.subtitle}</p>
                {filledCount > 0 && (
                  <div className="mt-1.5 flex items-center gap-2">
                    <div className="flex-1 h-1 rounded-full bg-bg-elevated overflow-hidden">
                      <div
                        className="h-full rounded-full bg-gold/60 transition-all duration-500"
                        style={{ width: `${Math.min(100, (filledCount / totalPrompts) * 100)}%` }}
                      />
                    </div>
                    <span className="text-[10px] text-text-light">{filledCount}/{totalPrompts}</span>
                  </div>
                )}
              </div>
              <ChevronRight className="text-text-light flex-shrink-0" size={16} />
            </button>
          )
        })}
      </div>
    </div>
  )
}

export function ChapterDetail({ chapterId, store, onBack }) {
  const chapter = chapters.find(c => c.id === chapterId)
  if (!chapter) return null

  return (
    <div className="animate-slide-up px-4 pb-28">
      <div className="text-center pt-4 pb-6">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-gold/10 mb-3">
          <span className="font-serif text-gold text-xl font-semibold">{chapter.id}</span>
        </div>
        <h2 className="font-serif text-2xl font-semibold text-text-main">{chapter.title}</h2>
        <p className="text-text-muted text-sm mt-1 italic">{chapter.subtitle}</p>
        <div className="mt-3 mx-auto w-16 h-px bg-gradient-to-r from-transparent via-gold to-transparent" />
      </div>

      {chapter.sections.map((section, si) => (
        <div key={si} className="mb-8">
          <h3 className="font-serif text-lg font-semibold text-text-main mb-1">{section.title}</h3>
          {section.hint && (
            <p className="text-text-muted text-sm mb-4 italic">{section.hint}</p>
          )}
          {section.prompts.map((prompt) => (
            <JournalPrompt
              key={prompt.id}
              id={prompt.id}
              label={prompt.label}
              hint={prompt.hint}
              store={store}
            />
          ))}
        </div>
      ))}
    </div>
  )
}
