import { useState } from 'react'
import { ShareButton } from './ShareButton'
import { useIsDark } from '../hooks/useTheme'

export function JournalPrompt({ id, label, placeholder, hint, store, multiline = true }) {
  const value = store.getValue(id, '')
  const [focused, setFocused] = useState(false)
  const isDark = useIsDark()

  return (
    <div className={`mb-6 transition-all duration-300 ${focused ? 'scale-[1.005]' : ''}`}>
      {label && (
        <label className="block font-serif text-lg text-text-main mb-1.5 font-medium">
          {label}
        </label>
      )}
      {hint && (
        <p className="text-text-muted text-sm mb-2 italic leading-relaxed">{hint}</p>
      )}
      <div className="glass rounded-xl px-4 py-3">
        {multiline ? (
          <textarea
            className="journal-textarea"
            placeholder={placeholder || 'Write here...'}
            value={value}
            onChange={(e) => store.setValue(id, e.target.value)}
            onFocus={() => setFocused(true)}
            onBlur={() => setFocused(false)}
            rows={3}
          />
        ) : (
          <input
            type="text"
            className="w-full bg-transparent border-none outline-none font-serif text-lg text-text-main placeholder:text-text-light placeholder:italic"
            placeholder={placeholder || 'Write here...'}
            value={value}
            onChange={(e) => store.setValue(id, e.target.value)}
            onFocus={() => setFocused(true)}
            onBlur={() => setFocused(false)}
          />
        )}
      </div>
      {value && (
        <div className="mt-1 flex items-center justify-between">
          <ShareButton text={value} label={label} isDark={isDark} size="sm" />
          <span className="text-xs text-text-light">{value.length} characters</span>
        </div>
      )}
    </div>
  )
}

export function JournalCheckbox({ id, label, store }) {
  const checked = store.getChecked(id)

  return (
    <label className="flex items-start gap-3 py-2 cursor-pointer group">
      <div
        className={`mt-0.5 w-5 h-5 rounded-md border-2 flex-shrink-0 flex items-center justify-center transition-all duration-300 ${
          checked
            ? 'bg-gold border-gold text-white'
            : 'border-text-light group-hover:border-gold-dark'
        }`}
        onClick={() => store.setChecked(id, !checked)}
      >
        {checked && (
          <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
            <path d="M2 6L5 9L10 3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
      </div>
      <span
        className={`font-sans text-sm leading-relaxed transition-colors ${
          checked ? 'text-text-muted line-through' : 'text-text-main'
        }`}
        onClick={() => store.setChecked(id, !checked)}
      >
        {label}
      </span>
    </label>
  )
}

export function ScaleInput({ id, label, store, max = 10 }) {
  const value = store.getScale(id)

  return (
    <div className="mb-6">
      <label className="block font-serif text-lg text-text-main mb-2 font-medium">
        {label}
      </label>
      <div className="flex items-center gap-2">
        <span className="text-xs text-text-light w-4">1</span>
        <div className="flex-1 flex gap-1">
          {Array.from({ length: max }, (_, i) => i + 1).map((n) => (
            <button
              key={n}
              onClick={() => store.setScale(id, n)}
              className={`flex-1 h-9 rounded-lg text-xs font-medium transition-all duration-300 ${
                n <= value
                  ? 'bg-gold/80 text-white shadow-sm'
                  : 'glass text-text-muted hover:bg-gold-light/30'
              }`}
            >
              {n}
            </button>
          ))}
        </div>
        <span className="text-xs text-text-light w-4">{max}</span>
      </div>
      <div className="text-center text-sm text-gold-dark mt-1 font-medium">{value}/{max}</div>
    </div>
  )
}

export function SectionDivider({ title, subtitle, icon }) {
  return (
    <div className="text-center py-8 mb-6">
      {icon && <div className="text-3xl mb-3">{icon}</div>}
      <h2 className="font-serif text-2xl md:text-3xl text-text-main font-semibold tracking-tight">
        {title}
      </h2>
      {subtitle && (
        <p className="text-text-muted text-sm mt-2 max-w-md mx-auto italic leading-relaxed">
          {subtitle}
        </p>
      )}
      <div className="mt-4 mx-auto w-16 h-px bg-gradient-to-r from-transparent via-gold to-transparent" />
    </div>
  )
}
