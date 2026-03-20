/**
 * Resonance UX API Routes
 *
 * All RESTful endpoints for the Resonance platform.
 */

import { Router, type Request, type Response } from 'express';
import { authenticateToken, optionalAuth, generateTokens } from '../server';
import { LuminizeService } from '../services/luminizeService';
import { SyncService } from '../services/syncService';
import { NotificationService } from '../services/notificationService';
import { v4 as uuid } from 'uuid';

export const apiRouter = Router();

const luminize = new LuminizeService();
const syncService = new SyncService();
const notifications = NotificationService.getInstance();

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function paginate(query: { page?: string; limit?: string }) {
  const page = Math.max(1, parseInt(query.page || '1', 10));
  const limit = Math.min(100, Math.max(1, parseInt(query.limit || '20', 10)));
  const offset = (page - 1) * limit;
  return { page, limit, offset };
}

function ok<T>(res: Response, data: T, meta?: Record<string, unknown>) {
  res.json({ success: true, data, ...(meta ? { meta } : {}) });
}

function created<T>(res: Response, data: T) {
  res.status(201).json({ success: true, data });
}

function noContent(res: Response) {
  res.status(204).end();
}

function badRequest(res: Response, message: string, details?: Record<string, string[]>) {
  res.status(400).json({ success: false, error: { code: 'BAD_REQUEST', message, details } });
}

function notFound(res: Response, entity = 'Resource') {
  res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: `${entity} not found.` } });
}

// ---------------------------------------------------------------------------
// AUTH  /api/auth
// ---------------------------------------------------------------------------

const authRouter = Router();

authRouter.post('/register', async (req: Request, res: Response) => {
  const { email, password, displayName } = req.body;

  if (!email || !password || !displayName) {
    return badRequest(res, 'Missing required fields.', {
      email: !email ? ['Email is required'] : [],
      password: !password ? ['Password is required'] : [],
      displayName: !displayName ? ['Display name is required'] : [],
    });
  }

  if (password.length < 8) {
    return badRequest(res, 'Password must be at least 8 characters.');
  }

  // In production this would hash the password and store in DB
  const userId = uuid();
  const tokens = generateTokens(userId, email);

  created(res, {
    user: {
      id: userId,
      email,
      displayName,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      preferences: {
        theme: 'light',
        notificationsEnabled: true,
        syncEnabled: true,
        reducedMotion: false,
        defaultEnergyLevel: 'moderate',
        fontSize: 'medium',
      },
    },
    tokens,
  });
});

authRouter.post('/login', async (req: Request, res: Response) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return badRequest(res, 'Email and password are required.');
  }

  // In production: verify against DB
  const userId = uuid();
  const tokens = generateTokens(userId, email);

  ok(res, {
    user: {
      id: userId,
      email,
      displayName: email.split('@')[0],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      preferences: {
        theme: 'light',
        notificationsEnabled: true,
        syncEnabled: true,
        reducedMotion: false,
        defaultEnergyLevel: 'moderate',
        fontSize: 'medium',
      },
    },
    tokens,
  });
});

authRouter.post('/refresh', async (req: Request, res: Response) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return badRequest(res, 'Refresh token is required.');
  }

  try {
    const jwt = await import('jsonwebtoken');
    const payload = jwt.default.verify(refreshToken, process.env.JWT_SECRET || 'resonance-dev-secret-change-in-production') as {
      userId: string;
      email: string;
    };
    const tokens = generateTokens(payload.userId, payload.email);
    ok(res, { tokens });
  } catch {
    res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'Invalid refresh token.' } });
  }
});

authRouter.post('/logout', authenticateToken, (_req: Request, res: Response) => {
  // In production: invalidate token in DB / Redis
  noContent(res);
});

authRouter.get('/me', authenticateToken, (req: Request, res: Response) => {
  ok(res, {
    id: req.userId,
    email: req.userEmail,
    displayName: req.userEmail?.split('@')[0] || 'User',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });
});

apiRouter.use('/auth', authRouter);

// ---------------------------------------------------------------------------
// FLOW  /api/flow
// ---------------------------------------------------------------------------

const flowRouter = Router();
flowRouter.use(authenticateToken);

flowRouter.get('/today', (req: Request, res: Response) => {
  const now = new Date();
  const hour = now.getHours();

  let currentPhase = 'deep-rest';
  if (hour >= 5 && hour < 8) currentPhase = 'dawn';
  else if (hour >= 8 && hour < 12) currentPhase = 'morning-focus';
  else if (hour >= 12 && hour < 14) currentPhase = 'midday';
  else if (hour >= 14 && hour < 18) currentPhase = 'afternoon';
  else if (hour >= 18 && hour < 21) currentPhase = 'evening';

  ok(res, {
    date: now.toISOString().slice(0, 10),
    currentPhase,
    currentEnergy: 'high',
    spaciousness: 62,
    tasks: [],
    completedCount: 0,
    totalCount: 0,
  });
});

flowRouter.get('/phases', (req: Request, res: Response) => {
  ok(res, [
    { phase: 'dawn', startTime: '05:00', endTime: '08:00', energyLevel: 'moderate', notificationsAllowed: false },
    { phase: 'morning-focus', startTime: '08:00', endTime: '12:00', energyLevel: 'peak', notificationsAllowed: true },
    { phase: 'midday', startTime: '12:00', endTime: '14:00', energyLevel: 'moderate', notificationsAllowed: true },
    { phase: 'afternoon', startTime: '14:00', endTime: '18:00', energyLevel: 'high', notificationsAllowed: true },
    { phase: 'evening', startTime: '18:00', endTime: '21:00', energyLevel: 'low', notificationsAllowed: false },
    { phase: 'deep-rest', startTime: '21:00', endTime: '05:00', energyLevel: 'rest', notificationsAllowed: false },
  ]);
});

flowRouter.put('/phases', (req: Request, res: Response) => {
  const { phases } = req.body;
  if (!Array.isArray(phases)) {
    return badRequest(res, 'Phases must be an array.');
  }
  // In production: validate and persist
  ok(res, { updated: true, phases });
});

flowRouter.get('/spaciousness', (req: Request, res: Response) => {
  ok(res, {
    date: new Date().toISOString().slice(0, 10),
    percentage: 62,
    scheduledMinutes: 228,
    totalMinutes: 600,
    freeMinutes: 372,
  });
});

apiRouter.use('/flow', flowRouter);

// ---------------------------------------------------------------------------
// FOCUS  /api/focus
// ---------------------------------------------------------------------------

const focusRouter = Router();
focusRouter.use(authenticateToken);

// Tasks
focusRouter.get('/tasks', (req: Request, res: Response) => {
  const { page, limit } = paginate(req.query as Record<string, string>);

  ok(res, [], { page, limit, total: 0, hasMore: false });
});

focusRouter.post('/tasks', (req: Request, res: Response) => {
  const { title, description, priority, domainId, energyRequired, estimatedMinutes, scheduledDate, scheduledPhase, tags } = req.body;

  if (!title) return badRequest(res, 'Title is required.');

  const task = {
    id: uuid(),
    userId: req.userId,
    title,
    description: description || null,
    status: 'open',
    priority: priority || 'normal',
    domainId: domainId || null,
    energyRequired: energyRequired || 'moderate',
    estimatedMinutes: estimatedMinutes || null,
    actualMinutes: null,
    scheduledDate: scheduledDate || null,
    scheduledPhase: scheduledPhase || null,
    completedAt: null,
    tags: tags || [],
    subtasks: [],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  created(res, task);
});

focusRouter.get('/tasks/:id', (req: Request, res: Response) => {
  // In production: fetch from DB
  notFound(res, 'Task');
});

focusRouter.patch('/tasks/:id', (req: Request, res: Response) => {
  const { id } = req.params;
  ok(res, { id, ...req.body, updatedAt: new Date().toISOString() });
});

focusRouter.delete('/tasks/:id', (_req: Request, res: Response) => {
  noContent(res);
});

// Subtasks
focusRouter.post('/tasks/:taskId/subtasks', (req: Request, res: Response) => {
  const { title } = req.body;
  if (!title) return badRequest(res, 'Title is required.');
  created(res, { id: uuid(), title, completed: false, sortOrder: 0 });
});

focusRouter.patch('/tasks/:taskId/subtasks/:subtaskId', (req: Request, res: Response) => {
  ok(res, { id: req.params.subtaskId, ...req.body });
});

// Domains
focusRouter.get('/domains', (req: Request, res: Response) => {
  ok(res, []);
});

focusRouter.post('/domains', (req: Request, res: Response) => {
  const { name, color, icon } = req.body;
  if (!name) return badRequest(res, 'Name is required.');
  created(res, { id: uuid(), userId: req.userId, name, color: color || '#5BA37B', icon: icon || null, sortOrder: 0 });
});

focusRouter.patch('/domains/:id', (req: Request, res: Response) => {
  ok(res, { id: req.params.id, ...req.body });
});

focusRouter.delete('/domains/:id', (_req: Request, res: Response) => {
  noContent(res);
});

// Energy
focusRouter.get('/energy', (req: Request, res: Response) => {
  ok(res, {
    current: 'high',
    history: [
      { time: '08:00', level: 'peak' },
      { time: '10:00', level: 'high' },
      { time: '12:00', level: 'moderate' },
      { time: '14:00', level: 'moderate' },
      { time: '16:00', level: 'low' },
    ],
  });
});

focusRouter.put('/energy', (req: Request, res: Response) => {
  const { level } = req.body;
  if (!level) return badRequest(res, 'Level is required.');
  ok(res, { level, updatedAt: new Date().toISOString() });
});

apiRouter.use('/focus', focusRouter);

// ---------------------------------------------------------------------------
// LETTERS  /api/letters
// ---------------------------------------------------------------------------

const lettersRouter = Router();
lettersRouter.use(authenticateToken);

// Contacts
lettersRouter.get('/contacts', (req: Request, res: Response) => {
  const { page, limit } = paginate(req.query as Record<string, string>);
  ok(res, [], { page, limit, total: 0, hasMore: false });
});

lettersRouter.post('/contacts', (req: Request, res: Response) => {
  const { displayName, email, phone } = req.body;
  if (!displayName) return badRequest(res, 'Display name is required.');
  created(res, {
    id: uuid(),
    userId: req.userId,
    displayName,
    email: email || null,
    phone: phone || null,
    avatarUrl: null,
    lastContactedAt: null,
    isFavorite: false,
    notes: null,
  });
});

// Conversations
lettersRouter.get('/conversations', (req: Request, res: Response) => {
  const { page, limit } = paginate(req.query as Record<string, string>);
  ok(res, [], { page, limit, total: 0, hasMore: false });
});

lettersRouter.get('/conversations/:id', (req: Request, res: Response) => {
  notFound(res, 'Conversation');
});

// Messages
lettersRouter.get('/conversations/:conversationId/messages', (req: Request, res: Response) => {
  const { page, limit } = paginate(req.query as Record<string, string>);
  ok(res, [], { page, limit, total: 0, hasMore: false });
});

lettersRouter.post('/conversations/:conversationId/messages', (req: Request, res: Response) => {
  const { type, content, metadata } = req.body;
  if (!content) return badRequest(res, 'Content is required.');

  const message = {
    id: uuid(),
    conversationId: req.params.conversationId,
    senderId: req.userId,
    type: type || 'text',
    content,
    metadata: metadata || null,
    readAt: null,
    createdAt: new Date().toISOString(),
  };

  created(res, message);
});

lettersRouter.patch('/conversations/:conversationId/messages/:messageId/read', (req: Request, res: Response) => {
  ok(res, { messageId: req.params.messageId, readAt: new Date().toISOString() });
});

// Voice messages
lettersRouter.post('/voice-messages', (req: Request, res: Response) => {
  const { messageId, audioUrl, durationMs, waveform } = req.body;
  created(res, {
    id: uuid(),
    messageId: messageId || uuid(),
    audioUrl: audioUrl || '',
    durationMs: durationMs || 0,
    waveform: waveform || [],
    transcript: null,
    createdAt: new Date().toISOString(),
  });
});

// Video calls
lettersRouter.post('/calls', (req: Request, res: Response) => {
  const { conversationId } = req.body;
  if (!conversationId) return badRequest(res, 'Conversation ID is required.');
  created(res, {
    id: uuid(),
    conversationId,
    initiatorId: req.userId,
    status: 'ringing',
    startedAt: null,
    endedAt: null,
    durationMs: null,
  });
});

lettersRouter.patch('/calls/:id', (req: Request, res: Response) => {
  ok(res, { id: req.params.id, ...req.body, updatedAt: new Date().toISOString() });
});

apiRouter.use('/letters', lettersRouter);

// ---------------------------------------------------------------------------
// CANVAS  /api/canvas
// ---------------------------------------------------------------------------

const canvasRouter = Router();
canvasRouter.use(authenticateToken);

canvasRouter.get('/documents', (req: Request, res: Response) => {
  const { page, limit } = paginate(req.query as Record<string, string>);
  ok(res, [], { page, limit, total: 0, hasMore: false });
});

canvasRouter.post('/documents', (req: Request, res: Response) => {
  const { title, content, format, tags } = req.body;
  if (!title) return badRequest(res, 'Title is required.');

  const wordCount = (content || '').split(/\s+/).filter(Boolean).length;

  created(res, {
    id: uuid(),
    userId: req.userId,
    title,
    content: content || '',
    format: format || 'prose',
    wordCount,
    readingTimeMinutes: Math.max(1, Math.ceil(wordCount / 200)),
    tags: tags || [],
    isPublished: false,
    publishedAt: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });
});

canvasRouter.get('/documents/:id', (req: Request, res: Response) => {
  notFound(res, 'Document');
});

canvasRouter.patch('/documents/:id', (req: Request, res: Response) => {
  const updates = req.body;
  if (updates.content) {
    updates.wordCount = updates.content.split(/\s+/).filter(Boolean).length;
    updates.readingTimeMinutes = Math.max(1, Math.ceil(updates.wordCount / 200));
  }
  ok(res, { id: req.params.id, ...updates, updatedAt: new Date().toISOString() });
});

canvasRouter.delete('/documents/:id', (_req: Request, res: Response) => {
  noContent(res);
});

// Writing sessions
canvasRouter.post('/sessions', (req: Request, res: Response) => {
  const { documentId } = req.body;
  if (!documentId) return badRequest(res, 'Document ID is required.');
  created(res, {
    id: uuid(),
    documentId,
    userId: req.userId,
    startedAt: new Date().toISOString(),
    endedAt: null,
    wordsWritten: 0,
    durationMs: 0,
    flowState: 'warming-up',
  });
});

canvasRouter.patch('/sessions/:id', (req: Request, res: Response) => {
  ok(res, { id: req.params.id, ...req.body, updatedAt: new Date().toISOString() });
});

apiRouter.use('/canvas', canvasRouter);

// ---------------------------------------------------------------------------
// WELLNESS  /api/wellness
// ---------------------------------------------------------------------------

const wellnessRouter = Router();
wellnessRouter.use(authenticateToken);

// Patients
wellnessRouter.get('/patients', (req: Request, res: Response) => {
  ok(res, []);
});

wellnessRouter.get('/patients/:id', (req: Request, res: Response) => {
  notFound(res, 'Patient');
});

wellnessRouter.post('/patients', (req: Request, res: Response) => {
  const { dateOfBirth, medicalRecordNumber } = req.body;
  created(res, {
    id: uuid(),
    userId: req.userId,
    providerId: null,
    dateOfBirth: dateOfBirth || null,
    medicalRecordNumber: medicalRecordNumber || null,
    createdAt: new Date().toISOString(),
  });
});

// Biomarkers
wellnessRouter.get('/patients/:patientId/biomarkers', (req: Request, res: Response) => {
  const { page, limit } = paginate(req.query as Record<string, string>);
  ok(res, [], { page, limit, total: 0, hasMore: false });
});

wellnessRouter.post('/patients/:patientId/biomarkers', (req: Request, res: Response) => {
  const { name, category, value, unit, referenceMin, referenceMax, optimalMin, optimalMax, notes } = req.body;
  if (!name || value === undefined || !unit) {
    return badRequest(res, 'Name, value, and unit are required.');
  }
  created(res, {
    id: uuid(),
    patientId: req.params.patientId,
    name,
    category: category || 'metabolic',
    value,
    unit,
    referenceMin: referenceMin ?? null,
    referenceMax: referenceMax ?? null,
    optimalMin: optimalMin ?? null,
    optimalMax: optimalMax ?? null,
    collectedAt: new Date().toISOString(),
    notes: notes || null,
  });
});

// Protocols
wellnessRouter.get('/patients/:patientId/protocols', (req: Request, res: Response) => {
  ok(res, []);
});

wellnessRouter.post('/patients/:patientId/protocols', (req: Request, res: Response) => {
  const { title, description, interventions, startDate } = req.body;
  if (!title) return badRequest(res, 'Title is required.');
  created(res, {
    id: uuid(),
    patientId: req.params.patientId,
    providerId: req.userId,
    title,
    description: description || '',
    status: 'draft',
    interventions: interventions || [],
    startDate: startDate || new Date().toISOString().slice(0, 10),
    endDate: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });
});

wellnessRouter.patch('/patients/:patientId/protocols/:id', (req: Request, res: Response) => {
  ok(res, { id: req.params.id, ...req.body, updatedAt: new Date().toISOString() });
});

apiRouter.use('/wellness', wellnessRouter);

// ---------------------------------------------------------------------------
// SYNC  /api/sync
// ---------------------------------------------------------------------------

const syncRouter = Router();
syncRouter.use(authenticateToken);

syncRouter.post('/push', (req: Request, res: Response) => {
  const { deviceId, changes } = req.body;
  if (!deviceId || !Array.isArray(changes)) {
    return badRequest(res, 'deviceId and changes array are required.');
  }
  const result = syncService.processPush(req.userId!, deviceId, changes);
  ok(res, result);
});

syncRouter.post('/pull', (req: Request, res: Response) => {
  const { deviceId, since, entityTypes, limit } = req.body;
  if (!deviceId) return badRequest(res, 'deviceId is required.');
  const batch = syncService.processPull(req.userId!, deviceId, since, entityTypes, limit);
  ok(res, batch);
});

syncRouter.get('/state', (req: Request, res: Response) => {
  const deviceId = req.headers['x-device-id'] as string || 'unknown';
  ok(res, syncService.getState(req.userId!, deviceId));
});

syncRouter.post('/devices', (req: Request, res: Response) => {
  const { platform, deviceName, pushToken } = req.body;
  if (!platform || !deviceName) return badRequest(res, 'Platform and device name are required.');
  const device = syncService.registerDevice(req.userId!, {
    platform,
    deviceName,
    pushToken: pushToken || null,
  });
  created(res, device);
});

syncRouter.delete('/devices/:deviceId', (req: Request, res: Response) => {
  syncService.deregisterDevice(req.userId!, req.params.deviceId);
  noContent(res);
});

syncRouter.get('/devices', (req: Request, res: Response) => {
  ok(res, syncService.getDevices(req.userId!));
});

apiRouter.use('/sync', syncRouter);

// ---------------------------------------------------------------------------
// LUMINIZE  /api/luminize
// ---------------------------------------------------------------------------

const luminizeRouter = Router();
luminizeRouter.use(authenticateToken);

luminizeRouter.post('/refine', async (req: Request, res: Response) => {
  const { text, style, preserveVoice, context } = req.body;
  if (!text) return badRequest(res, 'Text is required.');

  try {
    const result = await luminize.refineProse(req.userId!, {
      text,
      style: style || 'refine',
      preserveVoice: preserveVoice !== false,
      context,
    });
    ok(res, result);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Refinement failed.';
    res.status(502).json({ success: false, error: { code: 'LUMINIZE_ERROR', message } });
  }
});

luminizeRouter.post('/translate-biomarker', async (req: Request, res: Response) => {
  const { biomarkerName, value, unit, referenceRange } = req.body;
  if (!biomarkerName || value === undefined) return badRequest(res, 'biomarkerName and value are required.');

  try {
    const result = await luminize.translateBiomarker(req.userId!, {
      biomarkerName,
      value,
      unit: unit || '',
      referenceRange,
    });
    ok(res, result);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Translation failed.';
    res.status(502).json({ success: false, error: { code: 'LUMINIZE_ERROR', message } });
  }
});

luminizeRouter.post('/empathize', async (req: Request, res: Response) => {
  const { incomingMessage, relationship, tone } = req.body;
  if (!incomingMessage) return badRequest(res, 'incomingMessage is required.');

  try {
    const result = await luminize.draftEmpatheticResponse(req.userId!, {
      incomingMessage,
      relationship: relationship || 'friend',
      tone: tone || 'warm',
    });
    ok(res, result);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Drafting failed.';
    res.status(502).json({ success: false, error: { code: 'LUMINIZE_ERROR', message } });
  }
});

apiRouter.use('/luminize', luminizeRouter);
