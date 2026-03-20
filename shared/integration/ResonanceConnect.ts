// ResonanceConnect.ts — Integration hub connecting Luminous Attachment to the Resonance ecosystem
// Syncs with Daily Flow, Writer, Health Dashboard, and all other Resonance apps

export interface ResonanceUser {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  preferences: { theme: 'light' | 'dark'; notifications: boolean; };
  attachmentStyle?: 'anxious' | 'avoidant' | 'disorganized' | 'secure' | 'earned-secure';
  streak: number;
  joinedAt: string;
}

export interface SyncPayload {
  app: string;
  action: string;
  data: Record<string, unknown>;
  timestamp: number;
}

export interface DeepLink {
  app: 'daily-flow' | 'writer' | 'health' | 'luminous-attachment' | 'resonance';
  screen: string;
  params?: Record<string, string>;
}

// --- Event Bus for cross-app communication ---

type EventHandler = (data: unknown) => void;

class SharedEventBus {
  private handlers: Map<string, Set<EventHandler>> = new Map();

  on(event: string, handler: EventHandler): void {
    if (!this.handlers.has(event)) this.handlers.set(event, new Set());
    this.handlers.get(event)!.add(handler);
  }

  off(event: string, handler: EventHandler): void {
    this.handlers.get(event)?.delete(handler);
  }

  emit(event: string, data?: unknown): void {
    this.handlers.get(event)?.forEach(handler => {
      try { handler(data); } catch (e) { console.error(`[ResonanceEventBus] Error in handler for ${event}:`, e); }
    });
    // Also broadcast via BroadcastChannel for cross-tab/cross-app sync
    try {
      const channel = new BroadcastChannel('resonance-ecosystem');
      channel.postMessage({ event, data, source: 'luminous-attachment', timestamp: Date.now() });
      channel.close();
    } catch {}
  }

  listenToBroadcast(): void {
    try {
      const channel = new BroadcastChannel('resonance-ecosystem');
      channel.onmessage = (e) => {
        if (e.data?.source !== 'luminous-attachment') {
          this.handlers.get(e.data?.event)?.forEach(handler => handler(e.data?.data));
        }
      };
    } catch {}
  }
}

export const eventBus = new SharedEventBus();

// --- Resonance Connect ---

class ResonanceConnect {
  private baseUrl: string;
  private apiKey: string | null = null;
  private user: ResonanceUser | null = null;

  constructor(baseUrl = 'https://api.resonance.app') {
    this.baseUrl = baseUrl;
    eventBus.listenToBroadcast();
  }

  // --- Authentication ---

  async initialize(apiKey: string): Promise<ResonanceUser> {
    this.apiKey = apiKey;
    this.user = await this.getUnifiedProfile();
    eventBus.emit('resonance:initialized', this.user);
    return this.user;
  }

  // --- Unified Profile ---

  async getUnifiedProfile(): Promise<ResonanceUser> {
    const stored = localStorage.getItem('resonance_user');
    if (stored) {
      this.user = JSON.parse(stored);
      return this.user!;
    }
    // Fallback default profile
    const defaultUser: ResonanceUser = {
      id: 'local-user',
      name: 'You',
      email: '',
      preferences: { theme: 'light', notifications: true },
      streak: 0,
      joinedAt: new Date().toISOString(),
    };
    this.user = defaultUser;
    return defaultUser;
  }

  async updateProfile(updates: Partial<ResonanceUser>): Promise<void> {
    if (this.user) {
      this.user = { ...this.user, ...updates };
      localStorage.setItem('resonance_user', JSON.stringify(this.user));
      eventBus.emit('resonance:profile-updated', this.user);
    }
  }

  // --- Cross-App Sync ---

  async syncWithDailyFlow(): Promise<SyncPayload | null> {
    const payload: SyncPayload = {
      app: 'luminous-attachment',
      action: 'sync-mood',
      data: {
        currentMood: localStorage.getItem('la_current_mood') || 'leaf',
        streak: this.user?.streak || 0,
        lastEntry: localStorage.getItem('la_last_entry_date'),
      },
      timestamp: Date.now(),
    };
    eventBus.emit('sync:daily-flow', payload);
    try { localStorage.setItem('resonance_sync_daily_flow', JSON.stringify(payload)); } catch {}
    return payload;
  }

  async syncWithWriter(): Promise<SyncPayload | null> {
    const journalEntries = JSON.parse(localStorage.getItem('la_journal_entries') || '[]');
    const payload: SyncPayload = {
      app: 'luminous-attachment',
      action: 'sync-journal',
      data: {
        recentEntries: journalEntries.slice(-5),
        totalEntries: journalEntries.length,
        themes: extractThemes(journalEntries),
      },
      timestamp: Date.now(),
    };
    eventBus.emit('sync:writer', payload);
    try { localStorage.setItem('resonance_sync_writer', JSON.stringify(payload)); } catch {}
    return payload;
  }

  async syncWithHealthDashboard(): Promise<SyncPayload | null> {
    const payload: SyncPayload = {
      app: 'luminous-attachment',
      action: 'sync-health',
      data: {
        moodHistory: JSON.parse(localStorage.getItem('la_mood_history') || '[]'),
        attachmentStyle: this.user?.attachmentStyle,
        breathingMinutes: parseInt(localStorage.getItem('la_breathing_minutes') || '0'),
        meditationMinutes: parseInt(localStorage.getItem('la_meditation_minutes') || '0'),
      },
      timestamp: Date.now(),
    };
    eventBus.emit('sync:health', payload);
    try { localStorage.setItem('resonance_sync_health', JSON.stringify(payload)); } catch {}
    return payload;
  }

  async syncAll(): Promise<void> {
    await Promise.all([
      this.syncWithDailyFlow(),
      this.syncWithWriter(),
      this.syncWithHealthDashboard(),
    ]);
    eventBus.emit('resonance:sync-complete', { timestamp: Date.now() });
  }

  // --- Deep Linking ---

  generateDeepLink(link: DeepLink): string {
    const base = `resonance://${link.app}/${link.screen}`;
    if (!link.params) return base;
    const query = Object.entries(link.params).map(([k, v]) => `${k}=${encodeURIComponent(v)}`).join('&');
    return `${base}?${query}`;
  }

  openInDailyFlow(screen = 'today'): void {
    const url = this.generateDeepLink({ app: 'daily-flow', screen });
    try { window.open(url, '_blank'); } catch {}
    eventBus.emit('deeplink:opened', { app: 'daily-flow', screen });
  }

  openInWriter(screen = 'new', params?: Record<string, string>): void {
    const url = this.generateDeepLink({ app: 'writer', screen, params });
    try { window.open(url, '_blank'); } catch {}
    eventBus.emit('deeplink:opened', { app: 'writer', screen });
  }

  openInHealth(screen = 'dashboard'): void {
    const url = this.generateDeepLink({ app: 'health', screen });
    try { window.open(url, '_blank'); } catch {}
    eventBus.emit('deeplink:opened', { app: 'health', screen });
  }

  // --- Notifications ---

  async sendCrossAppNotification(title: string, body: string, targetApp?: string): Promise<void> {
    eventBus.emit('notification:send', { title, body, targetApp, source: 'luminous-attachment' });
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification(title, { body, icon: '/icons/luminous-attachment.png', tag: 'resonance' });
    }
  }
}

// --- Helpers ---

function extractThemes(entries: Array<{ tags?: string[]; content?: string }>): string[] {
  const tagCounts: Record<string, number> = {};
  entries.forEach(e => {
    (e.tags || []).forEach(tag => { tagCounts[tag] = (tagCounts[tag] || 0) + 1; });
  });
  return Object.entries(tagCounts).sort((a, b) => b[1] - a[1]).slice(0, 5).map(([tag]) => tag);
}

// --- Singleton Export ---

export const resonanceConnect = new ResonanceConnect();
export default resonanceConnect;
