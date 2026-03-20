/**
 * Resonance UX Database Schema
 *
 * Prisma-style TypeScript schema definitions for all data models.
 * These serve as the canonical database schema and can be used to
 * generate Prisma schema files or other ORM configurations.
 */

// ---------------------------------------------------------------------------
// Enums (mirroring shared/types but defined here for DB layer)
// ---------------------------------------------------------------------------

export const ThemeMode = {
  light: 'light',
  deepRest: 'deep-rest',
  system: 'system',
} as const;

export const FlowPhase = {
  dawn: 'dawn',
  morningFocus: 'morning-focus',
  midday: 'midday',
  afternoon: 'afternoon',
  evening: 'evening',
  deepRest: 'deep-rest',
} as const;

export const EnergyLevel = {
  peak: 'peak',
  high: 'high',
  moderate: 'moderate',
  low: 'low',
  rest: 'rest',
} as const;

export const TaskStatus = {
  open: 'open',
  inProgress: 'in-progress',
  completed: 'completed',
  deferred: 'deferred',
  archived: 'archived',
} as const;

export const TaskPriority = {
  urgent: 'urgent',
  high: 'high',
  normal: 'normal',
  low: 'low',
  someday: 'someday',
} as const;

export const IntentionalStatusType = {
  available: 'available',
  focused: 'focused',
  creating: 'creating',
  resting: 'resting',
  away: 'away',
  doNotDisturb: 'do-not-disturb',
} as const;

export const MessageType = {
  text: 'text',
  voice: 'voice',
  image: 'image',
  document: 'document',
  system: 'system',
} as const;

export const CallStatus = {
  ringing: 'ringing',
  active: 'active',
  ended: 'ended',
  missed: 'missed',
  declined: 'declined',
} as const;

export const DocumentFormat = {
  prose: 'prose',
  markdown: 'markdown',
  richText: 'rich-text',
  plainText: 'plain-text',
} as const;

export const BiomarkerCategory = {
  cardiovascular: 'cardiovascular',
  metabolic: 'metabolic',
  hormonal: 'hormonal',
  inflammatory: 'inflammatory',
  neurological: 'neurological',
  nutritional: 'nutritional',
} as const;

export const ProtocolStatus = {
  active: 'active',
  paused: 'paused',
  completed: 'completed',
  draft: 'draft',
} as const;

export const SyncAction = {
  create: 'create',
  update: 'update',
  delete: 'delete',
  merge: 'merge',
} as const;

export const DevicePlatform = {
  web: 'web',
  ios: 'ios',
  android: 'android',
  macos: 'macos',
  windows: 'windows',
  linux: 'linux',
  watchos: 'watchos',
  tvos: 'tvos',
} as const;

// ---------------------------------------------------------------------------
// Model Interfaces (DB row shapes)
// ---------------------------------------------------------------------------

/** Base fields present on every model */
export interface BaseModel {
  id: string;         // UUID primary key
  createdAt: Date;
  updatedAt: Date;
}

// ---- Users & Auth ----

export interface UserRow extends BaseModel {
  email: string;          // unique
  passwordHash: string;
  displayName: string;
  avatarUrl: string | null;
  isActive: boolean;
  lastLoginAt: Date | null;
}

export interface UserPreferencesRow {
  id: string;
  userId: string;         // FK -> User.id, unique
  theme: keyof typeof ThemeMode;
  notificationsEnabled: boolean;
  quietHoursStart: string | null;   // HH:mm
  quietHoursEnd: string | null;
  defaultEnergyLevel: keyof typeof EnergyLevel;
  syncEnabled: boolean;
  reducedMotion: boolean;
  fontSize: 'small' | 'medium' | 'large';
}

export interface RefreshTokenRow {
  id: string;
  userId: string;         // FK -> User.id
  tokenHash: string;
  expiresAt: Date;
  revokedAt: Date | null;
  createdAt: Date;
}

// ---- Profile & Status ----

export interface ProfileRow extends BaseModel {
  userId: string;         // FK -> User.id, unique
  bio: string | null;
}

export interface IntentionalStatusRow {
  id: string;
  userId: string;         // FK -> User.id
  type: keyof typeof IntentionalStatusType;
  message: string | null;
  emoji: string | null;
  expiresAt: Date | null;
  createdAt: Date;
}

// ---- Flow (Daily Rhythm) ----

export interface DailyPhaseConfigRow {
  id: string;
  userId: string;         // FK -> User.id
  phase: keyof typeof FlowPhase;
  startTime: string;      // HH:mm
  endTime: string;
  label: string | null;
  energyLevel: keyof typeof EnergyLevel;
  notificationsAllowed: boolean;
  sortOrder: number;
}

export interface DailyFlowSnapshotRow {
  id: string;
  userId: string;
  date: string;           // YYYY-MM-DD, compound unique with userId
  spaciousnessPercent: number;
  scheduledMinutes: number;
  freeMinutes: number;
  completedTasks: number;
  totalTasks: number;
  createdAt: Date;
}

// ---- Focus (Tasks) ----

export interface DomainRow extends BaseModel {
  userId: string;
  name: string;
  color: string;
  icon: string | null;
  sortOrder: number;
  isArchived: boolean;
}

export interface TaskRow extends BaseModel {
  userId: string;
  title: string;
  description: string | null;
  status: keyof typeof TaskStatus;
  priority: keyof typeof TaskPriority;
  domainId: string | null; // FK -> Domain.id
  energyRequired: keyof typeof EnergyLevel;
  estimatedMinutes: number | null;
  actualMinutes: number | null;
  scheduledDate: string | null;
  scheduledPhase: keyof typeof FlowPhase | null;
  completedAt: Date | null;
  archivedAt: Date | null;
}

export interface SubtaskRow {
  id: string;
  taskId: string;         // FK -> Task.id
  title: string;
  completed: boolean;
  sortOrder: number;
}

export interface TaskTagRow {
  taskId: string;         // FK -> Task.id
  tag: string;            // compound PK (taskId, tag)
}

export interface EnergyLogRow {
  id: string;
  userId: string;
  level: keyof typeof EnergyLevel;
  loggedAt: Date;
  note: string | null;
}

// ---- Letters (Communication) ----

export interface ContactRow extends BaseModel {
  userId: string;
  displayName: string;
  email: string | null;
  phone: string | null;
  avatarUrl: string | null;
  lastContactedAt: Date | null;
  isFavorite: boolean;
  notes: string | null;
}

export interface ConversationRow extends BaseModel {
  // Many-to-many with users via ConversationParticipant
  lastMessageAt: Date | null;
}

export interface ConversationParticipantRow {
  conversationId: string;  // FK -> Conversation.id
  userId: string;          // FK -> User.id  (compound PK)
  unreadCount: number;
  mutedUntil: Date | null;
  joinedAt: Date;
}

export interface MessageRow extends BaseModel {
  conversationId: string;  // FK -> Conversation.id
  senderId: string;        // FK -> User.id
  type: keyof typeof MessageType;
  content: string;
  readAt: Date | null;
}

export interface MessageMetadataRow {
  messageId: string;       // FK -> Message.id, unique
  voiceDurationMs: number | null;
  voiceTranscript: string | null;
  imageWidth: number | null;
  imageHeight: number | null;
  fileName: string | null;
  fileSize: number | null;
  mimeType: string | null;
}

export interface VoiceMessageRow extends BaseModel {
  messageId: string;       // FK -> Message.id, unique
  audioUrl: string;
  durationMs: number;
  waveform: number[];      // JSON column
  transcript: string | null;
}

export interface VideoCallRow extends BaseModel {
  conversationId: string;  // FK -> Conversation.id
  initiatorId: string;     // FK -> User.id
  status: keyof typeof CallStatus;
  startedAt: Date | null;
  endedAt: Date | null;
  durationMs: number | null;
}

// ---- Canvas (Writing) ----

export interface DocumentRow extends BaseModel {
  userId: string;
  title: string;
  content: string;         // TEXT column
  format: keyof typeof DocumentFormat;
  wordCount: number;
  readingTimeMinutes: number;
  isPublished: boolean;
  publishedAt: Date | null;
  isDeleted: boolean;
  deletedAt: Date | null;
}

export interface DocumentTagRow {
  documentId: string;
  tag: string;             // compound PK
}

export interface WritingSessionRow extends BaseModel {
  documentId: string;      // FK -> Document.id
  userId: string;
  startedAt: Date;
  endedAt: Date | null;
  wordsWritten: number;
  durationMs: number;
  flowState: 'warming-up' | 'flowing' | 'deep-flow' | 'winding-down' | null;
}

// ---- Wellness (Clinical) ----

export interface PatientRow extends BaseModel {
  userId: string;          // FK -> User.id, unique
  providerId: string | null; // FK -> Provider.id
  dateOfBirth: string;
  medicalRecordNumber: string | null;
}

export interface ProviderRow extends BaseModel {
  userId: string;          // FK -> User.id, unique
  specialty: string;
  licenseNumber: string;
}

export interface BiomarkerRow extends BaseModel {
  patientId: string;       // FK -> Patient.id
  name: string;
  category: keyof typeof BiomarkerCategory;
  value: number;
  unit: string;
  referenceMin: number | null;
  referenceMax: number | null;
  optimalMin: number | null;
  optimalMax: number | null;
  collectedAt: Date;
  notes: string | null;
}

export interface ProtocolRow extends BaseModel {
  patientId: string;
  providerId: string;
  title: string;
  description: string;
  status: keyof typeof ProtocolStatus;
  startDate: string;
  endDate: string | null;
}

export interface InterventionRow {
  id: string;
  protocolId: string;      // FK -> Protocol.id
  name: string;
  description: string;
  dosage: string | null;
  frequency: string | null;
  timing: string | null;
  notes: string | null;
  sortOrder: number;
}

// ---- Sync ----

export interface SyncStateRow {
  userId: string;
  deviceId: string;        // compound PK
  lastSyncedAt: Date;
  vectorClock: Record<string, number>; // JSON column
  pendingChanges: number;
}

export interface DeviceRegistrationRow extends BaseModel {
  userId: string;
  platform: keyof typeof DevicePlatform;
  deviceName: string;
  pushToken: string | null;
  lastSeenAt: Date;
  syncEnabled: boolean;
}

export interface SyncEnvelopeRow {
  id: string;
  userId: string;
  deviceId: string;
  action: keyof typeof SyncAction;
  entityType: string;
  entityId: string;
  payload: unknown;        // JSON column
  vectorClock: Record<string, number>;
  timestamp: Date;
  processedAt: Date | null;
}

// ---------------------------------------------------------------------------
// Prisma Schema Generator (template)
// ---------------------------------------------------------------------------

/**
 * Returns a Prisma schema string that can be written to schema.prisma.
 * This is a generator helper, not meant to be used at runtime.
 */
export function generatePrismaSchema(): string {
  return `
// Auto-generated from Resonance schema.ts — do not edit manually.
// Run the schema generator to update.

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id            String    @id @default(uuid())
  email         String    @unique
  passwordHash  String
  displayName   String
  avatarUrl     String?
  isActive      Boolean   @default(true)
  lastLoginAt   DateTime?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  preferences   UserPreferences?
  profile       Profile?
  statuses      IntentionalStatus[]
  phaseConfigs  DailyPhaseConfig[]
  flowSnapshots DailyFlowSnapshot[]
  domains       Domain[]
  tasks         Task[]
  energyLogs    EnergyLog[]
  contacts      Contact[]
  conversationParticipants ConversationParticipant[]
  sentMessages  Message[]     @relation("SentMessages")
  documents     Document[]
  sessions      WritingSession[]
  patient       Patient?
  provider      Provider?
  devices       DeviceRegistration[]
  syncStates    SyncState[]
  syncEnvelopes SyncEnvelope[]
  refreshTokens RefreshToken[]

  @@map("users")
}

model UserPreferences {
  id                   String  @id @default(uuid())
  userId               String  @unique
  theme                String  @default("light")
  notificationsEnabled Boolean @default(true)
  quietHoursStart      String?
  quietHoursEnd        String?
  defaultEnergyLevel   String  @default("moderate")
  syncEnabled          Boolean @default(true)
  reducedMotion        Boolean @default(false)
  fontSize             String  @default("medium")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("user_preferences")
}

model RefreshToken {
  id        String    @id @default(uuid())
  userId    String
  tokenHash String
  expiresAt DateTime
  revokedAt DateTime?
  createdAt DateTime  @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@map("refresh_tokens")
}

model Profile {
  id        String   @id @default(uuid())
  userId    String   @unique
  bio       String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("profiles")
}

model IntentionalStatus {
  id        String    @id @default(uuid())
  userId    String
  type      String
  message   String?
  emoji     String?
  expiresAt DateTime?
  createdAt DateTime  @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, createdAt(sort: Desc)])
  @@map("intentional_statuses")
}

model DailyPhaseConfig {
  id                   String  @id @default(uuid())
  userId               String
  phase                String
  startTime            String
  endTime              String
  label                String?
  energyLevel          String
  notificationsAllowed Boolean @default(true)
  sortOrder            Int     @default(0)

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([userId, phase])
  @@map("daily_phase_configs")
}

model DailyFlowSnapshot {
  id                  String   @id @default(uuid())
  userId              String
  date                String
  spaciousnessPercent Int
  scheduledMinutes    Int
  freeMinutes         Int
  completedTasks      Int
  totalTasks          Int
  createdAt           DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([userId, date])
  @@map("daily_flow_snapshots")
}

model Domain {
  id         String   @id @default(uuid())
  userId     String
  name       String
  color      String   @default("#5BA37B")
  icon       String?
  sortOrder  Int      @default(0)
  isArchived Boolean  @default(false)
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt

  user  User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  tasks Task[]

  @@map("domains")
}

model Task {
  id               String    @id @default(uuid())
  userId           String
  title            String
  description      String?
  status           String    @default("open")
  priority         String    @default("normal")
  domainId         String?
  energyRequired   String    @default("moderate")
  estimatedMinutes Int?
  actualMinutes    Int?
  scheduledDate    String?
  scheduledPhase   String?
  completedAt      DateTime?
  archivedAt       DateTime?
  createdAt        DateTime  @default(now())
  updatedAt        DateTime  @updatedAt

  user     User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  domain   Domain?   @relation(fields: [domainId], references: [id])
  subtasks Subtask[]
  tags     TaskTag[]

  @@index([userId, status])
  @@index([userId, scheduledDate])
  @@map("tasks")
}

model Subtask {
  id        String  @id @default(uuid())
  taskId    String
  title     String
  completed Boolean @default(false)
  sortOrder Int     @default(0)

  task Task @relation(fields: [taskId], references: [id], onDelete: Cascade)

  @@map("subtasks")
}

model TaskTag {
  taskId String
  tag    String

  task Task @relation(fields: [taskId], references: [id], onDelete: Cascade)

  @@id([taskId, tag])
  @@map("task_tags")
}

model EnergyLog {
  id       String   @id @default(uuid())
  userId   String
  level    String
  loggedAt DateTime @default(now())
  note     String?

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, loggedAt(sort: Desc)])
  @@map("energy_logs")
}

model Contact {
  id              String    @id @default(uuid())
  userId          String
  displayName     String
  email           String?
  phone           String?
  avatarUrl       String?
  lastContactedAt DateTime?
  isFavorite      Boolean   @default(false)
  notes           String?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("contacts")
}

model Conversation {
  id            String    @id @default(uuid())
  lastMessageAt DateTime?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  participants ConversationParticipant[]
  messages     Message[]
  videoCalls   VideoCall[]

  @@map("conversations")
}

model ConversationParticipant {
  conversationId String
  userId         String
  unreadCount    Int       @default(0)
  mutedUntil     DateTime?
  joinedAt       DateTime  @default(now())

  conversation Conversation @relation(fields: [conversationId], references: [id], onDelete: Cascade)
  user         User         @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@id([conversationId, userId])
  @@map("conversation_participants")
}

model Message {
  id             String    @id @default(uuid())
  conversationId String
  senderId       String
  type           String    @default("text")
  content        String
  readAt         DateTime?
  createdAt      DateTime  @default(now())
  updatedAt      DateTime  @updatedAt

  conversation Conversation     @relation(fields: [conversationId], references: [id], onDelete: Cascade)
  sender       User             @relation("SentMessages", fields: [senderId], references: [id])
  metadata     MessageMetadata?
  voiceMessage VoiceMessage?

  @@index([conversationId, createdAt(sort: Desc)])
  @@map("messages")
}

model MessageMetadata {
  messageId       String @id
  voiceDurationMs Int?
  voiceTranscript String?
  imageWidth      Int?
  imageHeight     Int?
  fileName        String?
  fileSize        Int?
  mimeType        String?

  message Message @relation(fields: [messageId], references: [id], onDelete: Cascade)

  @@map("message_metadata")
}

model VoiceMessage {
  id         String   @id @default(uuid())
  messageId  String   @unique
  audioUrl   String
  durationMs Int
  waveform   Json
  transcript String?
  createdAt  DateTime @default(now())

  message Message @relation(fields: [messageId], references: [id], onDelete: Cascade)

  @@map("voice_messages")
}

model VideoCall {
  id             String    @id @default(uuid())
  conversationId String
  initiatorId    String
  status         String    @default("ringing")
  startedAt      DateTime?
  endedAt        DateTime?
  durationMs     Int?
  createdAt      DateTime  @default(now())
  updatedAt      DateTime  @updatedAt

  conversation Conversation @relation(fields: [conversationId], references: [id])

  @@map("video_calls")
}

model Document {
  id                 String    @id @default(uuid())
  userId             String
  title              String
  content            String
  format             String    @default("prose")
  wordCount          Int       @default(0)
  readingTimeMinutes Int       @default(0)
  isPublished        Boolean   @default(false)
  publishedAt        DateTime?
  isDeleted          Boolean   @default(false)
  deletedAt          DateTime?
  createdAt          DateTime  @default(now())
  updatedAt          DateTime  @updatedAt

  user     User             @relation(fields: [userId], references: [id], onDelete: Cascade)
  tags     DocumentTag[]
  sessions WritingSession[]

  @@index([userId, isDeleted])
  @@map("documents")
}

model DocumentTag {
  documentId String
  tag        String

  document Document @relation(fields: [documentId], references: [id], onDelete: Cascade)

  @@id([documentId, tag])
  @@map("document_tags")
}

model WritingSession {
  id           String    @id @default(uuid())
  documentId   String
  userId       String
  startedAt    DateTime  @default(now())
  endedAt      DateTime?
  wordsWritten Int       @default(0)
  durationMs   Int       @default(0)
  flowState    String?
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt

  document Document @relation(fields: [documentId], references: [id], onDelete: Cascade)
  user     User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("writing_sessions")
}

model Patient {
  id                  String   @id @default(uuid())
  userId              String   @unique
  providerId          String?
  dateOfBirth         String
  medicalRecordNumber String?
  createdAt           DateTime @default(now())
  updatedAt           DateTime @updatedAt

  user       User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  biomarkers Biomarker[]
  protocols  Protocol[]

  @@map("patients")
}

model Provider {
  id            String   @id @default(uuid())
  userId        String   @unique
  specialty     String
  licenseNumber String
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  user      User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  protocols Protocol[]

  @@map("providers")
}

model Biomarker {
  id           String   @id @default(uuid())
  patientId    String
  name         String
  category     String
  value        Float
  unit         String
  referenceMin Float?
  referenceMax Float?
  optimalMin   Float?
  optimalMax   Float?
  collectedAt  DateTime
  notes        String?
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  patient Patient @relation(fields: [patientId], references: [id], onDelete: Cascade)

  @@index([patientId, collectedAt(sort: Desc)])
  @@map("biomarkers")
}

model Protocol {
  id          String    @id @default(uuid())
  patientId   String
  providerId  String
  title       String
  description String
  status      String    @default("draft")
  startDate   String
  endDate     String?
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  patient       Patient        @relation(fields: [patientId], references: [id], onDelete: Cascade)
  provider      Provider       @relation(fields: [providerId], references: [id])
  interventions Intervention[]

  @@map("protocols")
}

model Intervention {
  id          String  @id @default(uuid())
  protocolId  String
  name        String
  description String
  dosage      String?
  frequency   String?
  timing      String?
  notes       String?
  sortOrder   Int     @default(0)

  protocol Protocol @relation(fields: [protocolId], references: [id], onDelete: Cascade)

  @@map("interventions")
}

model SyncState {
  userId         String
  deviceId       String
  lastSyncedAt   DateTime
  vectorClock    Json
  pendingChanges Int @default(0)

  @@id([userId, deviceId])
  @@map("sync_states")
}

model DeviceRegistration {
  id           String   @id @default(uuid())
  userId       String
  platform     String
  deviceName   String
  pushToken    String?
  lastSeenAt   DateTime @default(now())
  syncEnabled  Boolean  @default(true)
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  @@index([userId])
  @@map("device_registrations")
}

model SyncEnvelope {
  id          String    @id @default(uuid())
  userId      String
  deviceId    String
  action      String
  entityType  String
  entityId    String
  payload     Json
  vectorClock Json
  timestamp   DateTime
  processedAt DateTime?

  @@index([userId, timestamp(sort: Desc)])
  @@index([entityType, entityId])
  @@map("sync_envelopes")
}
`.trim();
}
