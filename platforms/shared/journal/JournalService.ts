/**
 * Luminous Cosmic Architecture™ — Journal Service
 * Manages astrology-aware journaling with mood tracking and cosmic correlations
 */

// ─── Types ───────────────────────────────────────────────────────

export interface JournalEntry {
  id: string;
  createdAt: string;
  updatedAt: string;
  title: string;
  body: string;
  mood: MoodRating;
  tags: JournalTag[];
  cosmicSnapshot: CosmicSnapshot;
  promptId?: string;
  isBookmarked: boolean;
  wordCount: number;
}

export type MoodRating = 1 | 2 | 3 | 4 | 5;

export interface JournalTag {
  id: string;
  label: string;
  color: string;
  category: 'emotion' | 'theme' | 'transit' | 'custom';
}

export interface CosmicSnapshot {
  moonPhase: string;
  moonSign: string;
  sunSign: string;
  risingSign?: string;
  activeTransits: string[];
  retrogradePlanets: string[];
}

export interface JournalPrompt {
  id: string;
  text: string;
  category: PromptCategory;
  associatedSign?: string;
  associatedTransit?: string;
}

export type PromptCategory =
  | 'new-moon'
  | 'full-moon'
  | 'mercury-retrograde'
  | 'venus-transit'
  | 'saturn-return'
  | 'eclipse-season'
  | 'daily-reflection'
  | 'gratitude'
  | 'shadow-work'
  | 'manifestation';

export interface JournalStats {
  totalEntries: number;
  currentStreak: number;
  longestStreak: number;
  averageMood: number;
  moodTrend: 'rising' | 'stable' | 'falling';
  topTags: JournalTag[];
  entriesByMoonPhase: Record<string, number>;
  wordsWritten: number;
}

export interface JournalFilter {
  dateRange?: { start: string; end: string };
  mood?: MoodRating[];
  tags?: string[];
  moonPhase?: string;
  searchQuery?: string;
  bookmarkedOnly?: boolean;
}

// ─── Default Tags ────────────────────────────────────────────────

export const DEFAULT_TAGS: JournalTag[] = [
  { id: 'grateful', label: 'Grateful', color: '#C5A059', category: 'emotion' },
  { id: 'anxious', label: 'Anxious', color: '#8B6F47', category: 'emotion' },
  { id: 'inspired', label: 'Inspired', color: '#D4AF61', category: 'emotion' },
  { id: 'restless', label: 'Restless', color: '#9A7A3A', category: 'emotion' },
  { id: 'peaceful', label: 'Peaceful', color: '#1B402E', category: 'emotion' },
  { id: 'growth', label: 'Growth', color: '#2D5A3F', category: 'theme' },
  { id: 'release', label: 'Release', color: '#5C7065', category: 'theme' },
  { id: 'intention', label: 'Intention', color: '#3A6B4E', category: 'theme' },
  { id: 'shadow', label: 'Shadow Work', color: '#0A1C14', category: 'theme' },
  { id: 'dreams', label: 'Dreams', color: '#4A2D7A', category: 'theme' },
];

// ─── Prompts ─────────────────────────────────────────────────────

export const JOURNAL_PROMPTS: JournalPrompt[] = [
  { id: 'nm-1', text: 'What seeds of intention are you planting with this New Moon? Describe the vision you hold for this lunar cycle.', category: 'new-moon' },
  { id: 'nm-2', text: 'In the darkness of the New Moon, what inner knowing is emerging? What feels ready to begin?', category: 'new-moon' },
  { id: 'fm-1', text: 'Under this Full Moon illumination, what has come to fruition? What are you ready to release?', category: 'full-moon' },
  { id: 'fm-2', text: 'The Full Moon reveals what was hidden. What truth is now visible that you could not see before?', category: 'full-moon' },
  { id: 'mr-1', text: 'Mercury Retrograde invites review. What communication patterns are you reconsidering?', category: 'mercury-retrograde' },
  { id: 'mr-2', text: 'During this retrograde period, what old project or idea is calling you back?', category: 'mercury-retrograde' },
  { id: 'dr-1', text: 'As the day unfolds, what cosmic energy are you most attuned to? How is it showing up in your life?', category: 'daily-reflection' },
  { id: 'dr-2', text: 'Reflect on today planetary alignments. Where do you feel harmony, and where do you sense tension?', category: 'daily-reflection' },
  { id: 'dr-3', text: 'What synchronicities have you noticed today? How might the stars be speaking to you through daily events?', category: 'daily-reflection' },
  { id: 'gr-1', text: 'Name three cosmic gifts you have received today — moments of synchronicity, beauty, or unexpected grace.', category: 'gratitude' },
  { id: 'gr-2', text: 'Which planetary energy are you most grateful for right now, and how has it blessed your journey?', category: 'gratitude' },
  { id: 'sw-1', text: 'What shadow aspect is asking for integration right now? How can you honor this part of yourself with compassion?', category: 'shadow-work' },
  { id: 'sw-2', text: 'Pluto transformative energy asks: what needs to die so something new can be born?', category: 'shadow-work' },
  { id: 'mn-1', text: 'Write your manifestation as if it has already happened. Feel the reality of your desire fulfilled.', category: 'manifestation' },
  { id: 'mn-2', text: 'Jupiter expands what it touches. What area of your life is ready for abundant growth? Write your vision.', category: 'manifestation' },
  { id: 'vt-1', text: 'Venus invites you to explore beauty and desire. What are you attracting into your life?', category: 'venus-transit' },
  { id: 'sr-1', text: 'Saturn asks for accountability. What structures in your life need strengthening?', category: 'saturn-return' },
  { id: 'es-1', text: 'Eclipse energy accelerates change. What chapter is closing? What doorway is opening?', category: 'eclipse-season' },
];

// ─── Service ─────────────────────────────────────────────────────

export class JournalService {
  private entries: JournalEntry[] = [];

  private generateId(): string {
    return 'journal-' + Date.now() + '-' + Math.random().toString(36).slice(2, 9);
  }

  createEntry(params: {
    title: string;
    body: string;
    mood: MoodRating;
    tags: JournalTag[];
    cosmicSnapshot: CosmicSnapshot;
    promptId?: string;
  }): JournalEntry {
    const now = new Date().toISOString();
    const entry: JournalEntry = {
      id: this.generateId(),
      createdAt: now,
      updatedAt: now,
      title: params.title,
      body: params.body,
      mood: params.mood,
      tags: params.tags,
      cosmicSnapshot: params.cosmicSnapshot,
      promptId: params.promptId,
      isBookmarked: false,
      wordCount: params.body.split(/\s+/).filter(Boolean).length,
    };
    this.entries.unshift(entry);
    return entry;
  }

  updateEntry(id: string, updates: Partial<Pick<JournalEntry, 'title' | 'body' | 'mood' | 'tags' | 'isBookmarked'>>): JournalEntry | null {
    const entry = this.entries.find(e => e.id === id);
    if (!entry) return null;
    if (updates.title !== undefined) entry.title = updates.title;
    if (updates.body !== undefined) {
      entry.body = updates.body;
      entry.wordCount = updates.body.split(/\s+/).filter(Boolean).length;
    }
    if (updates.mood !== undefined) entry.mood = updates.mood;
    if (updates.tags !== undefined) entry.tags = updates.tags;
    if (updates.isBookmarked !== undefined) entry.isBookmarked = updates.isBookmarked;
    entry.updatedAt = new Date().toISOString();
    return entry;
  }

  deleteEntry(id: string): boolean {
    const index = this.entries.findIndex(e => e.id === id);
    if (index === -1) return false;
    this.entries.splice(index, 1);
    return true;
  }

  getEntries(filter?: JournalFilter): JournalEntry[] {
    let results = [...this.entries];
    if (filter?.bookmarkedOnly) results = results.filter(e => e.isBookmarked);
    if (filter?.mood?.length) results = results.filter(e => filter.mood!.includes(e.mood));
    if (filter?.tags?.length) results = results.filter(e => e.tags.some(t => filter.tags!.includes(t.id)));
    if (filter?.moonPhase) results = results.filter(e => e.cosmicSnapshot.moonPhase === filter.moonPhase);
    if (filter?.searchQuery) {
      const q = filter.searchQuery.toLowerCase();
      results = results.filter(e => e.title.toLowerCase().includes(q) || e.body.toLowerCase().includes(q));
    }
    if (filter?.dateRange) {
      const start = new Date(filter.dateRange.start).getTime();
      const end = new Date(filter.dateRange.end).getTime();
      results = results.filter(e => {
        const t = new Date(e.createdAt).getTime();
        return t >= start && t <= end;
      });
    }
    return results;
  }

  getPromptForContext(moonPhase: string, activeTransits: string[]): JournalPrompt {
    let category: PromptCategory = 'daily-reflection';
    if (moonPhase.toLowerCase().includes('new')) category = 'new-moon';
    else if (moonPhase.toLowerCase().includes('full')) category = 'full-moon';
    if (activeTransits.some(t => t.toLowerCase().includes('mercury') && t.toLowerCase().includes('retrograde'))) {
      category = 'mercury-retrograde';
    }
    const candidates = JOURNAL_PROMPTS.filter(p => p.category === category);
    return candidates[Math.floor(Math.random() * candidates.length)] || JOURNAL_PROMPTS[0];
  }

  getStats(): JournalStats {
    const entries = this.entries;
    if (entries.length === 0) {
      return { totalEntries: 0, currentStreak: 0, longestStreak: 0, averageMood: 0, moodTrend: 'stable', topTags: [], entriesByMoonPhase: {}, wordsWritten: 0 };
    }
    const avgMood = entries.reduce((sum, e) => sum + e.mood, 0) / entries.length;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let currentStreak = 0;
    let longestStreak = 0;
    let streak = 0;
    const entryDates = new Set(entries.map(e => new Date(e.createdAt).toISOString().split('T')[0]));
    for (let i = 0; i < 365; i++) {
      const d = new Date(today);
      d.setDate(d.getDate() - i);
      if (entryDates.has(d.toISOString().split('T')[0])) {
        streak++;
        if (i < streak) currentStreak = streak;
        longestStreak = Math.max(longestStreak, streak);
      } else {
        streak = 0;
      }
    }

    const tagCounts = new Map<string, { tag: JournalTag; count: number }>();
    for (const entry of entries) {
      for (const tag of entry.tags) {
        const existing = tagCounts.get(tag.id);
        if (existing) existing.count++;
        else tagCounts.set(tag.id, { tag, count: 1 });
      }
    }
    const topTags = [...tagCounts.values()].sort((a, b) => b.count - a.count).slice(0, 5).map(t => t.tag);

    const entriesByMoonPhase: Record<string, number> = {};
    for (const entry of entries) {
      const phase = entry.cosmicSnapshot.moonPhase;
      entriesByMoonPhase[phase] = (entriesByMoonPhase[phase] || 0) + 1;
    }

    const recent = entries.slice(0, 7);
    const older = entries.slice(7, 14);
    let moodTrend: 'rising' | 'stable' | 'falling' = 'stable';
    if (recent.length > 0 && older.length > 0) {
      const recentAvg = recent.reduce((s, e) => s + e.mood, 0) / recent.length;
      const olderAvg = older.reduce((s, e) => s + e.mood, 0) / older.length;
      if (recentAvg - olderAvg > 0.3) moodTrend = 'rising';
      else if (olderAvg - recentAvg > 0.3) moodTrend = 'falling';
    }

    return {
      totalEntries: entries.length, currentStreak, longestStreak,
      averageMood: Math.round(avgMood * 10) / 10, moodTrend, topTags, entriesByMoonPhase,
      wordsWritten: entries.reduce((s, e) => s + e.wordCount, 0),
    };
  }
}
