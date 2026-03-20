import React, { useState, useEffect, useMemo, useCallback } from 'react';
import {
  JournalService,
  JournalEntry,
  JournalPrompt,
  Mood,
  DAILY_JOURNAL_PROMPTS,
} from '../../../shared/journal/JournalService';

// ─── Theme Constants ────────────────────────────────────────────────────────

const THEME = {
  bg: '#FAFAF8',
  darkGreen: '#0A1C14',
  green: '#122E21',
  gold: '#C5A059',
  goldLight: '#D4B472',
  glass: 'rgba(255,255,255,0.7)',
  glassBorder: 'rgba(255,255,255,0.35)',
  glassHover: 'rgba(255,255,255,0.85)',
  text: '#1A1A1A',
  textMuted: '#6B7C74',
  backdrop: 'blur(12px)',
  radius: '16px',
  radiusSm: '10px',
  shadow: '0 4px 24px rgba(10,28,20,0.08)',
  shadowLg: '0 8px 40px rgba(10,28,20,0.12)',
} as const;

const MOOD_OPTIONS: { value: Mood; label: string; icon: string }[] = [
  { value: 'radiant', label: 'Radiant', icon: '\u2600\uFE0F' },
  { value: 'balanced', label: 'Balanced', icon: '\u262F\uFE0F' },
  { value: 'contemplative', label: 'Contemplative', icon: '\u{1F319}' },
  { value: 'stormy', label: 'Stormy', icon: '\u26C8\uFE0F' },
  { value: 'eclipsed', label: 'Eclipsed', icon: '\u{1F311}' },
];

// ─── Styles ─────────────────────────────────────────────────────────────────

const styles: Record<string, React.CSSProperties> = {
  page: {
    minHeight: '100vh',
    background: `linear-gradient(165deg, ${THEME.bg} 0%, #F0EDE6 50%, #E8E4DA 100%)`,
    padding: '32px 24px',
    fontFamily: "'Inter', 'SF Pro Display', system-ui, -apple-system, sans-serif",
    color: THEME.text,
  },
  container: {
    maxWidth: '1120px',
    margin: '0 auto',
  },
  header: {
    marginBottom: '32px',
  },
  headerTitle: {
    fontSize: '36px',
    fontWeight: 700,
    color: THEME.darkGreen,
    margin: 0,
    letterSpacing: '-0.5px',
  },
  headerSubtitle: {
    fontSize: '15px',
    color: THEME.textMuted,
    marginTop: '6px',
  },
  moonBadge: {
    display: 'inline-flex',
    alignItems: 'center',
    gap: '6px',
    background: THEME.green,
    color: '#fff',
    padding: '6px 14px',
    borderRadius: '20px',
    fontSize: '13px',
    fontWeight: 500,
    marginTop: '12px',
  },
  glassCard: {
    background: THEME.glass,
    backdropFilter: THEME.backdrop,
    WebkitBackdropFilter: THEME.backdrop,
    border: `1px solid ${THEME.glassBorder}`,
    borderRadius: THEME.radius,
    padding: '24px',
    boxShadow: THEME.shadow,
  },
  promptCard: {
    background: `linear-gradient(135deg, ${THEME.darkGreen} 0%, ${THEME.green} 100%)`,
    borderRadius: THEME.radius,
    padding: '28px',
    color: '#fff',
    marginBottom: '28px',
    boxShadow: THEME.shadowLg,
    position: 'relative' as const,
    overflow: 'hidden',
  },
  promptLabel: {
    fontSize: '11px',
    fontWeight: 600,
    textTransform: 'uppercase' as const,
    letterSpacing: '1.5px',
    color: THEME.gold,
    marginBottom: '12px',
  },
  promptText: {
    fontSize: '18px',
    lineHeight: 1.6,
    fontWeight: 400,
    margin: 0,
  },
  promptRefresh: {
    marginTop: '16px',
    background: 'rgba(255,255,255,0.12)',
    border: '1px solid rgba(255,255,255,0.2)',
    color: '#fff',
    padding: '8px 16px',
    borderRadius: '8px',
    cursor: 'pointer',
    fontSize: '13px',
    fontWeight: 500,
  },
  layout: {
    display: 'grid',
    gridTemplateColumns: '380px 1fr',
    gap: '28px',
    alignItems: 'start',
  },
  sidebar: {
    display: 'flex',
    flexDirection: 'column' as const,
    gap: '20px',
  },
  searchInput: {
    width: '100%',
    padding: '12px 16px',
    border: `1px solid ${THEME.glassBorder}`,
    borderRadius: THEME.radiusSm,
    fontSize: '14px',
    background: THEME.glass,
    backdropFilter: THEME.backdrop,
    outline: 'none',
    color: THEME.text,
    boxSizing: 'border-box' as const,
  },
  tagFilter: {
    display: 'flex',
    flexWrap: 'wrap' as const,
    gap: '6px',
  },
  tagChip: {
    padding: '4px 12px',
    borderRadius: '14px',
    fontSize: '12px',
    fontWeight: 500,
    cursor: 'pointer',
    border: `1px solid ${THEME.glassBorder}`,
    background: THEME.glass,
    color: THEME.textMuted,
    transition: 'all 0.2s',
  },
  tagChipActive: {
    background: THEME.green,
    color: '#fff',
    borderColor: THEME.green,
  },
  entryListCard: {
    padding: '14px 18px',
    borderRadius: THEME.radiusSm,
    cursor: 'pointer',
    transition: 'all 0.2s',
    border: `1px solid transparent`,
    background: 'rgba(255,255,255,0.5)',
  },
  entryListCardActive: {
    background: THEME.glassHover,
    borderColor: THEME.gold,
    boxShadow: `0 0 0 1px ${THEME.gold}33`,
  },
  entryTitle: {
    fontSize: '15px',
    fontWeight: 600,
    color: THEME.darkGreen,
    margin: 0,
    marginBottom: '4px',
  },
  entryMeta: {
    fontSize: '12px',
    color: THEME.textMuted,
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
  },
  dateGroup: {
    fontSize: '11px',
    fontWeight: 600,
    textTransform: 'uppercase' as const,
    letterSpacing: '1px',
    color: THEME.textMuted,
    marginTop: '12px',
    marginBottom: '6px',
    paddingLeft: '4px',
  },
  // Form styles
  formCard: {
    background: THEME.glass,
    backdropFilter: THEME.backdrop,
    WebkitBackdropFilter: THEME.backdrop,
    border: `1px solid ${THEME.glassBorder}`,
    borderRadius: THEME.radius,
    padding: '28px',
    boxShadow: THEME.shadow,
  },
  input: {
    width: '100%',
    padding: '12px 16px',
    border: `1px solid #D4D0C8`,
    borderRadius: THEME.radiusSm,
    fontSize: '16px',
    fontWeight: 600,
    color: THEME.darkGreen,
    background: '#fff',
    outline: 'none',
    boxSizing: 'border-box' as const,
  },
  textarea: {
    width: '100%',
    minHeight: '200px',
    padding: '16px',
    border: `1px solid #D4D0C8`,
    borderRadius: THEME.radiusSm,
    fontSize: '14px',
    lineHeight: 1.7,
    color: THEME.text,
    background: '#fff',
    outline: 'none',
    resize: 'vertical' as const,
    fontFamily: "'Inter', system-ui, sans-serif",
    boxSizing: 'border-box' as const,
  },
  moodSelector: {
    display: 'flex',
    gap: '8px',
    flexWrap: 'wrap' as const,
  },
  moodBtn: {
    display: 'flex',
    flexDirection: 'column' as const,
    alignItems: 'center',
    gap: '4px',
    padding: '10px 14px',
    borderRadius: THEME.radiusSm,
    border: `1px solid #D4D0C8`,
    background: '#fff',
    cursor: 'pointer',
    fontSize: '12px',
    color: THEME.textMuted,
    transition: 'all 0.2s',
    minWidth: '72px',
  },
  moodBtnActive: {
    borderColor: THEME.gold,
    background: `${THEME.gold}15`,
    color: THEME.darkGreen,
    fontWeight: 600,
    boxShadow: `0 0 0 1px ${THEME.gold}44`,
  },
  tagInput: {
    display: 'flex',
    flexWrap: 'wrap' as const,
    gap: '6px',
    alignItems: 'center',
    padding: '8px 12px',
    border: `1px solid #D4D0C8`,
    borderRadius: THEME.radiusSm,
    background: '#fff',
    minHeight: '42px',
  },
  tagBubble: {
    display: 'inline-flex',
    alignItems: 'center',
    gap: '4px',
    background: THEME.green,
    color: '#fff',
    padding: '3px 10px',
    borderRadius: '12px',
    fontSize: '12px',
    fontWeight: 500,
  },
  tagRemove: {
    cursor: 'pointer',
    opacity: 0.7,
    fontSize: '14px',
    lineHeight: 1,
  },
  primaryBtn: {
    padding: '12px 28px',
    background: THEME.green,
    color: '#fff',
    border: 'none',
    borderRadius: THEME.radiusSm,
    fontSize: '14px',
    fontWeight: 600,
    cursor: 'pointer',
    transition: 'all 0.2s',
  },
  secondaryBtn: {
    padding: '12px 20px',
    background: 'transparent',
    color: THEME.textMuted,
    border: `1px solid #D4D0C8`,
    borderRadius: THEME.radiusSm,
    fontSize: '14px',
    fontWeight: 500,
    cursor: 'pointer',
  },
  dangerBtn: {
    padding: '12px 20px',
    background: 'transparent',
    color: '#C0392B',
    border: `1px solid #E8D0CD`,
    borderRadius: THEME.radiusSm,
    fontSize: '14px',
    fontWeight: 500,
    cursor: 'pointer',
  },
  label: {
    fontSize: '12px',
    fontWeight: 600,
    textTransform: 'uppercase' as const,
    letterSpacing: '0.8px',
    color: THEME.textMuted,
    marginBottom: '8px',
    display: 'block',
  },
  emptyState: {
    textAlign: 'center' as const,
    padding: '60px 24px',
    color: THEME.textMuted,
  },
  entryDetail: {
    padding: '32px',
  },
  entryDetailTitle: {
    fontSize: '24px',
    fontWeight: 700,
    color: THEME.darkGreen,
    margin: '0 0 8px 0',
  },
  entryDetailContent: {
    fontSize: '15px',
    lineHeight: 1.8,
    color: THEME.text,
    whiteSpace: 'pre-wrap' as const,
  },
  metaBadge: {
    display: 'inline-flex',
    alignItems: 'center',
    gap: '4px',
    padding: '4px 10px',
    borderRadius: '12px',
    fontSize: '12px',
    fontWeight: 500,
    background: 'rgba(18,46,33,0.08)',
    color: THEME.green,
  },
};

// ─── Component ──────────────────────────────────────────────────────────────

const JournalPage: React.FC = () => {
  const service = useMemo(() => new JournalService(), []);

  // State
  const [entries, setEntries] = useState<JournalEntry[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [isCreating, setIsCreating] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeTag, setActiveTag] = useState<string | null>(null);
  const [prompt, setPrompt] = useState<JournalPrompt | null>(null);

  // Form state
  const [formTitle, setFormTitle] = useState('');
  const [formContent, setFormContent] = useState('');
  const [formMood, setFormMood] = useState<Mood>('balanced');
  const [formTags, setFormTags] = useState<string[]>([]);
  const [tagInput, setTagInput] = useState('');

  // Derived
  const moonPhase = JournalService.getCurrentMoonPhase();
  const zodiacSign = JournalService.getCurrentZodiacSign();

  // Load entries
  const refreshEntries = useCallback(() => {
    let result: JournalEntry[];
    if (searchQuery.trim()) {
      result = service.searchEntries(searchQuery);
    } else if (activeTag) {
      result = service.getEntriesByTag(activeTag);
    } else {
      result = service.getEntries();
    }
    setEntries(result);
  }, [service, searchQuery, activeTag]);

  useEffect(() => {
    refreshEntries();
  }, [refreshEntries]);

  useEffect(() => {
    setPrompt(service.generatePrompt(moonPhase));
  }, [service, moonPhase]);

  // All tags across entries
  const allTags = useMemo(() => {
    const tagSet = new Set<string>();
    service.getEntries().forEach((e) => e.tags.forEach((t) => tagSet.add(t)));
    return Array.from(tagSet).sort();
  }, [entries]); // eslint-disable-line react-hooks/exhaustive-deps

  // Group entries by date
  const groupedEntries = useMemo(() => {
    const groups: Record<string, JournalEntry[]> = {};
    entries.forEach((e) => {
      const label = formatDateGroup(e.date);
      if (!groups[label]) groups[label] = [];
      groups[label].push(e);
    });
    return groups;
  }, [entries]);

  const selectedEntry = selectedId ? service.getEntryById(selectedId) : null;

  // ── Handlers ────────────────────────────────────────────────────────────

  const resetForm = () => {
    setFormTitle('');
    setFormContent('');
    setFormMood('balanced');
    setFormTags([]);
    setTagInput('');
  };

  const handleCreate = () => {
    setIsCreating(true);
    setIsEditing(false);
    setSelectedId(null);
    resetForm();
  };

  const handleEdit = () => {
    if (!selectedEntry) return;
    setIsEditing(true);
    setIsCreating(false);
    setFormTitle(selectedEntry.title);
    setFormContent(selectedEntry.content);
    setFormMood(selectedEntry.mood);
    setFormTags([...selectedEntry.tags]);
  };

  const handleSave = () => {
    if (!formTitle.trim() || !formContent.trim()) return;

    if (isCreating) {
      const entry = service.createEntry({
        title: formTitle.trim(),
        content: formContent.trim(),
        mood: formMood,
        tags: formTags,
      });
      setSelectedId(entry.id);
    } else if (isEditing && selectedId) {
      service.updateEntry(selectedId, {
        title: formTitle.trim(),
        content: formContent.trim(),
        mood: formMood,
        tags: formTags,
      });
    }

    setIsCreating(false);
    setIsEditing(false);
    resetForm();
    refreshEntries();
  };

  const handleDelete = () => {
    if (!selectedId) return;
    if (!window.confirm('Delete this journal entry?')) return;
    service.deleteEntry(selectedId);
    setSelectedId(null);
    refreshEntries();
  };

  const handleCancel = () => {
    setIsCreating(false);
    setIsEditing(false);
    resetForm();
  };

  const handleTagKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if ((e.key === 'Enter' || e.key === ',') && tagInput.trim()) {
      e.preventDefault();
      const tag = tagInput.trim().toLowerCase();
      if (!formTags.includes(tag)) {
        setFormTags([...formTags, tag]);
      }
      setTagInput('');
    }
    if (e.key === 'Backspace' && !tagInput && formTags.length > 0) {
      setFormTags(formTags.slice(0, -1));
    }
  };

  const removeTag = (tag: string) => {
    setFormTags(formTags.filter((t) => t !== tag));
  };

  const handleUsePrompt = () => {
    if (!prompt) return;
    handleCreate();
    setFormContent(prompt.text + '\n\n');
  };

  const shufflePrompt = () => {
    const pool = DAILY_JOURNAL_PROMPTS;
    setPrompt(pool[Math.floor(Math.random() * pool.length)]);
  };

  // ── Render helpers ──────────────────────────────────────────────────────

  const showForm = isCreating || isEditing;

  return (
    <div style={styles.page}>
      <div style={styles.container}>
        {/* Header */}
        <div style={styles.header}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h1 style={styles.headerTitle}>Celestial Journal</h1>
              <p style={styles.headerSubtitle}>
                Record your reflections under the stars
              </p>
              <div style={styles.moonBadge}>
                <span>{JournalService.getMoonPhaseEmoji(moonPhase)}</span>
                <span>{JournalService.formatMoonPhase(moonPhase)}</span>
                <span style={{ opacity: 0.5 }}>|</span>
                <span>{JournalService.formatZodiacSign(zodiacSign)} Season</span>
              </div>
            </div>
            <button
              style={{ ...styles.primaryBtn, marginTop: '8px' }}
              onClick={handleCreate}
            >
              + New Entry
            </button>
          </div>
        </div>

        {/* Daily Prompt */}
        {prompt && (
          <div style={styles.promptCard}>
            {/* Decorative circle */}
            <div
              style={{
                position: 'absolute',
                top: '-40px',
                right: '-40px',
                width: '140px',
                height: '140px',
                borderRadius: '50%',
                background: `radial-gradient(circle, ${THEME.gold}22 0%, transparent 70%)`,
              }}
            />
            <div style={styles.promptLabel}>Daily Prompt</div>
            <p style={styles.promptText}>{prompt.text}</p>
            <div style={{ display: 'flex', gap: '10px', marginTop: '16px' }}>
              <button style={styles.promptRefresh} onClick={handleUsePrompt}>
                Write about this
              </button>
              <button style={styles.promptRefresh} onClick={shufflePrompt}>
                Shuffle
              </button>
            </div>
          </div>
        )}

        {/* Main Layout */}
        <div style={styles.layout}>
          {/* Sidebar: search + entry list */}
          <div style={styles.sidebar}>
            <input
              type="text"
              placeholder="Search entries..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={styles.searchInput}
            />

            {allTags.length > 0 && (
              <div style={styles.tagFilter}>
                <span
                  style={{
                    ...styles.tagChip,
                    ...(activeTag === null ? styles.tagChipActive : {}),
                  }}
                  onClick={() => setActiveTag(null)}
                >
                  All
                </span>
                {allTags.map((tag) => (
                  <span
                    key={tag}
                    style={{
                      ...styles.tagChip,
                      ...(activeTag === tag ? styles.tagChipActive : {}),
                    }}
                    onClick={() => setActiveTag(activeTag === tag ? null : tag)}
                  >
                    #{tag}
                  </span>
                ))}
              </div>
            )}

            {/* Entry list */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
              {entries.length === 0 && (
                <div style={{ ...styles.emptyState, padding: '40px 16px' }}>
                  <p style={{ fontSize: '32px', margin: '0 0 12px 0' }}>{JournalService.getMoonPhaseEmoji(moonPhase)}</p>
                  <p style={{ margin: 0, fontSize: '14px' }}>
                    {searchQuery
                      ? 'No entries match your search.'
                      : 'Your celestial journal awaits its first entry.'}
                  </p>
                </div>
              )}
              {Object.entries(groupedEntries).map(([dateLabel, groupEntries]) => (
                <div key={dateLabel}>
                  <div style={styles.dateGroup}>{dateLabel}</div>
                  {groupEntries.map((entry) => (
                    <div
                      key={entry.id}
                      style={{
                        ...styles.entryListCard,
                        ...(selectedId === entry.id ? styles.entryListCardActive : {}),
                        marginBottom: '4px',
                      }}
                      onClick={() => {
                        setSelectedId(entry.id);
                        setIsCreating(false);
                        setIsEditing(false);
                      }}
                    >
                      <p style={styles.entryTitle}>{entry.title}</p>
                      <div style={styles.entryMeta}>
                        <span>
                          {MOOD_OPTIONS.find((m) => m.value === entry.mood)?.icon}{' '}
                          {JournalService.getMoodLabel(entry.mood)}
                        </span>
                        <span>{JournalService.getMoonPhaseEmoji(entry.moonPhase)}</span>
                        {entry.tags.length > 0 && (
                          <span style={{ opacity: 0.7 }}>
                            {entry.tags.map((t) => `#${t}`).join(' ')}
                          </span>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              ))}
            </div>
          </div>

          {/* Main Panel: form or detail view */}
          <div>
            {showForm ? (
              <div style={styles.formCard}>
                <div style={{ marginBottom: '20px' }}>
                  <label style={styles.label}>Title</label>
                  <input
                    type="text"
                    placeholder="Name this reflection..."
                    value={formTitle}
                    onChange={(e) => setFormTitle(e.target.value)}
                    style={styles.input}
                  />
                </div>

                <div style={{ marginBottom: '20px' }}>
                  <label style={styles.label}>Your Reflection</label>
                  <textarea
                    placeholder="What are the stars whispering to you today?"
                    value={formContent}
                    onChange={(e) => setFormContent(e.target.value)}
                    style={styles.textarea}
                  />
                </div>

                <div style={{ marginBottom: '20px' }}>
                  <label style={styles.label}>Mood</label>
                  <div style={styles.moodSelector}>
                    {MOOD_OPTIONS.map((mood) => (
                      <button
                        key={mood.value}
                        onClick={() => setFormMood(mood.value)}
                        style={{
                          ...styles.moodBtn,
                          ...(formMood === mood.value ? styles.moodBtnActive : {}),
                        }}
                      >
                        <span style={{ fontSize: '20px' }}>{mood.icon}</span>
                        {mood.label}
                      </button>
                    ))}
                  </div>
                </div>

                <div style={{ marginBottom: '24px' }}>
                  <label style={styles.label}>Tags</label>
                  <div style={styles.tagInput}>
                    {formTags.map((tag) => (
                      <span key={tag} style={styles.tagBubble}>
                        #{tag}
                        <span style={styles.tagRemove} onClick={() => removeTag(tag)}>
                          x
                        </span>
                      </span>
                    ))}
                    <input
                      type="text"
                      value={tagInput}
                      onChange={(e) => setTagInput(e.target.value)}
                      onKeyDown={handleTagKeyDown}
                      placeholder={formTags.length === 0 ? 'Add tags (press Enter)...' : ''}
                      style={{
                        border: 'none',
                        outline: 'none',
                        fontSize: '13px',
                        flex: 1,
                        minWidth: '80px',
                        background: 'transparent',
                      }}
                    />
                  </div>
                </div>

                <div style={{ display: 'flex', gap: '10px' }}>
                  <button style={styles.primaryBtn} onClick={handleSave}>
                    {isCreating ? 'Save Entry' : 'Update Entry'}
                  </button>
                  <button style={styles.secondaryBtn} onClick={handleCancel}>
                    Cancel
                  </button>
                </div>
              </div>
            ) : selectedEntry ? (
              <div style={{ ...styles.formCard, ...styles.entryDetail }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
                  <div>
                    <h2 style={styles.entryDetailTitle}>{selectedEntry.title}</h2>
                    <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', marginBottom: '8px' }}>
                      <span style={styles.metaBadge}>
                        {MOOD_OPTIONS.find((m) => m.value === selectedEntry.mood)?.icon}{' '}
                        {JournalService.getMoodLabel(selectedEntry.mood)}
                      </span>
                      <span style={styles.metaBadge}>
                        {JournalService.getMoonPhaseEmoji(selectedEntry.moonPhase)}{' '}
                        {JournalService.formatMoonPhase(selectedEntry.moonPhase)}
                      </span>
                      <span style={styles.metaBadge}>
                        {JournalService.formatZodiacSign(selectedEntry.zodiacSign)}
                      </span>
                    </div>
                    <div style={{ fontSize: '13px', color: THEME.textMuted }}>
                      {new Date(selectedEntry.createdAt).toLocaleDateString('en-US', {
                        weekday: 'long',
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric',
                      })}
                    </div>
                  </div>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button style={styles.secondaryBtn} onClick={handleEdit}>
                      Edit
                    </button>
                    <button style={styles.dangerBtn} onClick={handleDelete}>
                      Delete
                    </button>
                  </div>
                </div>

                <hr style={{ border: 'none', borderTop: '1px solid #E8E4DA', margin: '16px 0 20px' }} />

                <div style={styles.entryDetailContent}>{selectedEntry.content}</div>

                {selectedEntry.tags.length > 0 && (
                  <div style={{ display: 'flex', gap: '6px', marginTop: '24px', flexWrap: 'wrap' }}>
                    {selectedEntry.tags.map((tag) => (
                      <span
                        key={tag}
                        style={{
                          ...styles.tagChip,
                          cursor: 'default',
                        }}
                      >
                        #{tag}
                      </span>
                    ))}
                  </div>
                )}
              </div>
            ) : (
              <div style={{ ...styles.formCard, ...styles.emptyState }}>
                <p style={{ fontSize: '48px', margin: '0 0 16px 0', opacity: 0.3 }}>{JournalService.getMoonPhaseEmoji(moonPhase)}</p>
                <p style={{ fontSize: '16px', fontWeight: 500, color: THEME.darkGreen, margin: '0 0 8px 0' }}>
                  Select an entry or begin a new one
                </p>
                <p style={{ fontSize: '14px', margin: 0 }}>
                  Your reflections are stored under the current {JournalService.formatMoonPhase(moonPhase)}.
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

// ─── Helpers ──────────────────────────────────────────────────────────────────

function formatDateGroup(dateStr: string): string {
  const date = new Date(dateStr + 'T00:00:00');
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const diff = today.getTime() - date.getTime();
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));

  if (days === 0) return 'Today';
  if (days === 1) return 'Yesterday';
  if (days < 7) return 'This Week';
  if (days < 30) return 'This Month';
  return date.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
}

export default JournalPage;
