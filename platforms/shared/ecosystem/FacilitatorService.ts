/**
 * FacilitatorService.ts
 * Luminous Cosmic Architecture™ — Shared Facilitator Service
 *
 * Cross-platform service for the AI Facilitator (cosmic teacher/coach/guide).
 * Handles message flow, conversation context, voice abstraction,
 * guide personality, session persistence, and pre-built conversation flows.
 */

// ─────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────

export type MessageRole = 'user' | 'guide';
export type InputMode = 'text' | 'voice';

export interface FacilitatorMessage {
  id: string;
  role: MessageRole;
  content: string;
  timestamp: number;
  inputMode: InputMode;
  /** If voice, duration in seconds */
  voiceDuration?: number;
}

export interface ConversationThread {
  id: string;
  title: string;
  messages: FacilitatorMessage[];
  createdAt: number;
  updatedAt: number;
  flow?: ConversationFlowType;
  context: ConversationContext;
}

export interface ConversationContext {
  /** User's natal chart data for personalized guidance */
  sunSign?: string;
  moonSign?: string;
  risingSign?: string;
  natalPlacements?: PlanetPlacement[];
  /** Current sky conditions */
  currentTransits?: TransitInfo[];
  currentMoonPhase?: string;
  currentMoonSign?: string;
  /** Reading/engagement history */
  recentChaptersRead?: string[];
  recentReflections?: string[];
  journalMoodTrend?: string;
  /** Session metadata */
  sessionCount: number;
  lastSessionDate?: number;
}

export interface PlanetPlacement {
  planet: string;
  sign: string;
  house: number;
  degree: number;
}

export interface TransitInfo {
  planet: string;
  sign: string;
  aspect?: string;
  natalTarget?: string;
  description?: string;
}

export type ConversationFlowType =
  | 'chart_reading'
  | 'daily_guidance'
  | 'meditation_guidance'
  | 'book_discussion'
  | 'personal_development'
  | 'open';

export interface GuidePersonality {
  name: string;
  tone: 'warm' | 'contemplative' | 'encouraging' | 'playful';
  style: 'poetic' | 'conversational' | 'socratic' | 'narrative';
  nonDeterministic: boolean;
  useAstrologyFramework: boolean;
  developmentalFocus: boolean;
}

export interface ConversationStarter {
  label: string;
  prompt: string;
  flow: ConversationFlowType;
  icon?: string;
}

export interface VoiceAdapter {
  startListening(): Promise<void>;
  stopListening(): Promise<string>;
  speak(text: string, options?: VoiceSpeakOptions): Promise<void>;
  stopSpeaking(): void;
  isListening(): boolean;
  isSpeaking(): boolean;
}

export interface VoiceSpeakOptions {
  rate?: number;
  pitch?: number;
  voice?: string;
}

export interface StorageAdapter {
  save(key: string, data: string): Promise<void>;
  load(key: string): Promise<string | null>;
  remove(key: string): Promise<void>;
}

// ─────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────

const STORAGE_KEY_THREADS = 'lca-facilitator-threads';
const STORAGE_KEY_CONTEXT = 'lca-facilitator-context';
const MAX_CONTEXT_MESSAGES = 50;

export const DEFAULT_PERSONALITY: GuidePersonality = {
  name: 'Luminous Guide',
  tone: 'warm',
  style: 'conversational',
  nonDeterministic: true,
  useAstrologyFramework: true,
  developmentalFocus: true,
};

export const CONVERSATION_STARTERS: ConversationStarter[] = [
  {
    label: 'Tell me about my chart',
    prompt:
      'I would love to understand my natal chart more deeply. Can you walk me through the key themes and patterns you see?',
    flow: 'chart_reading',
    icon: '\u2609', // Sun glyph
  },
  {
    label: 'What should I focus on today?',
    prompt:
      'Based on the current transits and my chart, what energies are most relevant for me today? What might I pay attention to?',
    flow: 'daily_guidance',
    icon: '\u2728',
  },
  {
    label: 'Help me understand my Moon sign',
    prompt:
      'I want to explore what my Moon sign means for my emotional world and inner life. Can you guide me through this?',
    flow: 'chart_reading',
    icon: '\u263D', // Moon glyph
  },
  {
    label: 'Guide me through a reflection',
    prompt:
      'I would like a guided reflection or meditation that connects me with the current cosmic energies. Please lead me through it.',
    flow: 'meditation_guidance',
    icon: '\u2618', // Shamrock / peaceful
  },
];

// ─────────────────────────────────────────────
// Response Templates
// ─────────────────────────────────────────────

interface ResponseTemplate {
  flow: ConversationFlowType;
  stage: 'opening' | 'deepening' | 'closing' | 'follow_up';
  templates: string[];
}

const RESPONSE_TEMPLATES: ResponseTemplate[] = [
  // Chart Reading
  {
    flow: 'chart_reading',
    stage: 'opening',
    templates: [
      "Let's take a gentle look at your chart together. With your Sun in {{sunSign}}, there's a core vitality that shapes how you express yourself in the world. But remember, a chart is a living map, not a fixed destiny. What draws your curiosity first?",
      "Your natal chart is like a cosmic fingerprint \u2014 entirely your own. I see your Sun shining in {{sunSign}}, your Moon resting in {{moonSign}}, and {{risingSign}} rising on your horizon. Each of these tells a story. Where would you like to begin?",
      "Welcome to this exploration. Your chart holds many layers of meaning. With {{sunSign}} as your solar center and {{moonSign}} as your emotional ground, there's a beautiful interplay between how you shine outwardly and how you feel inwardly. What resonates with you so far?",
    ],
  },
  {
    flow: 'chart_reading',
    stage: 'deepening',
    templates: [
      "That's a wonderful question. Your {{planet}} in {{sign}} in the {{house}} house suggests a pattern of {{theme}}. But astrology invites us not just to know, but to work with these energies consciously. How does this land for you?",
      "There's something interesting here. The relationship between your {{planet}} and your natal {{natalTarget}} creates a dynamic tension \u2014 not a problem to solve, but a creative edge to explore. What comes up when you sit with that?",
    ],
  },
  {
    flow: 'chart_reading',
    stage: 'closing',
    templates: [
      "This has been a rich exploration. Remember, your chart doesn't determine your path \u2014 it illuminates the landscape you're walking through. Carry what resonated with you, and let the rest settle in its own time.",
      "Thank you for bringing your curiosity to this conversation. The chart is always there as a mirror, and you can return to it whenever you need perspective. What one insight feels most alive for you right now?",
    ],
  },

  // Daily Guidance
  {
    flow: 'daily_guidance',
    stage: 'opening',
    templates: [
      "Today the Moon is in {{currentMoonSign}}, which colors the emotional atmosphere with a quality of {{moonQuality}}. For your {{sunSign}} Sun, this could invite you to {{invitation}}. What feels most present for you this morning?",
      "Good to connect with you today. The sky is active \u2014 {{transitSummary}}. For someone with your chart, this moment asks for {{guidance}}. How are you feeling as you move into this day?",
    ],
  },
  {
    flow: 'daily_guidance',
    stage: 'deepening',
    templates: [
      "I hear you. With {{planet}} currently moving through {{sign}}, there is an opportunity to {{opportunity}}. This isn't about forcing anything, but about recognizing where the current wants to carry you. What small step might honor that flow?",
    ],
  },

  // Meditation Guidance
  {
    flow: 'meditation_guidance',
    stage: 'opening',
    templates: [
      "Let's begin by finding a comfortable stillness. Close your eyes if you like, and take three slow breaths. With each exhale, let go of whatever you carried into this moment...\n\nThe Moon is in {{currentMoonSign}} right now, and the quality of this energy is {{moonQuality}}. Let's use that as our doorway inward.",
      "Thank you for choosing to be present with yourself. This is a form of courage. Let's begin by simply noticing your breath, your body, the weight of you against whatever supports you...\n\nToday's cosmic atmosphere is shaped by {{transitSummary}}. We'll let that guide our reflection gently.",
    ],
  },
  {
    flow: 'meditation_guidance',
    stage: 'deepening',
    templates: [
      "Now, bring your attention to your heart center. Imagine a soft golden light there \u2014 the same gold as the Sun's light. This light is your essential nature, your {{sunSign}} vitality. Let it pulse gently with each heartbeat...\n\nAs this light expands, it meets the silver light of your {{moonSign}} Moon \u2014 your feeling nature, your depths. Notice where these two lights blend.",
    ],
  },
  {
    flow: 'meditation_guidance',
    stage: 'closing',
    templates: [
      "Slowly begin to return to the room around you. Bring with you whatever insight or feeling emerged during this time. There's no need to analyze it yet \u2014 just hold it gently, the way the sky holds the stars.\n\nWhen you're ready, open your eyes. How do you feel?",
    ],
  },

  // Book Discussion
  {
    flow: 'book_discussion',
    stage: 'opening',
    templates: [
      "I'd love to explore the book with you. The Luminous Cosmic Architecture offers not just knowledge, but an invitation to see yourself and the cosmos differently. Is there a chapter or concept that's been on your mind?",
      "Reading is one thing; integrating what we read into lived experience is another. Let's talk about what's resonating for you in the book. What passage or idea keeps circling back to you?",
    ],
  },
  {
    flow: 'book_discussion',
    stage: 'deepening',
    templates: [
      "That's a powerful passage to sit with. The book invites us to consider {{concept}} not as abstract theory, but as something we can feel in our daily lives. How does this idea show up in your own experience?",
    ],
  },

  // Personal Development
  {
    flow: 'personal_development',
    stage: 'opening',
    templates: [
      "Growth is not always about adding more \u2014 sometimes it's about becoming more of who you already are. With your chart's signature, there are natural strengths to lean into and growing edges to approach with compassion. What area of your life is calling for your attention right now?",
      "I'm glad you're here for this kind of conversation. Personal development through a cosmic lens isn't about fixing what's broken \u2014 it's about understanding the design and working with it. What's stirring in you today?",
    ],
  },
  {
    flow: 'personal_development',
    stage: 'deepening',
    templates: [
      "What you're describing sounds like a {{planet}} in {{sign}} theme coming to the surface. This energy often manifests as {{manifestation}}. The developmental invitation here is not to overcome it, but to develop a more conscious relationship with it. What would that look like for you?",
    ],
  },
  {
    flow: 'personal_development',
    stage: 'closing',
    templates: [
      "You've done meaningful work in this conversation. Growth happens in small moments of awareness, and you've been present with yourself today. Before we close, is there one intention or commitment you'd like to carry forward from this?",
    ],
  },
];

// ─────────────────────────────────────────────
// Utility
// ─────────────────────────────────────────────

function generateId(): string {
  return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
}

function pickRandom<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function substituteTemplate(
  template: string,
  context: ConversationContext
): string {
  const replacements: Record<string, string | undefined> = {
    sunSign: context.sunSign,
    moonSign: context.moonSign,
    risingSign: context.risingSign,
    currentMoonSign: context.currentMoonSign,
    currentMoonPhase: context.currentMoonPhase,
    moonQuality: getMoonQuality(context.currentMoonSign),
    transitSummary: getTransitSummary(context.currentTransits),
    invitation: getInvitation(context.sunSign, context.currentMoonSign),
    guidance: getGuidance(context),
  };

  let result = template;
  for (const [key, value] of Object.entries(replacements)) {
    if (value) {
      result = result.replace(new RegExp(`\\{\\{${key}\\}\\}`, 'g'), value);
    }
  }
  return result;
}

function getMoonQuality(moonSign?: string): string {
  const qualities: Record<string, string> = {
    Aries: 'bold initiative and fresh beginnings',
    Taurus: 'sensory comfort and steady presence',
    Gemini: 'curious exploration and lively exchange',
    Cancer: 'deep nurturing and emotional attunement',
    Leo: 'radiant self-expression and heartfelt warmth',
    Virgo: 'thoughtful refinement and mindful service',
    Libra: 'harmonious relating and aesthetic appreciation',
    Scorpio: 'profound depth and transformative honesty',
    Sagittarius: 'expansive vision and adventurous spirit',
    Capricorn: 'structured ambition and grounded wisdom',
    Aquarius: 'innovative thinking and communal awareness',
    Pisces: 'dreamy intuition and compassionate flow',
  };
  return moonSign ? qualities[moonSign] || 'quiet attentiveness' : 'quiet attentiveness';
}

function getTransitSummary(transits?: TransitInfo[]): string {
  if (!transits || transits.length === 0) {
    return 'the planets are weaving their stories overhead';
  }
  const descriptions = transits
    .filter((t) => t.description)
    .map((t) => t.description);
  if (descriptions.length > 0) return descriptions.slice(0, 2).join(', and ');
  return transits
    .slice(0, 2)
    .map((t) => `${t.planet} in ${t.sign}`)
    .join(' and ');
}

function getInvitation(sunSign?: string, moonSign?: string): string {
  if (!sunSign) return 'be present with whatever arises';
  const invitations: Record<string, string> = {
    Aries: 'pause before acting and listen to the deeper impulse beneath the urgency',
    Taurus: 'notice where comfort becomes complacency and where stability becomes strength',
    Gemini: 'let your curiosity settle on one thread and follow it deeply today',
    Cancer: 'tend to your own emotional needs before extending your care outward',
    Leo: 'express something authentic, even if it feels vulnerable',
    Virgo: 'release the need for perfection and find beauty in what is',
    Libra: 'honor your own truth even when it disrupts harmony',
    Scorpio: 'bring something hidden into the light with gentleness',
    Sagittarius: 'ground your vision in a single practical step',
    Capricorn: 'let yourself be held by something greater than your own effort',
    Aquarius: 'connect your ideals to an act of personal tenderness',
    Pisces: 'give form to what you feel, through words, art, or movement',
  };
  return invitations[sunSign] || 'be present with whatever arises';
}

function getGuidance(context: ConversationContext): string {
  return 'a blend of intention and receptivity \u2014 knowing when to act and when to simply be';
}

// ─────────────────────────────────────────────
// FacilitatorService
// ─────────────────────────────────────────────

export class FacilitatorService {
  private threads: ConversationThread[] = [];
  private activeThreadId: string | null = null;
  private context: ConversationContext;
  private personality: GuidePersonality;
  private voiceAdapter: VoiceAdapter | null = null;
  private storageAdapter: StorageAdapter | null = null;
  private onMessageCallback: ((message: FacilitatorMessage) => void) | null = null;
  private onTypingCallback: ((isTyping: boolean) => void) | null = null;

  constructor(
    personality: GuidePersonality = DEFAULT_PERSONALITY,
    context?: Partial<ConversationContext>
  ) {
    this.personality = personality;
    this.context = {
      sessionCount: 0,
      ...context,
    };
  }

  // ── Adapters ──

  setVoiceAdapter(adapter: VoiceAdapter): void {
    this.voiceAdapter = adapter;
  }

  setStorageAdapter(adapter: StorageAdapter): void {
    this.storageAdapter = adapter;
  }

  // ── Callbacks ──

  onMessage(callback: (message: FacilitatorMessage) => void): void {
    this.onMessageCallback = callback;
  }

  onTyping(callback: (isTyping: boolean) => void): void {
    this.onTypingCallback = callback;
  }

  // ── Thread Management ──

  getThreads(): ConversationThread[] {
    return [...this.threads].sort((a, b) => b.updatedAt - a.updatedAt);
  }

  getActiveThread(): ConversationThread | null {
    if (!this.activeThreadId) return null;
    return this.threads.find((t) => t.id === this.activeThreadId) || null;
  }

  createThread(
    title?: string,
    flow: ConversationFlowType = 'open'
  ): ConversationThread {
    const thread: ConversationThread = {
      id: generateId(),
      title: title || this.generateThreadTitle(flow),
      messages: [],
      createdAt: Date.now(),
      updatedAt: Date.now(),
      flow,
      context: { ...this.context },
    };
    this.threads.push(thread);
    this.activeThreadId = thread.id;
    this.persistThreads();
    return thread;
  }

  switchThread(threadId: string): ConversationThread | null {
    const thread = this.threads.find((t) => t.id === threadId);
    if (thread) {
      this.activeThreadId = thread.id;
      return thread;
    }
    return null;
  }

  deleteThread(threadId: string): void {
    this.threads = this.threads.filter((t) => t.id !== threadId);
    if (this.activeThreadId === threadId) {
      this.activeThreadId = this.threads[0]?.id || null;
    }
    this.persistThreads();
  }

  private generateThreadTitle(flow: ConversationFlowType): string {
    const titles: Record<ConversationFlowType, string[]> = {
      chart_reading: ['Chart Exploration', 'Reading My Stars', 'Natal Chart Session'],
      daily_guidance: ['Daily Guidance', "Today's Cosmic Weather", 'Morning Check-in'],
      meditation_guidance: ['Guided Reflection', 'Cosmic Meditation', 'Inner Journey'],
      book_discussion: ['Book Discussion', 'Exploring the Text', 'Chapter Reflection'],
      personal_development: ['Growth Session', 'Personal Exploration', 'Development Path'],
      open: ['Open Conversation', 'Cosmic Dialogue', 'Starlit Exchange'],
    };
    const dateStr = new Date().toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
    });
    return `${pickRandom(titles[flow])} \u2014 ${dateStr}`;
  }

  // ── Context Management ──

  updateContext(updates: Partial<ConversationContext>): void {
    this.context = { ...this.context, ...updates };
    const thread = this.getActiveThread();
    if (thread) {
      thread.context = { ...this.context };
    }
    this.persistContext();
  }

  getContext(): ConversationContext {
    return { ...this.context };
  }

  // ── Personality ──

  setPersonality(updates: Partial<GuidePersonality>): void {
    this.personality = { ...this.personality, ...updates };
  }

  getPersonality(): GuidePersonality {
    return { ...this.personality };
  }

  // ── Message Handling ──

  async sendMessage(content: string, inputMode: InputMode = 'text'): Promise<FacilitatorMessage> {
    let thread = this.getActiveThread();
    if (!thread) {
      thread = this.createThread();
    }

    // Create user message
    const userMessage: FacilitatorMessage = {
      id: generateId(),
      role: 'user',
      content,
      timestamp: Date.now(),
      inputMode,
    };
    thread.messages.push(userMessage);
    thread.updatedAt = Date.now();
    this.onMessageCallback?.(userMessage);

    // Generate guide response
    this.onTypingCallback?.(true);

    // Simulate thinking delay for natural pacing
    await this.simulateThinking();

    const guideResponse = this.generateResponse(thread);
    thread.messages.push(guideResponse);
    thread.updatedAt = Date.now();

    this.onTypingCallback?.(false);
    this.onMessageCallback?.(guideResponse);

    // Trim context if too long
    if (thread.messages.length > MAX_CONTEXT_MESSAGES) {
      thread.messages = thread.messages.slice(-MAX_CONTEXT_MESSAGES);
    }

    this.context.sessionCount += 1;
    this.context.lastSessionDate = Date.now();
    this.persistThreads();

    return guideResponse;
  }

  private generateResponse(thread: ConversationThread): FacilitatorMessage {
    const flow = thread.flow || 'open';
    const messageCount = thread.messages.length;
    const lastUserMessage = thread.messages
      .filter((m) => m.role === 'user')
      .pop();

    // Determine conversation stage
    let stage: 'opening' | 'deepening' | 'closing' | 'follow_up';
    if (messageCount <= 2) {
      stage = 'opening';
    } else if (messageCount > 10) {
      stage = 'closing';
    } else {
      stage = 'deepening';
    }

    // Find matching templates
    const matchingTemplates = RESPONSE_TEMPLATES.filter(
      (t) => t.flow === flow && t.stage === stage
    );

    let responseContent: string;

    if (matchingTemplates.length > 0) {
      const template = pickRandom(matchingTemplates);
      const rawTemplate = pickRandom(template.templates);
      responseContent = substituteTemplate(rawTemplate, thread.context);
    } else {
      // Fallback to open-ended, warm response
      responseContent = this.generateOpenResponse(lastUserMessage?.content || '', thread.context);
    }

    return {
      id: generateId(),
      role: 'guide',
      content: responseContent,
      timestamp: Date.now(),
      inputMode: 'text',
    };
  }

  private generateOpenResponse(userInput: string, context: ConversationContext): string {
    const openResponses = [
      "That's a meaningful question to sit with. In the framework of your chart, with {{sunSign}} as your guiding light, there's a particular way this theme might unfold for you. Tell me more about what's alive in this for you.",
      "I appreciate you sharing that. There's a thread here worth following. The cosmos doesn't give us easy answers, but it does offer us lenses \u2014 ways of seeing that can illuminate what we might otherwise miss. What do you sense beneath the surface of what you've described?",
      "Thank you for your honesty. Growth often begins at the edge of what we know, and you seem to be standing at such an edge right now. With the Moon currently in {{currentMoonSign}}, this is a moment that favors {{moonQuality}}. How might you lean into that quality today?",
      "What you're describing resonates with a pattern I see in many charts, but it's uniquely yours in how it manifests. Rather than offering you an answer, let me reflect something back to you: what part of what you've shared feels most true, most essential? Start there.",
      "There's wisdom in what you're noticing. The astrological tradition would say you're touching on themes related to your chart's deeper architecture. But beyond any framework, trust what your own experience is telling you. What does your intuition say?",
    ];

    return substituteTemplate(pickRandom(openResponses), context);
  }

  private simulateThinking(): Promise<void> {
    const delay = 800 + Math.random() * 1500; // 0.8-2.3 seconds
    return new Promise((resolve) => setTimeout(resolve, delay));
  }

  // ── Voice ──

  async startVoiceInput(): Promise<void> {
    if (!this.voiceAdapter) {
      throw new Error('Voice adapter not configured');
    }
    await this.voiceAdapter.startListening();
  }

  async stopVoiceInput(): Promise<string> {
    if (!this.voiceAdapter) {
      throw new Error('Voice adapter not configured');
    }
    return this.voiceAdapter.stopListening();
  }

  async speakResponse(text: string): Promise<void> {
    if (!this.voiceAdapter) {
      throw new Error('Voice adapter not configured');
    }
    await this.voiceAdapter.speak(text, {
      rate: 0.92,
      pitch: 1.0,
    });
  }

  stopSpeaking(): void {
    this.voiceAdapter?.stopSpeaking();
  }

  isListening(): boolean {
    return this.voiceAdapter?.isListening() ?? false;
  }

  isSpeaking(): boolean {
    return this.voiceAdapter?.isSpeaking() ?? false;
  }

  // ── Persistence ──

  private async persistThreads(): Promise<void> {
    if (!this.storageAdapter) return;
    try {
      await this.storageAdapter.save(
        STORAGE_KEY_THREADS,
        JSON.stringify(this.threads)
      );
    } catch {
      // Silent fail for persistence
    }
  }

  private async persistContext(): Promise<void> {
    if (!this.storageAdapter) return;
    try {
      await this.storageAdapter.save(
        STORAGE_KEY_CONTEXT,
        JSON.stringify(this.context)
      );
    } catch {
      // Silent fail for persistence
    }
  }

  async loadPersistedData(): Promise<void> {
    if (!this.storageAdapter) return;

    try {
      const threadsJson = await this.storageAdapter.load(STORAGE_KEY_THREADS);
      if (threadsJson) {
        this.threads = JSON.parse(threadsJson);
        if (this.threads.length > 0) {
          this.activeThreadId = this.threads.sort(
            (a, b) => b.updatedAt - a.updatedAt
          )[0].id;
        }
      }

      const contextJson = await this.storageAdapter.load(STORAGE_KEY_CONTEXT);
      if (contextJson) {
        this.context = { ...this.context, ...JSON.parse(contextJson) };
      }
    } catch {
      // Silent fail for loading
    }
  }

  async clearAllData(): Promise<void> {
    this.threads = [];
    this.activeThreadId = null;
    if (this.storageAdapter) {
      await this.storageAdapter.remove(STORAGE_KEY_THREADS);
      await this.storageAdapter.remove(STORAGE_KEY_CONTEXT);
    }
  }

  // ── Conversation Starters ──

  getConversationStarters(): ConversationStarter[] {
    return CONVERSATION_STARTERS;
  }

  async startFromStarter(starter: ConversationStarter): Promise<FacilitatorMessage> {
    this.createThread(undefined, starter.flow);
    return this.sendMessage(starter.prompt, 'text');
  }
}

export default FacilitatorService;
