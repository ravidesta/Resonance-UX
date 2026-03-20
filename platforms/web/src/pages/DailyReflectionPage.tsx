import React, { useState, useEffect, useCallback, useRef } from 'react';
import GlassPanel from '../components/GlassPanel';
import type { JournalEntry } from '../types/astrology';

const STORAGE_KEY = 'lca-journal-entries';

const PROMPTS = [
  'What part of yourself is ready to emerge from the depths? Allow your intuition to speak through imagery today.',
  'Consider the tension between what you desire and what you need. How might these forces find harmony?',
  'What old pattern is asking to be released? Imagine handing it to the cosmos with gratitude.',
  'If your emotions were a landscape right now, what would it look like? Describe it in detail.',
  'What message does the Moon have for you tonight? Listen with your heart, not your mind.',
  'Where in your life are you being called to expand beyond your comfort zone?',
  'Reflect on a moment of synchronicity you experienced recently. What might it be pointing toward?',
  'If your soul had a voice, what would it whisper to you right now?',
  'What are you nurturing in the garden of your inner world? What needs more sunlight?',
  'Consider the houses of your chart as rooms in a home. Which room needs your attention today?',
];

const MOODS = [
  { emoji: '\u2728', label: 'Inspired' },
  { emoji: '\u2764', label: 'Grateful' },
  { emoji: '\u263D', label: 'Reflective' },
  { emoji: '\u2600', label: 'Energized' },
  { emoji: '\u2601', label: 'Uncertain' },
  { emoji: '\u2B50', label: 'Hopeful' },
  { emoji: '\u26C8', label: 'Turbulent' },
  { emoji: '\u2618', label: 'Peaceful' },
];

function getTodayPrompt(): string {
  const dayOfYear = Math.floor(
    (Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) / 86400000
  );
  return PROMPTS[dayOfYear % PROMPTS.length];
}

function loadEntries(): JournalEntry[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function saveEntries(entries: JournalEntry[]): void {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
}

const DailyReflectionPage: React.FC = () => {
  const [entries, setEntries] = useState<JournalEntry[]>([]);
  const [content, setContent] = useState('');
  const [selectedMood, setSelectedMood] = useState('');
  const [isSaved, setIsSaved] = useState(false);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const todayPrompt = getTodayPrompt();
  const today = new Date().toISOString().slice(0, 10);

  useEffect(() => {
    const loaded = loadEntries();
    setEntries(loaded);
    // Load today's entry if exists
    const todayEntry = loaded.find((e) => e.date === today);
    if (todayEntry) {
      setContent(todayEntry.content);
      setSelectedMood(todayEntry.mood);
    }
  }, [today]);

  const handleSave = useCallback(() => {
    const existing = entries.find((e) => e.date === today);
    const now = new Date().toISOString();

    const entry: JournalEntry = {
      id: existing?.id || `journal-${Date.now()}`,
      date: today,
      prompt: todayPrompt,
      content,
      mood: selectedMood,
      tags: [],
      createdAt: existing?.createdAt || now,
      updatedAt: now,
    };

    const updated = existing
      ? entries.map((e) => (e.id === existing.id ? entry : e))
      : [entry, ...entries];

    setEntries(updated);
    saveEntries(updated);
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 2000);
  }, [entries, today, todayPrompt, content, selectedMood]);

  const pastEntries = entries.filter((e) => e.date !== today).slice(0, 7);

  return (
    <div
      style={{
        padding: '1.5rem 1rem 6rem',
        maxWidth: '640px',
        margin: '0 auto',
        width: '100%',
      }}
    >
      {/* Header */}
      <header
        style={{
          marginBottom: '2rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
        }}
      >
        <h1
          style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: '1.75rem',
            fontWeight: 500,
            marginBottom: '0.25rem',
          }}
        >
          Daily Reflection
        </h1>
        <p style={{ fontSize: '0.85rem', color: 'var(--text-tertiary)', margin: 0 }}>
          {new Date().toLocaleDateString('en-US', {
            weekday: 'long',
            month: 'long',
            day: 'numeric',
          })}
        </p>
      </header>

      {/* Today's Prompt */}
      <GlassPanel
        glow
        padding="1.5rem"
        borderRadius="1.25rem"
        style={{
          marginBottom: '1.5rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 100ms both',
        }}
      >
        <div
          style={{
            fontSize: '0.7rem',
            color: 'var(--text-accent)',
            textTransform: 'uppercase',
            letterSpacing: '0.1em',
            fontWeight: 600,
            marginBottom: '0.75rem',
          }}
        >
          Today&apos;s Prompt
        </div>
        <p
          style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: '1.25rem',
            fontStyle: 'italic',
            color: 'var(--text-primary)',
            lineHeight: 1.5,
            margin: 0,
          }}
        >
          &ldquo;{todayPrompt}&rdquo;
        </p>
      </GlassPanel>

      {/* Mood Selector */}
      <div
        style={{
          marginBottom: '1rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 200ms both',
        }}
      >
        <div
          style={{
            fontSize: '0.8rem',
            color: 'var(--text-secondary)',
            marginBottom: '0.5rem',
            fontWeight: 500,
          }}
        >
          How does the cosmos feel today?
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem' }}>
          {MOODS.map((mood) => (
            <button
              key={mood.label}
              onClick={() => setSelectedMood(mood.label)}
              style={{
                padding: '0.4rem 0.75rem',
                borderRadius: '9999px',
                border: selectedMood === mood.label
                  ? '1px solid var(--gold-600, #C5A059)'
                  : '1px solid var(--border-subtle)',
                background: selectedMood === mood.label
                  ? 'rgba(197, 160, 89, 0.15)'
                  : 'var(--glass-bg)',
                backdropFilter: 'blur(8px)',
                fontSize: '0.8rem',
                color: selectedMood === mood.label ? 'var(--text-accent)' : 'var(--text-secondary)',
                transition: 'all 200ms cubic-bezier(0.34, 1.56, 0.64, 1)',
                transform: selectedMood === mood.label ? 'scale(1.05)' : 'scale(1)',
              }}
            >
              {mood.emoji} {mood.label}
            </button>
          ))}
        </div>
      </div>

      {/* Journal Textarea */}
      <div
        style={{
          marginBottom: '1rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 300ms both',
        }}
      >
        <textarea
          ref={textareaRef}
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Let your thoughts flow like starlight across the page..."
          style={{
            width: '100%',
            minHeight: '200px',
            fontFamily: "'Manrope', sans-serif",
            fontSize: '0.95rem',
            lineHeight: 1.7,
            resize: 'vertical',
          }}
        />
      </div>

      {/* Save Button */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'flex-end',
          gap: '1rem',
          alignItems: 'center',
          marginBottom: '2.5rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 400ms both',
        }}
      >
        {isSaved && (
          <span
            style={{
              fontSize: '0.85rem',
              color: 'var(--gold-600, #C5A059)',
              animation: 'fadeIn 300ms ease both',
            }}
          >
            Saved to your journal
          </span>
        )}
        <button
          onClick={handleSave}
          disabled={!content.trim()}
          style={{
            padding: '0.65rem 1.75rem',
            borderRadius: '9999px',
            background: content.trim()
              ? 'linear-gradient(135deg, #C5A059, #9A7A3A)'
              : 'var(--sage-300, #A8B8AD)',
            color: '#FAFAF8',
            fontWeight: 600,
            fontSize: '0.9rem',
            letterSpacing: '0.03em',
            boxShadow: content.trim() ? '0 4px 16px rgba(154, 122, 58, 0.3)' : 'none',
            transition: 'all 200ms ease',
            opacity: content.trim() ? 1 : 0.5,
            cursor: content.trim() ? 'pointer' : 'not-allowed',
          }}
        >
          Save Reflection
        </button>
      </div>

      {/* Past Entries */}
      {pastEntries.length > 0 && (
        <div
          style={{
            animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 500ms both',
          }}
        >
          <h3
            style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: '1.25rem',
              fontWeight: 500,
              marginBottom: '1rem',
            }}
          >
            Past Reflections
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
            {pastEntries.map((entry) => (
              <GlassPanel key={entry.id} padding="1rem 1.25rem" borderRadius="0.75rem">
                <div
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginBottom: '0.5rem',
                  }}
                >
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-tertiary)' }}>
                    {new Date(entry.date).toLocaleDateString('en-US', {
                      weekday: 'short',
                      month: 'short',
                      day: 'numeric',
                    })}
                  </span>
                  {entry.mood && (
                    <span
                      style={{
                        fontSize: '0.7rem',
                        color: 'var(--text-accent)',
                        padding: '0.15rem 0.5rem',
                        borderRadius: '9999px',
                        border: '1px solid var(--border-subtle)',
                      }}
                    >
                      {entry.mood}
                    </span>
                  )}
                </div>
                <p
                  style={{
                    fontSize: '0.85rem',
                    color: 'var(--text-secondary)',
                    lineHeight: 1.6,
                    margin: 0,
                    display: '-webkit-box',
                    WebkitLineClamp: 3,
                    WebkitBoxOrient: 'vertical',
                    overflow: 'hidden',
                  }}
                >
                  {entry.content}
                </p>
              </GlassPanel>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default DailyReflectionPage;
