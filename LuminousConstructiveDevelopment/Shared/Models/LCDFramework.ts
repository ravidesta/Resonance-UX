// Luminous Constructive Development™ Core Domain Models — TypeScript/Web
// Mirrors Swift + Kotlin models for cross-platform parity

// ─── Developmental Orders (Kegan's Five Orders of Consciousness) ─────────

export enum DevelopmentalOrder {
  Impulsive = 1,
  Imperial = 2,
  Socialized = 3,
  SelfAuthoring = 4,
  SelfTransforming = 5,
}

export const OrderMeta: Record<DevelopmentalOrder, {
  name: string; description: string; gifts: string[]; shadow: string;
}> = {
  [DevelopmentalOrder.Impulsive]: {
    name: "Impulsive Mind",
    description: "Experience organized through immediate perceptions and impulses. Radical presence and sensory immediacy.",
    gifts: ["Radical presence", "Sensory aliveness", "Total absorption"],
    shadow: "No stable self-reflection; impulse-driven",
  },
  [DevelopmentalOrder.Imperial]: {
    name: "Imperial Mind",
    description: "Impulses coordinated into durable needs and interests. Foundation of purposeful action across time.",
    gifts: ["Purposeful action", "Self-direction", "Goal coordination"],
    shadow: "Others seen as instruments; limited genuine empathy",
  },
  [DevelopmentalOrder.Socialized]: {
    name: "Socialized Mind",
    description: "Deep capacity for empathy, loyalty, and relational attunement. Meaning drawn from the social surround.",
    gifts: ["Deep empathy", "Loyalty", "Relational attunement", "Belonging"],
    shadow: "Cannot author values independent of external validation",
  },
  [DevelopmentalOrder.SelfAuthoring]: {
    name: "Self-Authoring Mind",
    description: "Internal authority and self-generated values guide decisions. Capacity for principled autonomy.",
    gifts: ["Principled autonomy", "Internal compass", "Moral courage", "Boundary setting"],
    shadow: "Rigidity; ideology as identity; subtle contempt for dependency",
  },
  [DevelopmentalOrder.SelfTransforming]: {
    name: "Self-Transforming Mind",
    description: "Multiple frameworks held simultaneously. Comfort with paradox and the incomplete. Deepening wholeness.",
    gifts: ["Paradox-friendliness", "Multi-perspective holding", "Compassionate presence"],
    shadow: "Paralysis of perspective; evasion of commitment; drift",
  },
};

// ─── Life Domains ────────────────────────────────────────────────────────

export type LifeDomain = "personal" | "professional" | "relational" | "emotional" | "spiritual" | "somatic";

// ─── Subject-Object ──────────────────────────────────────────────────────

export interface SubjectObjectState {
  id: string;
  domain: LifeDomain;
  currentSubject: string;
  emergingObject?: string;
  somaticSignature?: string;
  reflectionNotes?: string;
  timestamp: string; // ISO 8601
}

// ─── Somatic Seasons ─────────────────────────────────────────────────────

export type SomaticSeason = "compression" | "trembling" | "emptiness" | "emergence" | "integration";

export const SeasonMeta: Record<SomaticSeason, {
  description: string; bodyPrompt: string;
}> = {
  compression: {
    description: "Increasing tension. The old structure strains against life demands it cannot accommodate.",
    bodyPrompt: "Where do you feel tightness or constriction right now?",
  },
  trembling: {
    description: "Instability between structures. Waves of emotion without clear trigger. The system is reorganizing.",
    bodyPrompt: "What sensations of instability or movement do you notice?",
  },
  emptiness: {
    description: "Surprising stillness. Formlessness. Waiting. Not-yet-knowing.",
    bodyPrompt: "Where do you feel spaciousness or quiet in your body?",
  },
  emergence: {
    description: "New patterns taking shape — first in the body, before cognition catches up.",
    bodyPrompt: "What new sensations or patterns are you beginning to notice?",
  },
  integration: {
    description: "The new structure consolidates. What was effortful becomes natural.",
    bodyPrompt: "Where does your body feel settled and at home?",
  },
};

// ─── Assessment ──────────────────────────────────────────────────────────

export interface DomainAssessment {
  id: string;
  domain: LifeDomain;
  primaryOrder: DevelopmentalOrder;
  emergingOrder?: DevelopmentalOrder;
  subjectTerritory: string[];
  objectTerritory: string[];
  growingEdge?: string;
  confidence: number;
}

export interface DevelopmentalAssessment {
  id: string;
  userId: string;
  date: string;
  domainAssessments: DomainAssessment[];
  overallReflection?: string;
  somaticSeason?: SomaticSeason;
  guideNotes?: string;
}

// ─── Journal ─────────────────────────────────────────────────────────────

export type JournalEntryType =
  | "freeWrite" | "subjectScan" | "relationalMirror" | "somaticWitness"
  | "spiralMapping" | "gratitudeForSelf" | "seasonInquiry" | "guideDialogue";

export type Mood = "spacious" | "tender" | "activated" | "contracted" | "curious" | "grieving" | "emerging" | "settled";

export interface BodyLocation {
  area: string;
  sensation: string;
  intensity: number;
}

export interface JournalEntry {
  id: string;
  timestamp: string;
  type: JournalEntryType;
  prompt?: string;
  content: string;
  somaticNotes?: string;
  bodyLocations?: BodyLocation[];
  developmentalOrder?: DevelopmentalOrder;
  season?: SomaticSeason;
  mood?: Mood;
  isShareable: boolean;
  shareExcerpt?: string;
}

// ─── Somatic Practices ───────────────────────────────────────────────────

export type PracticeCategory =
  | "bodyScan" | "breathwork" | "movement" | "somaticPause"
  | "grounding" | "nervousSystem" | "relationalSomatic";

export interface SomaticPractice {
  id: string;
  name: string;
  description: string;
  durationSeconds: number;
  category: PracticeCategory;
  season?: SomaticSeason;
  audioAssetKey?: string;
  videoAssetKey?: string;
  instructions: string[];
  developmentalContext?: string;
  isShareable: boolean;
}

// ─── eBook ───────────────────────────────────────────────────────────────

export interface EBookSection {
  id: string;
  title: string;
  body: string;
  type: "prose" | "caseStudy" | "practice" | "reflection" | "luminousInvitation" | "pitfall" | "safetyNote";
}

export interface EBookChapter {
  id: string;
  number: number;
  title: string;
  epigraph?: string;
  sections: EBookSection[];
  wordCount: number;
}

export interface ReadingPosition {
  chapterIndex: number;
  sectionIndex: number;
  paragraphIndex: number;
  scrollOffset: number;
  lastRead: string;
}

export type HighlightColor = "gold" | "forest" | "somatic" | "relational" | "integration";

export interface Highlight {
  id: string;
  chapterIndex: number;
  sectionIndex: number;
  startChar: number;
  endChar: number;
  text: string;
  color: HighlightColor;
  note?: string;
  isShareable: boolean;
  timestamp: string;
}

export interface EBook {
  id: string;
  title: string;
  subtitle: string;
  author: string;
  coverAssetKey: string;
  chapters: EBookChapter[];
  totalWordCount: number;
  estimatedReadingTimeSeconds: number;
  currentPosition?: ReadingPosition;
  bookmarks: ReadingPosition[];
  highlights: Highlight[];
}

// ─── Audiobook ───────────────────────────────────────────────────────────

export interface AudioChapter {
  id: string;
  number: number;
  title: string;
  audioAssetKey: string;
  durationSeconds: number;
  startTimeSeconds: number;
}

export interface AudioPosition {
  chapterIndex: number;
  timeOffsetSeconds: number;
  lastPlayed: string;
}

export interface Audiobook {
  id: string;
  title: string;
  narrator: string;
  totalDurationSeconds: number;
  chapters: AudioChapter[];
  currentPosition?: AudioPosition;
  playbackSpeed: number;
  sleepTimerMinutes?: number;
}

// ─── Guide / AI Tutor-Coach ──────────────────────────────────────────────

export type GuideSessionType =
  | "exploration" | "somaticGuidance" | "reflectionSupport" | "assessmentDebrief"
  | "crisisSupport" | "practiceGuidance" | "bookDiscussion";

export interface GuideMessage {
  id: string;
  role: "user" | "guide" | "system";
  content: string;
  somaticPrompt?: string;
  timestamp: string;
}

export interface GuideSession {
  id: string;
  userId: string;
  startTime: string;
  messages: GuideMessage[];
  sessionType: GuideSessionType;
}

// ─── Social Sharing ──────────────────────────────────────────────────────

export type ShareType = "quote" | "highlight" | "reflection" | "insight" | "practiceCompletion" | "milestone";
export type ShareBackground = "forestGold" | "creamSerif" | "deepRestGlow" | "somaticWave" | "spiralPattern";

export interface ShareableContent {
  id: string;
  type: ShareType;
  title: string;
  excerpt: string;
  attributionLine: string;
  backgroundStyle: ShareBackground;
  sourceChapter?: number;
  generatedImageUrl?: string;
  deepLink: string;
}

// ─── Community ───────────────────────────────────────────────────────────

export type IntentionalStatus = "reflecting" | "openToConnect" | "inPractice" | "deepWork" | "resting";
export type PostType = "reflection" | "insight" | "question" | "sharedHighlight" | "sharedPractice" | "gratitude";

export interface CommunityMember {
  id: string;
  displayName: string;
  avatarUrl?: string;
  joinDate: string;
  intentionalStatus: IntentionalStatus;
}

export interface CommunityPost {
  id: string;
  authorId: string;
  content: string;
  type: PostType;
  sharedHighlightId?: string;
  sharedPracticeId?: string;
  timestamp: string;
  resonanceCount: number;
}

// ─── Ecosystem Integration ───────────────────────────────────────────────

export interface ResonanceIntegration {
  dailyFlowSync: boolean;
  resonanceCommsSync: boolean;
  writerSync: boolean;
  iPadProviderSync: boolean;
  watchSync: boolean;
}
