/**
 * Resonance Journal & Coach API Routes
 *
 * Endpoints for journal entries, mood tracking, reflection prompts,
 * gratitude entries, and AI coach interactions.
 */

import { Router, Request, Response } from 'express';

const router = Router();

// ── Types ──────────────────────────────────────────────────────────────────────

interface JournalEntry {
  id: string;
  userId: string;
  date: string; // ISO date
  time: string; // ISO time
  phase: 'ascend' | 'zenith' | 'descent' | 'rest';
  mood: 'radiant' | 'bright' | 'steady' | 'low' | 'heavy';
  energy: 'high' | 'balanced' | 'moderate' | 'low' | 'depleted';
  reflectionPromptId?: string;
  reflectionText: string;
  gratitudeEntries: string[];
  tags: string[];
  isBookmarked: boolean;
  biomarkerSnapshot?: BiomarkerSnapshot;
  createdAt: string;
  updatedAt: string;
}

interface BiomarkerSnapshot {
  hrv?: number;
  cortisolTrend?: 'rising' | 'stable' | 'falling';
  sleepScore?: number;
}

interface MoodEntry {
  id: string;
  userId: string;
  timestamp: string;
  mood: string;
  energy: string;
  phase: string;
  note?: string;
}

interface CoachMessage {
  id: string;
  userId: string;
  sessionId: string;
  role: 'user' | 'coach';
  messageType: 'text' | 'insight' | 'breathwork' | 'suggestion';
  content: string;
  timestamp: string;
  metadata?: Record<string, unknown>;
}

interface CoachSession {
  id: string;
  userId: string;
  startedAt: string;
  lastMessageAt: string;
  messageCount: number;
  phase: string;
  summary?: string;
}

interface ReflectionPrompt {
  id: string;
  text: string;
  phase: string;
  category: string;
  isActive: boolean;
}

// ── In-memory store (replace with Prisma in production) ────────────────────────

const journalEntries: JournalEntry[] = [];
const moodEntries: MoodEntry[] = [];
const coachMessages: CoachMessage[] = [];
const coachSessions: CoachSession[] = [];

// ── Reflection Prompts ─────────────────────────────────────────────────────────

const reflectionPrompts: ReflectionPrompt[] = [
  // Ascend
  { id: 'p1', text: 'What intention would make today feel spacious?', phase: 'ascend', category: 'intention', isActive: true },
  { id: 'p2', text: 'What does your body need as you begin this day?', phase: 'ascend', category: 'body', isActive: true },
  { id: 'p3', text: 'If today had a single theme, what would you choose?', phase: 'ascend', category: 'focus', isActive: true },
  // Zenith
  { id: 'p4', text: "What's energizing you right now?", phase: 'zenith', category: 'energy', isActive: true },
  { id: 'p5', text: 'Where are you finding flow in this moment?', phase: 'zenith', category: 'flow', isActive: true },
  { id: 'p6', text: 'What thought deserves your full attention today?', phase: 'zenith', category: 'depth', isActive: true },
  // Descent
  { id: 'p7', text: 'What can you gently release from today?', phase: 'descent', category: 'release', isActive: true },
  { id: 'p8', text: 'What moment brought you unexpected calm?', phase: 'descent', category: 'calm', isActive: true },
  { id: 'p9', text: 'How did your energy shift through the day?', phase: 'descent', category: 'reflection', isActive: true },
  // Rest
  { id: 'p10', text: 'What are you grateful for as this day closes?', phase: 'rest', category: 'gratitude', isActive: true },
  { id: 'p11', text: 'What would you carry forward into tomorrow?', phase: 'rest', category: 'carry', isActive: true },
  { id: 'p12', text: 'How does stillness feel right now?', phase: 'rest', category: 'stillness', isActive: true },
];

// ── Helper: Get current phase ──────────────────────────────────────────────────

function getCurrentPhase(): string {
  const hour = new Date().getHours();
  if (hour >= 6 && hour <= 9) return 'ascend';
  if (hour >= 10 && hour <= 14) return 'zenith';
  if (hour >= 15 && hour <= 19) return 'descent';
  return 'rest';
}

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 8);
}

// ── Journal Entry CRUD ─────────────────────────────────────────────────────────

// List journal entries (with optional date range and phase filter)
router.get('/entries', (req: Request, res: Response) => {
  const userId = (req as any).userId;
  const { startDate, endDate, phase, bookmarked, limit = '50', offset = '0' } = req.query;

  let results = journalEntries.filter(e => e.userId === userId);

  if (startDate) results = results.filter(e => e.date >= (startDate as string));
  if (endDate) results = results.filter(e => e.date <= (endDate as string));
  if (phase) results = results.filter(e => e.phase === phase);
  if (bookmarked === 'true') results = results.filter(e => e.isBookmarked);

  results.sort((a, b) => b.createdAt.localeCompare(a.createdAt));

  const total = results.length;
  const sliced = results.slice(Number(offset), Number(offset) + Number(limit));

  res.json({ entries: sliced, total, limit: Number(limit), offset: Number(offset) });
});

// Get single entry
router.get('/entries/:id', (req: Request, res: Response) => {
  const userId = (req as any).userId;
  const entry = journalEntries.find(e => e.id === req.params.id && e.userId === userId);
  if (!entry) return res.status(404).json({ error: 'Entry not found' });
  res.json(entry);
});

// Create journal entry
router.post('/entries', (req: Request, res: Response) => {
  const userId = (req as any).userId;
  const now = new Date().toISOString();

  const entry: JournalEntry = {
    id: generateId(),
    userId,
    date: req.body.date || now.split('T')[0],
    time: req.body.time || now.split('T')[1].split('.')[0],
    phase: req.body.phase || getCurrentPhase(),
    mood: req.body.mood || 'steady',
    energy: req.body.energy || 'balanced',
    reflectionPromptId: req.body.reflectionPromptId,
    reflectionText: req.body.reflectionText || '',
    gratitudeEntries: req.body.gratitudeEntries || [],
    tags: req.body.tags || [],
    isBookmarked: req.body.isBookmarked || false,
    biomarkerSnapshot: req.body.biomarkerSnapshot,
    createdAt: now,
    updatedAt: now,
  };

  journalEntries.push(entry);
  res.status(201).json(entry);
});

// Update journal entry
router.put('/entries/:id', (req: Request, res: Response) => {
  const userId = (req as any).userId;
  const idx = journalEntries.findIndex(e => e.id === req.params.id && e.userId === userId);
  if (idx === -1) return res.status(404).json({ error: 'Entry not found' });

  const updated = {
    ...journalEntries[idx],
    ...req.body,
    id: journalEntries[idx].id,
    userId,
    updatedAt: new Date().toISOString(),
  };

  journalEntries[idx] = updated;
  res.json(updated);
});

// Delete journal entry
router.delete('/entries/:id', (req: Request, res: Response) => {
  const userId = (req as any).userId;
  const idx = journalEntries.findIndex(e => e.id === req.params.id && e.userId === userId);
  if (idx === -1) return res.status(404).json({ error: 'Entry not found' });

  journalEntries.splice(idx, 1);
  res.status(204).end();
});

// ── Mood Tracking ──────────────────────────────────────────────────────────────

// Log mood/energy check-in
router.post('/mood', (req: Request, res: Response) => {
  const userId = (req as any).userId;

  const entry: MoodEntry = {
    id: generateId(),
    userId,
    timestamp: new Date().toISOString(),
    mood: req.body.mood || 'steady',
    energy: req.body.energy || 'balanced',
    phase: req.body.phase || getCurrentPhase(),
    note: req.body.note,
  };

  moodEntries.push(entry);
  res.status(201).json(entry);
});

// Get mood history
router.get('/mood', (req: Request, res: Response) => {
  const userId = (req as any).userId;
  const { days = '30' } = req.query;

  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - Number(days));

  const results = moodEntries
    .filter(e => e.userId === userId && new Date(e.timestamp) >= cutoff)
    .sort((a, b) => b.timestamp.localeCompare(a.timestamp));

  // Aggregate mood distribution
  const moodCounts: Record<string, number> = {};
  const energyCounts: Record<string, number> = {};
  results.forEach(e => {
    moodCounts[e.mood] = (moodCounts[e.mood] || 0) + 1;
    energyCounts[e.energy] = (energyCounts[e.energy] || 0) + 1;
  });

  res.json({
    entries: results,
    summary: { moodDistribution: moodCounts, energyDistribution: energyCounts, totalEntries: results.length }
  });
});

// ── Reflection Prompts ─────────────────────────────────────────────────────────

// Get prompts for current or specified phase
router.get('/prompts', (req: Request, res: Response) => {
  const { phase } = req.query;
  const targetPhase = (phase as string) || getCurrentPhase();

  const prompts = reflectionPrompts.filter(p => p.phase === targetPhase && p.isActive);
  res.json({ prompts, phase: targetPhase });
});

// Get a random prompt for the current phase
router.get('/prompts/random', (_req: Request, res: Response) => {
  const phase = getCurrentPhase();
  const phasePrompts = reflectionPrompts.filter(p => p.phase === phase && p.isActive);
  const prompt = phasePrompts[Math.floor(Math.random() * phasePrompts.length)];
  res.json({ prompt, phase });
});

// ── Calendar / Consistency Stats ───────────────────────────────────────────────

// Get journal consistency heatmap data
router.get('/calendar', (req: Request, res: Response) => {
  const userId = (req as any).userId;
  const { year, month } = req.query;

  const targetYear = Number(year) || new Date().getFullYear();
  const targetMonth = month ? Number(month) - 1 : new Date().getMonth();

  const userEntries = journalEntries.filter(e => {
    const d = new Date(e.date);
    return e.userId === userId && d.getFullYear() === targetYear && d.getMonth() === targetMonth;
  });

  // Group by date
  const byDate: Record<string, { count: number; moods: string[]; phases: string[] }> = {};
  userEntries.forEach(e => {
    if (!byDate[e.date]) byDate[e.date] = { count: 0, moods: [], phases: [] };
    byDate[e.date].count++;
    byDate[e.date].moods.push(e.mood);
    byDate[e.date].phases.push(e.phase);
  });

  // Streak calculation
  const today = new Date();
  let streak = 0;
  for (let i = 0; i < 365; i++) {
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    const dateStr = d.toISOString().split('T')[0];
    if (userEntries.some(e => e.date === dateStr)) {
      streak++;
    } else if (i > 0) {
      break;
    }
  }

  res.json({
    year: targetYear,
    month: targetMonth + 1,
    days: byDate,
    totalEntries: userEntries.length,
    currentStreak: streak,
    daysWithEntries: Object.keys(byDate).length,
  });
});

// ── AI Coach Interactions ──────────────────────────────────────────────────────

// Coach response generation (simplified — integrate with Luminize service in production)
const coachResponseTemplates: Record<string, string[]> = {
  ascend: [
    "As your day begins, I notice you're bringing awareness to this moment. What intention feels right?",
    "Morning energy is fresh and full of possibility. What would make today feel spacious rather than packed?",
  ],
  zenith: [
    "You're in the productive heart of your day. How does your energy feel compared to yesterday at this time?",
    "Peak hours are precious. Are you spending them on what matters most, or what feels most urgent?",
  ],
  descent: [
    "The afternoon invites us to slow down. What can you gently set aside for tomorrow?",
    "I notice your energy patterns tend to dip around this time. Would a brief pause help?",
  ],
  rest: [
    "Evening is for integration, not optimization. What moment from today would you like to hold onto?",
    "As the day closes, your body is asking for rest. How can you honor that?",
  ],
};

// Start or continue a coach session
router.post('/coach/message', (req: Request, res: Response) => {
  const userId = (req as any).userId;
  const { sessionId, content } = req.body;

  if (!content || !content.trim()) {
    return res.status(400).json({ error: 'Message content is required' });
  }

  const now = new Date().toISOString();
  const phase = getCurrentPhase();

  // Find or create session
  let session = sessionId ? coachSessions.find(s => s.id === sessionId && s.userId === userId) : null;

  if (!session) {
    session = {
      id: generateId(),
      userId,
      startedAt: now,
      lastMessageAt: now,
      messageCount: 0,
      phase,
    };
    coachSessions.push(session);
  }

  // Save user message
  const userMsg: CoachMessage = {
    id: generateId(),
    userId,
    sessionId: session.id,
    role: 'user',
    messageType: 'text',
    content: content.trim(),
    timestamp: now,
  };
  coachMessages.push(userMsg);
  session.messageCount++;
  session.lastMessageAt = now;

  // Generate coach response
  const templates = coachResponseTemplates[phase] || coachResponseTemplates.zenith;
  const responseText = templates[Math.floor(Math.random() * templates.length)];

  const coachMsg: CoachMessage = {
    id: generateId(),
    userId,
    sessionId: session.id,
    role: 'coach',
    messageType: 'text',
    content: responseText,
    timestamp: new Date(Date.now() + 1000).toISOString(), // slight delay
  };
  coachMessages.push(coachMsg);
  session.messageCount++;

  res.json({
    session: { id: session.id, phase },
    userMessage: userMsg,
    coachResponse: coachMsg,
  });
});

// Get coach session history
router.get('/coach/sessions', (req: Request, res: Response) => {
  const userId = (req as any).userId;
  const sessions = coachSessions
    .filter(s => s.userId === userId)
    .sort((a, b) => b.lastMessageAt.localeCompare(a.lastMessageAt));
  res.json({ sessions });
});

// Get messages for a coach session
router.get('/coach/sessions/:sessionId/messages', (req: Request, res: Response) => {
  const userId = (req as any).userId;
  const { sessionId } = req.params;

  const session = coachSessions.find(s => s.id === sessionId && s.userId === userId);
  if (!session) return res.status(404).json({ error: 'Session not found' });

  const messages = coachMessages
    .filter(m => m.sessionId === sessionId)
    .sort((a, b) => a.timestamp.localeCompare(b.timestamp));

  res.json({ session, messages });
});

// Request breathwork suggestion
router.post('/coach/breathwork', (req: Request, res: Response) => {
  const techniques = [
    {
      name: 'Coherence Breathing',
      pattern: '5-5',
      description: 'Inhale for 5 counts, exhale for 5 counts. 6 cycles, about one minute.',
      duration: 60,
    },
    {
      name: '4-7-8 Calming',
      pattern: '4-7-8',
      description: 'Inhale 4, hold 7, exhale 8. Three rounds to settle the nervous system.',
      duration: 57,
    },
    {
      name: 'Box Breathing',
      pattern: '4-4-4-4',
      description: 'Inhale 4, hold 4, exhale 4, hold 4. Structured presence.',
      duration: 64,
    },
  ];

  const technique = techniques[Math.floor(Math.random() * techniques.length)];
  res.json({ technique });
});

// Request energy insight
router.get('/coach/insights', (req: Request, res: Response) => {
  const userId = (req as any).userId;

  // Gather recent mood data
  const recent = moodEntries
    .filter(e => e.userId === userId)
    .sort((a, b) => b.timestamp.localeCompare(a.timestamp))
    .slice(0, 14);

  // Simple pattern analysis
  const phaseMoods: Record<string, string[]> = {};
  recent.forEach(e => {
    if (!phaseMoods[e.phase]) phaseMoods[e.phase] = [];
    phaseMoods[e.phase].push(e.mood);
  });

  const insights = [
    {
      title: 'Energy Pattern',
      description: 'Your energy tends to peak mid-morning and dip after 3pm.',
      trend: 'stable',
      suggestion: 'Consider scheduling deep work between 10am and noon.',
    },
    {
      title: 'Mood Consistency',
      description: `You've logged ${recent.length} check-ins recently.`,
      trend: recent.length > 7 ? 'rising' : 'stable',
      suggestion: 'Regular check-ins help you notice patterns you might otherwise miss.',
    },
  ];

  res.json({ insights, recentEntries: recent.length });
});

export default router;
