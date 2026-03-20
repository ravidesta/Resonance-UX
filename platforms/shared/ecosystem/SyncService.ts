/**
 * Luminous Cosmic Architecture™ — Cross-Device Sync Service
 * Offline-first sync with conflict resolution across all platforms
 */

export interface SyncableEntity {
  id: string;
  entityType: SyncEntityType;
  lastModified: number; // Unix timestamp
  version: number;
  deviceId: string;
  data: unknown;
}

export type SyncEntityType =
  | "user_profile"
  | "birth_chart"
  | "journal_entry"
  | "meditation_session"
  | "reading_progress"
  | "facilitator_conversation"
  | "preferences"
  | "bookmark";

export interface SyncConflict {
  entityId: string;
  entityType: SyncEntityType;
  localVersion: SyncableEntity;
  remoteVersion: SyncableEntity;
  resolution: "local_wins" | "remote_wins" | "merge" | "manual";
}

export interface SyncStatus {
  lastSyncTime: number;
  pendingChanges: number;
  conflicts: SyncConflict[];
  isOnline: boolean;
  isSyncing: boolean;
}

// ─── Sync Service ─────────────────────────────────────────────────

export class SyncService {
  private pendingQueue: SyncableEntity[] = [];
  private status: SyncStatus = {
    lastSyncTime: 0,
    pendingChanges: 0,
    conflicts: [],
    isOnline: false,
    isSyncing: false,
  };
  private listeners: Set<(status: SyncStatus) => void> = new Set();
  private deviceId: string;
  private apiBaseUrl: string;
  private authToken: string | null = null;

  constructor(deviceId: string, apiBaseUrl: string) {
    this.deviceId = deviceId;
    this.apiBaseUrl = apiBaseUrl;
  }

  // ─── Authentication ───────────────────────────────────────────

  setAuthToken(token: string): void {
    this.authToken = token;
  }

  // ─── Entity Tracking ──────────────────────────────────────────

  async trackChange(entity: Omit<SyncableEntity, "deviceId" | "lastModified" | "version">): Promise<void> {
    const syncEntity: SyncableEntity = {
      ...entity,
      deviceId: this.deviceId,
      lastModified: Date.now(),
      version: (await this.getLocalVersion(entity.id)) + 1,
    };

    this.pendingQueue.push(syncEntity);
    await this.saveToLocalStore(syncEntity);
    this.updateStatus({ pendingChanges: this.pendingQueue.length });

    if (this.status.isOnline) {
      this.debouncedSync();
    }
  }

  // ─── Sync Operations ──────────────────────────────────────────

  async fullSync(): Promise<SyncStatus> {
    if (this.status.isSyncing || !this.authToken) return this.status;
    this.updateStatus({ isSyncing: true });

    try {
      // 1. Pull remote changes since last sync
      const remoteChanges = await this.fetchRemoteChanges(this.status.lastSyncTime);

      // 2. Apply remote changes locally (with conflict detection)
      for (const remoteEntity of remoteChanges) {
        const localEntity = await this.getLocalEntity(remoteEntity.id);

        if (!localEntity) {
          // New remote entity — save locally
          await this.saveToLocalStore(remoteEntity);
        } else if (remoteEntity.version > localEntity.version) {
          // Remote is newer — check for local pending changes
          const hasPendingLocal = this.pendingQueue.some((e) => e.id === remoteEntity.id);

          if (hasPendingLocal) {
            // Conflict: both local and remote changed
            const conflict = this.resolveConflict(localEntity, remoteEntity);
            if (conflict.resolution === "manual") {
              this.status.conflicts.push(conflict);
            } else {
              await this.applyResolution(conflict);
            }
          } else {
            // No local changes — accept remote
            await this.saveToLocalStore(remoteEntity);
          }
        }
      }

      // 3. Push local pending changes
      const pushResults = await this.pushPendingChanges();

      // 4. Update sync status
      this.updateStatus({
        lastSyncTime: Date.now(),
        pendingChanges: pushResults.remaining,
        isSyncing: false,
      });
    } catch (error) {
      this.updateStatus({ isSyncing: false });
      console.error("[SyncService] Sync failed:", error);
    }

    return this.status;
  }

  // ─── Conflict Resolution ──────────────────────────────────────

  private resolveConflict(local: SyncableEntity, remote: SyncableEntity): SyncConflict {
    const conflict: SyncConflict = {
      entityId: local.id,
      entityType: local.entityType,
      localVersion: local,
      remoteVersion: remote,
      resolution: "manual",
    };

    // Auto-resolve strategies by entity type
    switch (local.entityType) {
      case "journal_entry":
        // Journal entries: newer timestamp wins (user intent is clear)
        conflict.resolution = local.lastModified > remote.lastModified ? "local_wins" : "remote_wins";
        break;

      case "meditation_session":
        // Meditation sessions: merge (combine completion data)
        conflict.resolution = "merge";
        break;

      case "reading_progress":
        // Reading progress: furthest progress wins
        conflict.resolution = this.compareReadingProgress(local, remote) >= 0 ? "local_wins" : "remote_wins";
        break;

      case "preferences":
        // Preferences: most recent wins
        conflict.resolution = local.lastModified > remote.lastModified ? "local_wins" : "remote_wins";
        break;

      case "birth_chart":
        // Birth chart: should rarely conflict; most recent wins
        conflict.resolution = local.lastModified > remote.lastModified ? "local_wins" : "remote_wins";
        break;

      default:
        // Default: require manual resolution
        conflict.resolution = "manual";
    }

    return conflict;
  }

  private compareReadingProgress(local: SyncableEntity, remote: SyncableEntity): number {
    const localData = local.data as { chapterId: number; sectionId: string; scrollPosition: number };
    const remoteData = remote.data as { chapterId: number; sectionId: string; scrollPosition: number };
    if (localData.chapterId !== remoteData.chapterId) {
      return localData.chapterId - remoteData.chapterId;
    }
    return localData.scrollPosition - remoteData.scrollPosition;
  }

  private async applyResolution(conflict: SyncConflict): Promise<void> {
    switch (conflict.resolution) {
      case "local_wins":
        // Keep local, push to remote
        break;
      case "remote_wins":
        await this.saveToLocalStore(conflict.remoteVersion);
        this.pendingQueue = this.pendingQueue.filter((e) => e.id !== conflict.entityId);
        break;
      case "merge":
        const merged = this.mergeEntities(conflict.localVersion, conflict.remoteVersion);
        await this.saveToLocalStore(merged);
        this.pendingQueue = this.pendingQueue.filter((e) => e.id !== conflict.entityId);
        this.pendingQueue.push(merged);
        break;
    }
  }

  private mergeEntities(local: SyncableEntity, remote: SyncableEntity): SyncableEntity {
    return {
      ...local,
      data: { ...(remote.data as object), ...(local.data as object) },
      version: Math.max(local.version, remote.version) + 1,
      lastModified: Date.now(),
    };
  }

  // ─── Network Operations ───────────────────────────────────────

  private async fetchRemoteChanges(since: number): Promise<SyncableEntity[]> {
    const response = await fetch(`${this.apiBaseUrl}/sync/changes?since=${since}&device=${this.deviceId}`, {
      headers: { Authorization: `Bearer ${this.authToken}` },
    });
    if (!response.ok) throw new Error(`Sync fetch failed: ${response.status}`);
    return response.json();
  }

  private async pushPendingChanges(): Promise<{ remaining: number }> {
    if (this.pendingQueue.length === 0) return { remaining: 0 };

    const batch = this.pendingQueue.splice(0, 50); // Process in batches of 50

    const response = await fetch(`${this.apiBaseUrl}/sync/push`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.authToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ entities: batch }),
    });

    if (!response.ok) {
      // Put failed items back in queue
      this.pendingQueue.unshift(...batch);
      throw new Error(`Sync push failed: ${response.status}`);
    }

    return { remaining: this.pendingQueue.length };
  }

  // ─── Local Storage Abstraction ────────────────────────────────

  private async saveToLocalStore(entity: SyncableEntity): Promise<void> {
    // Platform-specific implementation:
    // iOS/macOS: Core Data or UserDefaults
    // Android: Room Database
    // Web: IndexedDB
    // Windows: SQLite or LocalSettings
    const key = `sync_${entity.entityType}_${entity.id}`;
    if (typeof localStorage !== "undefined") {
      localStorage.setItem(key, JSON.stringify(entity));
    }
  }

  private async getLocalEntity(id: string): Promise<SyncableEntity | null> {
    // Scan local store for entity by ID
    for (const type of ["user_profile", "birth_chart", "journal_entry", "meditation_session", "reading_progress", "facilitator_conversation", "preferences", "bookmark"]) {
      const key = `sync_${type}_${id}`;
      if (typeof localStorage !== "undefined") {
        const data = localStorage.getItem(key);
        if (data) return JSON.parse(data);
      }
    }
    return null;
  }

  private async getLocalVersion(id: string): Promise<number> {
    const entity = await this.getLocalEntity(id);
    return entity?.version ?? 0;
  }

  // ─── Status & Listeners ───────────────────────────────────────

  private updateStatus(partial: Partial<SyncStatus>): void {
    this.status = { ...this.status, ...partial };
    this.listeners.forEach((listener) => listener(this.status));
  }

  onStatusChange(listener: (status: SyncStatus) => void): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  getStatus(): SyncStatus {
    return { ...this.status };
  }

  setOnline(online: boolean): void {
    this.updateStatus({ isOnline: online });
    if (online && this.pendingQueue.length > 0) {
      this.fullSync();
    }
  }

  // ─── Utilities ────────────────────────────────────────────────

  private syncTimer: ReturnType<typeof setTimeout> | null = null;

  private debouncedSync(): void {
    if (this.syncTimer) clearTimeout(this.syncTimer);
    this.syncTimer = setTimeout(() => this.fullSync(), 3000);
  }
}
