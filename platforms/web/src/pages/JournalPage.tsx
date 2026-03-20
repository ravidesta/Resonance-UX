import React, { useState } from 'react';

// ─── Types ───────────────────────────────────────────────────────────────────

interface JournalEntry {
  id: string;
  title: string;
  body: string;
  mood: number;
  tags: string[];
  date: string;
  bookmarked: boolean;
}

interface NewEntryForm {
  title: string;
  body: string;
  mood: number;
  tags: string[];
}

// ─── Theme Constants ─────────────────────────────────────────────────────────

const COLORS = {
  background: '#FAFAF8',
  primaryText: '#0A1C14',
  secondaryText: '#5C7065',
  gold: '#C5A059',
  goldLight: '#E6D0A1',
  surface: '#F5F4EE',
} as const;

const GLASS: React.CSSProperties = {
  background: 'rgba(255,255,255,0.7)',
  backdropFilter: 'blur(12px)',
  WebkitBackdropFilter: 'blur(12px)',
  border: '1px solid rgba(209,224,215,0.5)',
  borderRadius: '16px',
};

const FONT_HEADER = "'Cormorant Garamond', Georgia, serif";
const FONT_BODY = "'Manrope', system-ui, sans-serif";

// ─── Data Constants ──────────────────────────────────────────────────────────

const MOODS: { label: string; value: number; icon: string }[] = [
  { label: 'Radiant', value: 5, icon: '\u2600\uFE0F' },
  { label: 'Balanced', value: 4, icon: '\u262F\uFE0F' },
  { label: 'Contemplative', value: 3, icon: '\uD83C\uDF19' },
  { label: 'Stormy', value: 2, icon: '\u26C8\uFE0F' },
  { label: 'Eclipsed', value: 1, icon: '\uD83C\uDF11' },
];

const ALL_TAGS = [
  'lunar', 'solar', 'mercury-retrograde', 'new-moon', 'full-moon',
  'eclipse', 'transit', 'reflection', 'gratitude', 'intention',
];

const COSMIC_PROMPTS = [
  'What constellations of thought are forming in your mind tonight? Trace their shapes and name them.',
  'If your current emotional state were a celestial body, what would it be and why?',
  'The Moon is whispering something to you across the void. What do you hear?',
  'Imagine you are standing at the edge of a nebula. What colors surround you, and what do they mean?',
  'Mercury stations direct today. What communication have you been holding back?',
  'Write a letter to your future self, one full orbit from now.',
  'Which star in your personal sky burns brightest right now? Which has dimmed?',
  'The ecliptic path crosses a threshold tonight. What are you ready to release?',
];

const SAMPLE_ENTRIES: JournalEntry[] = [
  {
    id: '1',
    title: 'New Moon Intentions Under Pisces',
    body: 'Tonight the new moon rests in Pisces, and I feel the pull of deep water beneath my thoughts. I set three intentions: to listen more carefully to my intuition, to let creativity flow without judgment, and to honor the quiet spaces between my words. The sky was perfectly dark when I stepped outside, and in that darkness I found a strange comfort, as though the universe had drawn a curtain so I could finally see inward. I wrote each intention on a small slip of paper and folded them into tiny boats, a private ritual that felt both silly and sacred.',
    mood: 3,
    tags: ['new-moon', 'intention', 'reflection'],
    date: '2026-03-20',
    bookmarked: true,
  },
  {
    id: '2',
    title: 'Solar Return Gratitude',
    body: 'My solar return chart this year has Venus conjunct Jupiter in the tenth house, and I can already feel its warmth radiating through my professional life. Unexpected opportunities have been arriving like meteor showers, bright and fleeting and beautiful. I am grateful for the collaborators who orbit alongside me, each one reflecting light I did not know I was casting. Today I pause to acknowledge the gravity that holds us all in place.',
    mood: 5,
    tags: ['solar', 'gratitude', 'transit'],
    date: '2026-03-18',
    bookmarked: false,
  },
  {
    id: '3',
    title: 'Mercury Retrograde Survival Notes',
    body: 'Three miscommunications in one day. My email to the design team was misread, my calendar shifted a meeting without warning, and a text I sent to a friend landed in entirely the wrong tone. Classic Mercury retrograde chaos. But instead of frustration, I am trying to treat this as a cosmic editing pass, a chance to revisit assumptions, re-read before sending, and slow down the pace of my exchanges. The retrograde does not break things; it reveals what was already fragile.',
    mood: 2,
    tags: ['mercury-retrograde', 'reflection'],
    date: '2026-03-15',
    bookmarked: false,
  },
  {
    id: '4',
    title: 'Full Moon Eclipse Journal',
    body: 'The lunar eclipse painted the moon in copper and rust tonight. I watched from the rooftop, wrapped in a blanket, feeling the strange tidal energy that eclipses always bring. Something is shifting at a level I cannot name yet. Old patterns are loosening their grip. I am learning to trust the darkness between phases, to understand that what is hidden is not lost, merely waiting for the right alignment to re-emerge. The eclipse reminded me that shadow is not the absence of light but its companion.',
    mood: 4,
    tags: ['full-moon', 'eclipse', 'lunar'],
    date: '2026-03-10',
    bookmarked: true,
  },
];

// ─── Helper Functions ────────────────────────────────────────────────────────

function getMoodInfo(value: number) {
  return MOODS.find((m) => m.value === value) || MOODS[2];
}

function formatDate(dateStr: string): string {
  const d = new Date(dateStr + 'T12:00:00');
  return d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
}

function getDateGroup(dateStr: string): string {
  const d = new Date(dateStr + 'T12:00:00');
  const now = new Date();
  now.setHours(12, 0, 0, 0);
  const diff = Math.floor((now.getTime() - d.getTime()) / (1000 * 60 * 60 * 24));
  if (diff === 0) return 'Today';
  if (diff === 1) return 'Yesterday';
  if (diff < 7) return 'This Week';
  if (diff < 30) return 'This Month';
  return d.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
}

function wordCount(text: string): number {
  return text.trim().split(/\s+/).filter(Boolean).length;
}

function computeStreak(entries: JournalEntry[]): number {
  if (entries.length === 0) return 0;
  const dates = Array.from(new Set(entries.map((e) => e.date))).sort().reverse();
  let streak = 1;
  for (let i = 1; i < dates.length; i++) {
    const prev = new Date(dates[i - 1] + 'T12:00:00');
    const curr = new Date(dates[i] + 'T12:00:00');
    const diffDays = Math.round((prev.getTime() - curr.getTime()) / (1000 * 60 * 60 * 24));
    if (diffDays === 1) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

function excerpt(text: string, maxLen: number = 120): string {
  if (text.length <= maxLen) return text;
  return text.slice(0, maxLen).trimEnd() + '...';
}

let nextId = 100;
function generateId(): string {
  nextId++;
  return String(nextId);
}

// ─── Component ───────────────────────────────────────────────────────────────

const JournalPage: React.FC = () => {
  const [entries, setEntries] = useState<JournalEntry[]>(SAMPLE_ENTRIES);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedMoodFilter, setSelectedMoodFilter] = useState<number | null>(null);
  const [selectedTagFilter, setSelectedTagFilter] = useState<string | null>(null);
  const [promptIndex, setPromptIndex] = useState(0);

  const [newEntry, setNewEntry] = useState<NewEntryForm>({
    title: '',
    body: '',
    mood: 4,
    tags: [],
  });

  // ── Derived data ──────────────────────────────────────────────────────

  const filteredEntries = entries.filter((entry) => {
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const matchesSearch =
        entry.title.toLowerCase().includes(q) ||
        entry.body.toLowerCase().includes(q) ||
        entry.tags.some((t) => t.toLowerCase().includes(q));
      if (!matchesSearch) return false;
    }
    if (selectedMoodFilter !== null && entry.mood !== selectedMoodFilter) return false;
    if (selectedTagFilter !== null && !entry.tags.includes(selectedTagFilter)) return false;
    return true;
  });

  const grouped: Record<string, JournalEntry[]> = {};
  filteredEntries.forEach((entry) => {
    const group = getDateGroup(entry.date);
    if (!grouped[group]) grouped[group] = [];
    grouped[group].push(entry);
  });

  const totalWords = entries.reduce((sum, e) => sum + wordCount(e.body), 0);
  const streak = computeStreak(entries);
  const currentPrompt = COSMIC_PROMPTS[promptIndex % COSMIC_PROMPTS.length];

  // ── Handlers ──────────────────────────────────────────────────────────

  const handleToggleNewEntryTag = (tag: string) => {
    setNewEntry((prev) => ({
      ...prev,
      tags: prev.tags.includes(tag)
        ? prev.tags.filter((t) => t !== tag)
        : [...prev.tags, tag],
    }));
  };

  const handleSubmitNewEntry = () => {
    if (!newEntry.title.trim() || !newEntry.body.trim()) return;
    const entry: JournalEntry = {
      id: generateId(),
      title: newEntry.title.trim(),
      body: newEntry.body.trim(),
      mood: newEntry.mood,
      tags: [...newEntry.tags],
      date: new Date().toISOString().slice(0, 10),
      bookmarked: false,
    };
    setEntries((prev) => [entry, ...prev]);
    setNewEntry({ title: '', body: '', mood: 4, tags: [] });
  };

  const handleToggleBookmark = (id: string) => {
    setEntries((prev) =>
      prev.map((e) => (e.id === id ? { ...e, bookmarked: !e.bookmarked } : e))
    );
  };

  const handleStartEdit = (id: string) => {
    setEditingId(id);
    const entry = entries.find((e) => e.id === id);
    if (entry) {
      setNewEntry({
        title: entry.title,
        body: entry.body,
        mood: entry.mood,
        tags: [...entry.tags],
      });
    }
  };

  const handleSaveEdit = () => {
    if (!editingId) return;
    setEntries((prev) =>
      prev.map((e) =>
        e.id === editingId
          ? { ...e, title: newEntry.title.trim(), body: newEntry.body.trim(), mood: newEntry.mood, tags: [...newEntry.tags] }
          : e
      )
    );
    setEditingId(null);
    setNewEntry({ title: '', body: '', mood: 4, tags: [] });
  };

  const handleCancelEdit = () => {
    setEditingId(null);
    setNewEntry({ title: '', body: '', mood: 4, tags: [] });
  };

  const handleDeleteEntry = (id: string) => {
    setEntries((prev) => prev.filter((e) => e.id !== id));
    if (editingId === id) handleCancelEdit();
  };

  const handleCyclePrompt = () => {
    setPromptIndex((prev) => (prev + 1) % COSMIC_PROMPTS.length);
  };

  const handleUsePrompt = () => {
    setNewEntry((prev) => ({
      ...prev,
      body: prev.body ? prev.body + '\n\n' + currentPrompt : currentPrompt,
    }));
  };

  // ── Styles ────────────────────────────────────────────────────────────

  const pageStyle: React.CSSProperties = {
    minHeight: '100vh',
    background: COLORS.background,
    fontFamily: FONT_BODY,
    color: COLORS.primaryText,
    padding: '32px 24px',
    boxSizing: 'border-box',
  };

  const containerStyle: React.CSSProperties = {
    maxWidth: '1080px',
    margin: '0 auto',
  };

  const headerStyle: React.CSSProperties = {
    fontFamily: FONT_HEADER,
    fontSize: '42px',
    fontWeight: 600,
    color: COLORS.primaryText,
    margin: '0 0 4px 0',
  };

  const subHeaderStyle: React.CSSProperties = {
    fontFamily: FONT_BODY,
    fontSize: '15px',
    color: COLORS.secondaryText,
    margin: '0 0 28px 0',
  };

  const statsBarStyle: React.CSSProperties = {
    ...GLASS,
    display: 'flex',
    gap: '32px',
    padding: '18px 28px',
    marginBottom: '28px',
  };

  const statItemStyle: React.CSSProperties = {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '2px',
  };

  const statValueStyle: React.CSSProperties = {
    fontFamily: FONT_HEADER,
    fontSize: '28px',
    fontWeight: 700,
    color: COLORS.gold,
  };

  const statLabelStyle: React.CSSProperties = {
    fontSize: '12px',
    fontWeight: 500,
    color: COLORS.secondaryText,
    textTransform: 'uppercase',
    letterSpacing: '0.8px',
  };

  const promptCardStyle: React.CSSProperties = {
    ...GLASS,
    padding: '24px 28px',
    marginBottom: '28px',
    borderLeft: `4px solid ${COLORS.gold}`,
  };

  const promptLabelStyle: React.CSSProperties = {
    fontSize: '11px',
    fontWeight: 700,
    textTransform: 'uppercase',
    letterSpacing: '1.5px',
    color: COLORS.gold,
    marginBottom: '10px',
  };

  const promptTextStyle: React.CSSProperties = {
    fontFamily: FONT_HEADER,
    fontSize: '20px',
    fontStyle: 'italic',
    lineHeight: 1.6,
    color: COLORS.primaryText,
    margin: '0 0 16px 0',
  };

  const promptBtnStyle: React.CSSProperties = {
    padding: '8px 18px',
    borderRadius: '8px',
    border: `1px solid ${COLORS.goldLight}`,
    background: 'transparent',
    color: COLORS.gold,
    fontSize: '13px',
    fontWeight: 600,
    cursor: 'pointer',
    fontFamily: FONT_BODY,
    marginRight: '8px',
  };

  const formCardStyle: React.CSSProperties = {
    ...GLASS,
    padding: '28px',
    marginBottom: '32px',
  };

  const formTitleStyle: React.CSSProperties = {
    fontFamily: FONT_HEADER,
    fontSize: '22px',
    fontWeight: 600,
    color: COLORS.primaryText,
    margin: '0 0 20px 0',
  };

  const labelStyle: React.CSSProperties = {
    display: 'block',
    fontSize: '12px',
    fontWeight: 600,
    textTransform: 'uppercase',
    letterSpacing: '0.8px',
    color: COLORS.secondaryText,
    marginBottom: '8px',
  };

  const inputStyle: React.CSSProperties = {
    width: '100%',
    padding: '12px 16px',
    border: '1px solid rgba(209,224,215,0.5)',
    borderRadius: '10px',
    fontSize: '15px',
    fontFamily: FONT_BODY,
    color: COLORS.primaryText,
    background: '#fff',
    outline: 'none',
    boxSizing: 'border-box',
  };

  const textareaStyle: React.CSSProperties = {
    ...inputStyle,
    minHeight: '160px',
    resize: 'vertical',
    lineHeight: 1.7,
    fontSize: '14px',
  };

  const moodSelectorStyle: React.CSSProperties = {
    display: 'flex',
    gap: '8px',
    flexWrap: 'wrap',
  };

  const moodBtnStyle = (value: number, isActive: boolean): React.CSSProperties => ({
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '4px',
    padding: '10px 14px',
    borderRadius: '10px',
    border: isActive ? `2px solid ${COLORS.gold}` : '1px solid rgba(209,224,215,0.5)',
    background: isActive ? `${COLORS.goldLight}33` : '#fff',
    cursor: 'pointer',
    fontSize: '12px',
    fontFamily: FONT_BODY,
    fontWeight: isActive ? 700 : 400,
    color: isActive ? COLORS.primaryText : COLORS.secondaryText,
    minWidth: '76px',
    transition: 'all 0.15s ease',
  });

  const tagPillStyle = (isActive: boolean): React.CSSProperties => ({
    display: 'inline-block',
    padding: '5px 14px',
    borderRadius: '16px',
    fontSize: '12px',
    fontWeight: 500,
    cursor: 'pointer',
    border: isActive ? `1px solid ${COLORS.gold}` : '1px solid rgba(209,224,215,0.5)',
    background: isActive ? COLORS.goldLight : COLORS.surface,
    color: isActive ? COLORS.primaryText : COLORS.secondaryText,
    transition: 'all 0.15s ease',
    fontFamily: FONT_BODY,
    userSelect: 'none',
  });

  const primaryBtnStyle: React.CSSProperties = {
    padding: '12px 28px',
    borderRadius: '10px',
    border: 'none',
    background: COLORS.gold,
    color: '#fff',
    fontSize: '14px',
    fontWeight: 600,
    cursor: 'pointer',
    fontFamily: FONT_BODY,
  };

  const secondaryBtnStyle: React.CSSProperties = {
    padding: '12px 20px',
    borderRadius: '10px',
    border: `1px solid rgba(209,224,215,0.5)`,
    background: 'transparent',
    color: COLORS.secondaryText,
    fontSize: '14px',
    fontWeight: 500,
    cursor: 'pointer',
    fontFamily: FONT_BODY,
  };

  const searchBarStyle: React.CSSProperties = {
    display: 'flex',
    gap: '12px',
    flexWrap: 'wrap',
    alignItems: 'center',
    marginBottom: '12px',
  };

  const searchInputStyle: React.CSSProperties = {
    ...inputStyle,
    flex: '1 1 240px',
    maxWidth: '360px',
  };

  const filterRowStyle: React.CSSProperties = {
    display: 'flex',
    gap: '8px',
    flexWrap: 'wrap',
    alignItems: 'center',
    marginBottom: '24px',
  };

  const filterLabelStyle: React.CSSProperties = {
    fontSize: '12px',
    fontWeight: 600,
    color: COLORS.secondaryText,
    textTransform: 'uppercase',
    letterSpacing: '0.6px',
    marginRight: '4px',
  };

  const filterChipStyle = (isActive: boolean): React.CSSProperties => ({
    padding: '4px 12px',
    borderRadius: '14px',
    fontSize: '12px',
    fontWeight: 500,
    cursor: 'pointer',
    border: isActive ? `1px solid ${COLORS.gold}` : '1px solid rgba(209,224,215,0.5)',
    background: isActive ? COLORS.goldLight : 'rgba(255,255,255,0.7)',
    color: isActive ? COLORS.primaryText : COLORS.secondaryText,
    fontFamily: FONT_BODY,
    userSelect: 'none',
  });

  const dateGroupStyle: React.CSSProperties = {
    fontFamily: FONT_HEADER,
    fontSize: '16px',
    fontWeight: 600,
    color: COLORS.secondaryText,
    margin: '24px 0 12px 0',
    paddingBottom: '6px',
    borderBottom: `1px solid ${COLORS.goldLight}55`,
  };

  const entryCardStyle = (isEditing: boolean): React.CSSProperties => ({
    ...GLASS,
    padding: '18px 22px',
    marginBottom: '12px',
    cursor: 'default',
    borderColor: isEditing ? COLORS.gold : 'rgba(209,224,215,0.5)',
    transition: 'border-color 0.15s ease',
  });

  const entryTitleStyle: React.CSSProperties = {
    fontFamily: FONT_HEADER,
    fontSize: '18px',
    fontWeight: 600,
    color: COLORS.primaryText,
    margin: '0 0 6px 0',
  };

  const entryMetaStyle: React.CSSProperties = {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
    fontSize: '13px',
    color: COLORS.secondaryText,
    marginBottom: '8px',
    flexWrap: 'wrap',
  };

  const entryExcerptStyle: React.CSSProperties = {
    fontSize: '14px',
    lineHeight: 1.6,
    color: COLORS.secondaryText,
    margin: '0 0 10px 0',
  };

  const entryTagStyle: React.CSSProperties = {
    display: 'inline-block',
    padding: '2px 10px',
    borderRadius: '12px',
    fontSize: '11px',
    fontWeight: 500,
    background: COLORS.surface,
    color: COLORS.secondaryText,
    marginRight: '6px',
  };

  const bookmarkBtnStyle = (isBookmarked: boolean): React.CSSProperties => ({
    background: 'none',
    border: 'none',
    cursor: 'pointer',
    fontSize: '18px',
    color: isBookmarked ? COLORS.gold : COLORS.secondaryText,
    opacity: isBookmarked ? 1 : 0.4,
    padding: '4px',
    lineHeight: 1,
    transition: 'all 0.15s ease',
  });

  const actionBtnStyle: React.CSSProperties = {
    background: 'none',
    border: 'none',
    cursor: 'pointer',
    fontSize: '12px',
    fontWeight: 500,
    color: COLORS.secondaryText,
    padding: '4px 8px',
    fontFamily: FONT_BODY,
    textDecoration: 'underline',
  };

  // ── Render ────────────────────────────────────────────────────────────

  const usedTags = Array.from(new Set(entries.flatMap((e) => e.tags))).sort();

  return (
    <div style={pageStyle}>
      <div style={containerStyle}>
        {/* Header */}
        <h1 style={headerStyle}>Celestial Journal</h1>
        <p style={subHeaderStyle}>Chart your inner cosmos, one reflection at a time.</p>

        {/* Stats Bar */}
        <div style={statsBarStyle}>
          <div style={statItemStyle}>
            <span style={statValueStyle}>{entries.length}</span>
            <span style={statLabelStyle}>Total Entries</span>
          </div>
          <div style={statItemStyle}>
            <span style={statValueStyle}>{streak}</span>
            <span style={statLabelStyle}>Day Streak</span>
          </div>
          <div style={statItemStyle}>
            <span style={statValueStyle}>{totalWords.toLocaleString()}</span>
            <span style={statLabelStyle}>Words Written</span>
          </div>
        </div>

        {/* Daily Cosmic Prompt */}
        <div style={promptCardStyle}>
          <div style={promptLabelStyle}>Daily Cosmic Prompt</div>
          <p style={promptTextStyle}>{currentPrompt}</p>
          <div>
            <button style={promptBtnStyle} onClick={handleUsePrompt}>
              Use This Prompt
            </button>
            <button style={promptBtnStyle} onClick={handleCyclePrompt}>
              Next Prompt
            </button>
          </div>
        </div>

        {/* New Entry / Edit Form */}
        <div style={formCardStyle}>
          <h2 style={formTitleStyle}>
            {editingId ? 'Edit Entry' : 'New Entry'}
          </h2>

          {/* Title */}
          <div style={{ marginBottom: '16px' }}>
            <label style={labelStyle}>Title</label>
            <input
              type="text"
              placeholder="Name this reflection..."
              value={newEntry.title}
              onChange={(e) => setNewEntry((prev) => ({ ...prev, title: e.target.value }))}
              style={inputStyle}
            />
          </div>

          {/* Body */}
          <div style={{ marginBottom: '16px' }}>
            <label style={labelStyle}>Body</label>
            <textarea
              placeholder="What are the stars whispering to you today?"
              value={newEntry.body}
              onChange={(e) => setNewEntry((prev) => ({ ...prev, body: e.target.value }))}
              style={textareaStyle}
            />
          </div>

          {/* Mood Selector */}
          <div style={{ marginBottom: '16px' }}>
            <label style={labelStyle}>Mood</label>
            <div style={moodSelectorStyle}>
              {MOODS.map((mood) => (
                <button
                  key={mood.value}
                  style={moodBtnStyle(mood.value, newEntry.mood === mood.value)}
                  onClick={() => setNewEntry((prev) => ({ ...prev, mood: mood.value }))}
                >
                  <span style={{ fontSize: '20px' }}>{mood.icon}</span>
                  <span>{mood.label}</span>
                  <span style={{ fontSize: '10px', color: COLORS.secondaryText }}>{mood.value}</span>
                </button>
              ))}
            </div>
          </div>

          {/* Tag Pills */}
          <div style={{ marginBottom: '20px' }}>
            <label style={labelStyle}>Tags</label>
            <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
              {ALL_TAGS.map((tag) => (
                <span
                  key={tag}
                  style={tagPillStyle(newEntry.tags.includes(tag))}
                  onClick={() => handleToggleNewEntryTag(tag)}
                >
                  #{tag}
                </span>
              ))}
            </div>
          </div>

          {/* Actions */}
          <div style={{ display: 'flex', gap: '10px' }}>
            {editingId ? (
              <>
                <button style={primaryBtnStyle} onClick={handleSaveEdit}>
                  Save Changes
                </button>
                <button style={secondaryBtnStyle} onClick={handleCancelEdit}>
                  Cancel
                </button>
              </>
            ) : (
              <button style={primaryBtnStyle} onClick={handleSubmitNewEntry}>
                Add Entry
              </button>
            )}
          </div>
        </div>

        {/* Search Bar */}
        <div style={searchBarStyle}>
          <input
            type="text"
            placeholder="Search entries..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            style={searchInputStyle}
          />
          {searchQuery && (
            <button
              style={secondaryBtnStyle}
              onClick={() => setSearchQuery('')}
            >
              Clear
            </button>
          )}
        </div>

        {/* Filter Controls */}
        <div style={filterRowStyle}>
          <span style={filterLabelStyle}>Mood:</span>
          <span
            style={filterChipStyle(selectedMoodFilter === null)}
            onClick={() => setSelectedMoodFilter(null)}
          >
            All
          </span>
          {MOODS.map((mood) => (
            <span
              key={mood.value}
              style={filterChipStyle(selectedMoodFilter === mood.value)}
              onClick={() =>
                setSelectedMoodFilter(selectedMoodFilter === mood.value ? null : mood.value)
              }
            >
              {mood.icon} {mood.label}
            </span>
          ))}
        </div>

        <div style={filterRowStyle}>
          <span style={filterLabelStyle}>Tag:</span>
          <span
            style={filterChipStyle(selectedTagFilter === null)}
            onClick={() => setSelectedTagFilter(null)}
          >
            All
          </span>
          {usedTags.map((tag) => (
            <span
              key={tag}
              style={filterChipStyle(selectedTagFilter === tag)}
              onClick={() =>
                setSelectedTagFilter(selectedTagFilter === tag ? null : tag)
              }
            >
              #{tag}
            </span>
          ))}
        </div>

        {/* Entry List */}
        {filteredEntries.length === 0 && (
          <div
            style={{
              ...GLASS,
              padding: '48px 24px',
              textAlign: 'center',
              color: COLORS.secondaryText,
            }}
          >
            <p style={{ fontFamily: FONT_HEADER, fontSize: '20px', margin: '0 0 8px 0' }}>
              No entries found
            </p>
            <p style={{ fontSize: '14px', margin: 0 }}>
              {searchQuery || selectedMoodFilter !== null || selectedTagFilter !== null
                ? 'Try adjusting your search or filters.'
                : 'Begin your cosmic journaling journey by adding your first entry above.'}
            </p>
          </div>
        )}

        {Object.entries(grouped).map(([dateLabel, groupEntries]) => (
          <div key={dateLabel}>
            <div style={dateGroupStyle}>{dateLabel}</div>
            {groupEntries.map((entry) => {
              const mood = getMoodInfo(entry.mood);
              const isCurrentlyEditing = editingId === entry.id;

              return (
                <div key={entry.id} style={entryCardStyle(isCurrentlyEditing)}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                    <div style={{ flex: 1 }}>
                      <h3 style={entryTitleStyle}>{entry.title}</h3>
                      <div style={entryMetaStyle}>
                        <span>{mood.icon} {mood.label}</span>
                        <span style={{ color: COLORS.goldLight }}>|</span>
                        <span>{formatDate(entry.date)}</span>
                      </div>
                      <div style={{ marginBottom: '8px' }}>
                        {entry.tags.map((tag) => (
                          <span key={tag} style={entryTagStyle}>#{tag}</span>
                        ))}
                      </div>
                      <p style={entryExcerptStyle}>{excerpt(entry.body)}</p>
                    </div>
                    <button
                      style={bookmarkBtnStyle(entry.bookmarked)}
                      onClick={() => handleToggleBookmark(entry.id)}
                      title={entry.bookmarked ? 'Remove bookmark' : 'Bookmark'}
                    >
                      {entry.bookmarked ? '\u2605' : '\u2606'}
                    </button>
                  </div>
                  <div style={{ display: 'flex', gap: '4px' }}>
                    <button
                      style={actionBtnStyle}
                      onClick={() => handleStartEdit(entry.id)}
                    >
                      Edit
                    </button>
                    <button
                      style={{ ...actionBtnStyle, color: '#B0413E' }}
                      onClick={() => handleDeleteEntry(entry.id)}
                    >
                      Delete
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        ))}
      </div>
    </div>
  );
};

export default JournalPage;
