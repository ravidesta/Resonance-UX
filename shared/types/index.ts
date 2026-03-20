/**
 * Resonance UX Shared Types
 *
 * Canonical TypeScript interfaces used by all platforms (web, backend, mobile).
 * Every API contract, WebSocket message, and database model reference these types.
 */

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

export enum ThemeMode {
  Light = 'light',
  DeepRest = 'deep-rest',
  System = 'system',
}

export enum FlowPhase {
  Dawn = 'dawn',
  MorningFocus = 'morning-focus',
  Midday = 'midday',
  Afternoon = 'afternoon',
  Evening = 'evening',
  DeepRest = 'deep-rest',
}

export enum EnergyLevel {
  Peak = 'peak',
  High = 'high',
  Moderate = 'moderate',
  Low = 'low',
  Rest = 'rest',
}

export enum TaskStatus {
  Open = 'open',
  InProgress = 'in-progress',
  Completed = 'completed',
  Deferred = 'deferred',
  Archived = 'archived',
}

export enum TaskPriority {
  Urgent = 'urgent',
  High = 'high',
  Normal = 'normal',
  Low = 'low',
  Someday = 'someday',
}

export enum IntentionalStatusType {
  Available = 'available',
  Focused = 'focused',
  Creating = 'creating',
  Resting = 'resting',
  Away = 'away',
  DoNotDisturb = 'do-not-disturb',
}

export enum MessageType {
  Text = 'text',
  Voice = 'voice',
  Image = 'image',
  Document = 'document',
  System = 'system',
}

export enum CallStatus {
  Ringing = 'ringing',
  Active = 'active',
  Ended = 'ended',
  Missed = 'missed',
  Declined = 'declined',
}

export enum DocumentFormat {
  Prose = 'prose',
  Markdown = 'markdown',
  RichText = 'rich-text',
  PlainText = 'plain-text',
}

export enum BiomarkerCategory {
  Cardiovascular = 'cardiovascular',
  Metabolic = 'metabolic',
  Hormonal = 'hormonal',
  Inflammatory = 'inflammatory',
  Neurological = 'neurological',
  Nutritional = 'nutritional',
}

export enum ProtocolStatus {
  Active = 'active',
  Paused = 'paused',
  Completed = 'completed',
  Draft = 'draft',
}

export enum SyncAction {
  Create = 'create',
  Update = 'update',
  Delete = 'delete',
  Merge = 'merge',
}

export enum NotificationUrgency {
  Critical = 'critical',
  High = 'high',
  Normal = 'normal',
  Low = 'low',
  Silent = 'silent',
}

export enum DevicePlatform {
  Web = 'web',
  iOS = 'ios',
  Android = 'android',
  macOS = 'macos',
  Windows = 'windows',
  Linux = 'linux',
  WatchOS = 'watchos',
  tvOS = 'tvos',
}

// ---------------------------------------------------------------------------
// User & Auth
// ---------------------------------------------------------------------------

export interface User {
  id: string;
  email: string;
  displayName: string;
  avatarUrl?: string;
  createdAt: string;
  updatedAt: string;
  preferences: UserPreferences;
}

export interface UserPreferences {
  theme: ThemeMode;
  notificationsEnabled: boolean;
  quietHoursStart?: string; // HH:mm
  quietHoursEnd?: string;
  defaultEnergyLevel: EnergyLevel;
  syncEnabled: boolean;
  reducedMotion: boolean;
  fontSize: 'small' | 'medium' | 'large';
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
}

export interface AuthLoginRequest {
  email: string;
  password: string;
}

export interface AuthRegisterRequest {
  email: string;
  password: string;
  displayName: string;
}

export interface AuthRefreshRequest {
  refreshToken: string;
}

export interface AuthResponse {
  user: User;
  tokens: AuthTokens;
}

// ---------------------------------------------------------------------------
// Profile & Intentional Status
// ---------------------------------------------------------------------------

export interface Profile {
  id: string;
  userId: string;
  bio?: string;
  currentStatus: IntentionalStatus;
  domains: Domain[];
  dailyPhases: DailyPhaseConfig[];
}

export interface IntentionalStatus {
  type: IntentionalStatusType;
  message?: string;
  emoji?: string;
  expiresAt?: string;
  updatedAt: string;
}

// ---------------------------------------------------------------------------
// Flow (Daily Rhythm)
// ---------------------------------------------------------------------------

export interface DailyPhaseConfig {
  phase: FlowPhase;
  startTime: string; // HH:mm
  endTime: string;
  label?: string;
  energyLevel: EnergyLevel;
  notificationsAllowed: boolean;
}

export interface DailyFlowState {
  date: string; // YYYY-MM-DD
  currentPhase: FlowPhase;
  currentEnergy: EnergyLevel;
  spaciousness: number; // 0-100 percentage of unscheduled time
  tasks: TaskSummary[];
  completedCount: number;
  totalCount: number;
}

export interface TaskSummary {
  id: string;
  title: string;
  status: TaskStatus;
  priority: TaskPriority;
  domain?: string;
  estimatedMinutes?: number;
}

// ---------------------------------------------------------------------------
// Focus (Tasks & Productivity)
// ---------------------------------------------------------------------------

export interface Domain {
  id: string;
  userId: string;
  name: string;
  color: string;
  icon?: string;
  sortOrder: number;
}

export interface Task {
  id: string;
  userId: string;
  title: string;
  description?: string;
  status: TaskStatus;
  priority: TaskPriority;
  domainId?: string;
  domain?: Domain;
  energyRequired: EnergyLevel;
  estimatedMinutes?: number;
  actualMinutes?: number;
  scheduledDate?: string;
  scheduledPhase?: FlowPhase;
  completedAt?: string;
  tags: string[];
  subtasks: Subtask[];
  createdAt: string;
  updatedAt: string;
}

export interface Subtask {
  id: string;
  title: string;
  completed: boolean;
  sortOrder: number;
}

export interface TaskCreateRequest {
  title: string;
  description?: string;
  priority?: TaskPriority;
  domainId?: string;
  energyRequired?: EnergyLevel;
  estimatedMinutes?: number;
  scheduledDate?: string;
  scheduledPhase?: FlowPhase;
  tags?: string[];
}

export interface TaskUpdateRequest {
  title?: string;
  description?: string;
  status?: TaskStatus;
  priority?: TaskPriority;
  domainId?: string;
  energyRequired?: EnergyLevel;
  estimatedMinutes?: number;
  scheduledDate?: string;
  scheduledPhase?: FlowPhase;
  tags?: string[];
}

export interface TaskListQuery {
  status?: TaskStatus[];
  priority?: TaskPriority[];
  domainId?: string;
  energyRequired?: EnergyLevel[];
  scheduledDate?: string;
  phase?: FlowPhase;
  search?: string;
  page?: number;
  limit?: number;
  sortBy?: 'priority' | 'created' | 'scheduled' | 'energy';
  sortOrder?: 'asc' | 'desc';
}

// ---------------------------------------------------------------------------
// Letters (Communication)
// ---------------------------------------------------------------------------

export interface Contact {
  id: string;
  userId: string;
  displayName: string;
  email?: string;
  phone?: string;
  avatarUrl?: string;
  lastContactedAt?: string;
  isFavorite: boolean;
  notes?: string;
}

export interface Conversation {
  id: string;
  participants: Contact[];
  lastMessage?: Message;
  unreadCount: number;
  updatedAt: string;
}

export interface Message {
  id: string;
  conversationId: string;
  senderId: string;
  type: MessageType;
  content: string;
  metadata?: MessageMetadata;
  readAt?: string;
  createdAt: string;
}

export interface MessageMetadata {
  voiceDurationMs?: number;
  voiceTranscript?: string;
  imageWidth?: number;
  imageHeight?: number;
  fileName?: string;
  fileSize?: number;
  mimeType?: string;
}

export interface MessageSendRequest {
  conversationId: string;
  type: MessageType;
  content: string;
  metadata?: MessageMetadata;
}

export interface VoiceMessage {
  id: string;
  messageId: string;
  audioUrl: string;
  durationMs: number;
  waveform: number[]; // normalized 0-1 amplitude samples
  transcript?: string;
  createdAt: string;
}

export interface VideoCall {
  id: string;
  conversationId: string;
  initiatorId: string;
  status: CallStatus;
  startedAt?: string;
  endedAt?: string;
  durationMs?: number;
}

// ---------------------------------------------------------------------------
// Canvas (Writing & Documents)
// ---------------------------------------------------------------------------

export interface Document {
  id: string;
  userId: string;
  title: string;
  content: string;
  format: DocumentFormat;
  wordCount: number;
  readingTimeMinutes: number;
  tags: string[];
  isPublished: boolean;
  publishedAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface DocumentCreateRequest {
  title: string;
  content?: string;
  format?: DocumentFormat;
  tags?: string[];
}

export interface DocumentUpdateRequest {
  title?: string;
  content?: string;
  format?: DocumentFormat;
  tags?: string[];
  isPublished?: boolean;
}

export interface WritingSession {
  id: string;
  documentId: string;
  userId: string;
  startedAt: string;
  endedAt?: string;
  wordsWritten: number;
  durationMs: number;
  flowState?: 'warming-up' | 'flowing' | 'deep-flow' | 'winding-down';
}

export interface LuminizeRequest {
  text: string;
  style: 'refine' | 'simplify' | 'expand' | 'empathize' | 'formalize';
  preserveVoice: boolean;
  context?: string;
}

export interface LuminizeResponse {
  original: string;
  refined: string;
  changes: LuminizeChange[];
  confidence: number;
}

export interface LuminizeChange {
  type: 'word' | 'phrase' | 'sentence' | 'structure';
  original: string;
  replacement: string;
  reason: string;
}

// ---------------------------------------------------------------------------
// Wellness (Clinical / Biomarker)
// ---------------------------------------------------------------------------

export interface Patient {
  id: string;
  userId: string;
  providerId?: string;
  dateOfBirth: string;
  medicalRecordNumber?: string;
  createdAt: string;
}

export interface Provider {
  id: string;
  userId: string;
  specialty: string;
  licenseNumber: string;
  patients: string[]; // patient IDs
}

export interface Biomarker {
  id: string;
  patientId: string;
  name: string;
  category: BiomarkerCategory;
  value: number;
  unit: string;
  referenceMin?: number;
  referenceMax?: number;
  optimalMin?: number;
  optimalMax?: number;
  collectedAt: string;
  notes?: string;
}

export interface Protocol {
  id: string;
  patientId: string;
  providerId: string;
  title: string;
  description: string;
  status: ProtocolStatus;
  interventions: Intervention[];
  startDate: string;
  endDate?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Intervention {
  id: string;
  name: string;
  description: string;
  dosage?: string;
  frequency?: string;
  timing?: string;
  notes?: string;
}

// ---------------------------------------------------------------------------
// Sync Protocol
// ---------------------------------------------------------------------------

export interface SyncState {
  deviceId: string;
  lastSyncedAt: string;
  vectorClock: Record<string, number>;
  pendingChanges: number;
}

export interface DeviceRegistration {
  id: string;
  userId: string;
  platform: DevicePlatform;
  deviceName: string;
  pushToken?: string;
  lastSeenAt: string;
  syncEnabled: boolean;
  registeredAt: string;
}

export interface SyncEnvelope {
  id: string;
  deviceId: string;
  userId: string;
  action: SyncAction;
  entityType: string;
  entityId: string;
  payload: unknown;
  vectorClock: Record<string, number>;
  timestamp: string;
}

export interface SyncBatch {
  envelopes: SyncEnvelope[];
  checkpoint: string;
  hasMore: boolean;
}

export interface SyncPushRequest {
  deviceId: string;
  changes: SyncEnvelope[];
}

export interface SyncPullRequest {
  deviceId: string;
  since: string; // checkpoint or ISO timestamp
  entityTypes?: string[];
  limit?: number;
}

export interface SyncConflict {
  entityType: string;
  entityId: string;
  localVersion: SyncEnvelope;
  remoteVersion: SyncEnvelope;
  resolution: 'local' | 'remote' | 'merged';
  mergedPayload?: unknown;
}

// ---------------------------------------------------------------------------
// WebSocket Messages
// ---------------------------------------------------------------------------

export enum WSMessageType {
  // Connection
  Ping = 'ping',
  Pong = 'pong',
  Authenticate = 'authenticate',
  Authenticated = 'authenticated',
  Error = 'error',

  // Status
  StatusUpdate = 'status-update',
  StatusSubscribe = 'status-subscribe',
  StatusUnsubscribe = 'status-unsubscribe',

  // Messaging
  MessageNew = 'message-new',
  MessageRead = 'message-read',
  TypingStart = 'typing-start',
  TypingStop = 'typing-stop',

  // Sync
  SyncPush = 'sync-push',
  SyncPull = 'sync-pull',
  SyncUpdate = 'sync-update',
  SyncConflict = 'sync-conflict',

  // Notifications
  Notification = 'notification',

  // Calls
  CallIncoming = 'call-incoming',
  CallAccepted = 'call-accepted',
  CallDeclined = 'call-declined',
  CallEnded = 'call-ended',
  CallSignal = 'call-signal',
}

export interface WSMessage {
  type: WSMessageType;
  id: string;
  timestamp: string;
  payload: unknown;
}

export interface WSAuthMessage extends WSMessage {
  type: WSMessageType.Authenticate;
  payload: { token: string; deviceId: string };
}

export interface WSStatusUpdateMessage extends WSMessage {
  type: WSMessageType.StatusUpdate;
  payload: { userId: string; status: IntentionalStatus };
}

export interface WSNewMessageMessage extends WSMessage {
  type: WSMessageType.MessageNew;
  payload: { message: Message };
}

export interface WSNotificationMessage extends WSMessage {
  type: WSMessageType.Notification;
  payload: {
    title: string;
    body: string;
    urgency: NotificationUrgency;
    data?: Record<string, string>;
  };
}

// ---------------------------------------------------------------------------
// API Response Wrappers
// ---------------------------------------------------------------------------

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  meta?: ApiMeta;
}

export interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, string[]>;
  };
}

export interface ApiMeta {
  page?: number;
  limit?: number;
  total?: number;
  hasMore?: boolean;
}

export interface PaginatedResponse<T> {
  success: true;
  data: T[];
  meta: Required<ApiMeta>;
}
