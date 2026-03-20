/**
 * Resonance UX Cross-Device Sync Service
 *
 * Provides:
 * - Conflict resolution using vector clocks (last-write-wins with causality tracking)
 * - Real-time push via WebSocket relay
 * - Offline queue with eventual consistency
 * - Device registration / deregistration
 * - Selective sync (per-feature opt-in)
 */

import { v4 as uuid } from 'uuid';
import type {
  SyncEnvelope,
  SyncBatch,
  SyncConflict,
  SyncState,
  DeviceRegistration,
  DevicePlatform,
} from '../../../shared/types';

// ---------------------------------------------------------------------------
// Vector Clock Utilities
// ---------------------------------------------------------------------------

export type VectorClock = Record<string, number>;

/** Increment the clock for a specific device */
export function tickClock(clock: VectorClock, deviceId: string): VectorClock {
  return { ...clock, [deviceId]: (clock[deviceId] || 0) + 1 };
}

/** Merge two clocks, taking the max of each entry */
export function mergeClock(a: VectorClock, b: VectorClock): VectorClock {
  const merged: VectorClock = { ...a };
  for (const [key, val] of Object.entries(b)) {
    merged[key] = Math.max(merged[key] || 0, val);
  }
  return merged;
}

/**
 * Compare two vector clocks.
 * Returns:
 *   -1  if a < b  (a happened before b)
 *    0  if a || b  (concurrent / incomparable)
 *    1  if a > b  (a happened after b)
 */
export function compareClock(a: VectorClock, b: VectorClock): -1 | 0 | 1 {
  const allKeys = new Set([...Object.keys(a), ...Object.keys(b)]);
  let aGreater = false;
  let bGreater = false;

  for (const key of allKeys) {
    const va = a[key] || 0;
    const vb = b[key] || 0;
    if (va > vb) aGreater = true;
    if (vb > va) bGreater = true;
  }

  if (aGreater && !bGreater) return 1;
  if (bGreater && !aGreater) return -1;
  return 0; // concurrent
}

/** Check if clock a dominates (happened-after) clock b */
export function dominates(a: VectorClock, b: VectorClock): boolean {
  return compareClock(a, b) === 1;
}

// ---------------------------------------------------------------------------
// In-memory stores (replace with DB in production)
// ---------------------------------------------------------------------------

interface StoredEnvelope extends SyncEnvelope {
  processedAt: string | null;
}

const envelopeStore: Map<string, StoredEnvelope[]> = new Map(); // userId -> envelopes
const deviceStore: Map<string, DeviceRegistration[]> = new Map(); // userId -> devices
const syncStates: Map<string, SyncState> = new Map(); // `${userId}:${deviceId}` -> state
const offlineQueues: Map<string, SyncEnvelope[]> = new Map(); // deviceId -> queued changes
const featureOptIn: Map<string, Set<string>> = new Map(); // deviceId -> set of entity types

// ---------------------------------------------------------------------------
// Sync Service
// ---------------------------------------------------------------------------

export class SyncService {
  // ---- Push (client -> server) ----

  processPush(
    userId: string,
    deviceId: string,
    changes: unknown[],
  ): { accepted: number; conflicts: SyncConflict[]; checkpoint: string } {
    const envelopes = (changes as SyncEnvelope[]).map((c) => ({
      ...c,
      id: c.id || uuid(),
      userId,
      deviceId,
      timestamp: c.timestamp || new Date().toISOString(),
    }));

    const userEnvelopes = envelopeStore.get(userId) || [];
    const conflicts: SyncConflict[] = [];
    let accepted = 0;

    for (const envelope of envelopes) {
      // Check for conflicts on the same entity
      const existing = userEnvelopes.find(
        (e) =>
          e.entityType === envelope.entityType &&
          e.entityId === envelope.entityId &&
          e.deviceId !== deviceId &&
          !e.processedAt,
      );

      if (existing) {
        const cmp = compareClock(envelope.vectorClock, existing.vectorClock);

        if (cmp === 0) {
          // Concurrent: resolve with last-write-wins (timestamp tiebreaker)
          const resolution = this.resolveConflict(envelope, existing);
          conflicts.push(resolution);

          if (resolution.resolution === 'local') {
            // Incoming envelope wins
            const idx = userEnvelopes.indexOf(existing);
            if (idx !== -1) userEnvelopes[idx] = { ...existing, processedAt: new Date().toISOString() };
            userEnvelopes.push({ ...envelope, processedAt: null });
            accepted++;
          } else if (resolution.resolution === 'merged') {
            // Apply merged payload
            const merged: StoredEnvelope = {
              ...envelope,
              payload: resolution.mergedPayload,
              vectorClock: mergeClock(envelope.vectorClock, existing.vectorClock),
              processedAt: null,
            };
            const idx = userEnvelopes.indexOf(existing);
            if (idx !== -1) userEnvelopes[idx] = { ...existing, processedAt: new Date().toISOString() };
            userEnvelopes.push(merged);
            accepted++;
          }
          // 'remote' means existing wins, skip incoming
        } else if (cmp === 1) {
          // Incoming dominates
          const idx = userEnvelopes.indexOf(existing);
          if (idx !== -1) userEnvelopes[idx] = { ...existing, processedAt: new Date().toISOString() };
          userEnvelopes.push({ ...envelope, processedAt: null });
          accepted++;
        }
        // cmp === -1 means existing dominates, skip
      } else {
        // No conflict
        userEnvelopes.push({ ...envelope, processedAt: null });
        accepted++;
      }
    }

    envelopeStore.set(userId, userEnvelopes);

    // Update sync state
    const stateKey = `${userId}:${deviceId}`;
    const currentState = syncStates.get(stateKey) || {
      deviceId,
      lastSyncedAt: new Date().toISOString(),
      vectorClock: {},
      pendingChanges: 0,
    };

    let updatedClock = { ...currentState.vectorClock };
    for (const e of envelopes) {
      updatedClock = mergeClock(updatedClock, e.vectorClock);
    }

    syncStates.set(stateKey, {
      ...currentState,
      lastSyncedAt: new Date().toISOString(),
      vectorClock: updatedClock,
      pendingChanges: 0,
    });

    const checkpoint = new Date().toISOString();
    return { accepted, conflicts, checkpoint };
  }

  // ---- Pull (server -> client) ----

  processPull(
    userId: string,
    deviceId: string,
    since?: string,
    entityTypes?: string[],
    limit?: number,
  ): SyncBatch {
    const userEnvelopes = envelopeStore.get(userId) || [];
    const effectiveLimit = Math.min(limit || 100, 500);

    // Filter out the device's own changes (it already has them)
    let filtered = userEnvelopes.filter(
      (e) => e.deviceId !== deviceId && !e.processedAt,
    );

    // Filter by timestamp
    if (since) {
      const sinceTime = new Date(since).getTime();
      filtered = filtered.filter((e) => new Date(e.timestamp).getTime() > sinceTime);
    }

    // Filter by entity types (selective sync)
    if (entityTypes && entityTypes.length > 0) {
      const typeSet = new Set(entityTypes);
      filtered = filtered.filter((e) => typeSet.has(e.entityType));
    }

    // Also check device feature opt-in
    const deviceOptIn = featureOptIn.get(deviceId);
    if (deviceOptIn && deviceOptIn.size > 0) {
      filtered = filtered.filter((e) => deviceOptIn.has(e.entityType));
    }

    // Sort by timestamp ascending
    filtered.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());

    const hasMore = filtered.length > effectiveLimit;
    const batch = filtered.slice(0, effectiveLimit);

    // Update sync state
    if (batch.length > 0) {
      const stateKey = `${userId}:${deviceId}`;
      const currentState = syncStates.get(stateKey) || {
        deviceId,
        lastSyncedAt: new Date().toISOString(),
        vectorClock: {},
        pendingChanges: 0,
      };

      let updatedClock = { ...currentState.vectorClock };
      for (const e of batch) {
        updatedClock = mergeClock(updatedClock, e.vectorClock);
      }

      syncStates.set(stateKey, {
        ...currentState,
        lastSyncedAt: new Date().toISOString(),
        vectorClock: updatedClock,
        pendingChanges: hasMore ? filtered.length - effectiveLimit : 0,
      });
    }

    const checkpoint = batch.length > 0
      ? batch[batch.length - 1].timestamp
      : since || new Date().toISOString();

    return {
      envelopes: batch,
      checkpoint,
      hasMore,
    };
  }

  // ---- Conflict Resolution ----

  private resolveConflict(incoming: SyncEnvelope, existing: StoredEnvelope): SyncConflict {
    const incomingTime = new Date(incoming.timestamp).getTime();
    const existingTime = new Date(existing.timestamp).getTime();

    // Attempt structural merge for update actions with object payloads
    if (
      incoming.action === 'update' &&
      existing.action === 'update' &&
      typeof incoming.payload === 'object' &&
      incoming.payload !== null &&
      typeof existing.payload === 'object' &&
      existing.payload !== null
    ) {
      const incomingFields = Object.keys(incoming.payload as Record<string, unknown>);
      const existingFields = Object.keys(existing.payload as Record<string, unknown>);
      const overlap = incomingFields.filter((f) => existingFields.includes(f));

      // If updates touch different fields, merge them
      if (overlap.length === 0) {
        return {
          entityType: incoming.entityType,
          entityId: incoming.entityId,
          localVersion: incoming,
          remoteVersion: existing,
          resolution: 'merged',
          mergedPayload: {
            ...(existing.payload as Record<string, unknown>),
            ...(incoming.payload as Record<string, unknown>),
          },
        };
      }
    }

    // Last-write-wins by timestamp
    const resolution = incomingTime >= existingTime ? 'local' : 'remote';

    return {
      entityType: incoming.entityType,
      entityId: incoming.entityId,
      localVersion: incoming,
      remoteVersion: existing,
      resolution,
    };
  }

  // ---- Offline Queue ----

  enqueueOffline(deviceId: string, envelope: SyncEnvelope): void {
    const queue = offlineQueues.get(deviceId) || [];
    queue.push(envelope);
    offlineQueues.set(deviceId, queue);
  }

  drainOfflineQueue(userId: string, deviceId: string): ReturnType<SyncService['processPush']> | null {
    const queue = offlineQueues.get(deviceId);
    if (!queue || queue.length === 0) return null;

    offlineQueues.delete(deviceId);
    return this.processPush(userId, deviceId, queue);
  }

  getOfflineQueueSize(deviceId: string): number {
    return offlineQueues.get(deviceId)?.length ?? 0;
  }

  // ---- Selective Sync ----

  setFeatureOptIn(deviceId: string, entityTypes: string[]): void {
    featureOptIn.set(deviceId, new Set(entityTypes));
  }

  getFeatureOptIn(deviceId: string): string[] {
    const set = featureOptIn.get(deviceId);
    return set ? Array.from(set) : [];
  }

  // ---- Device Management ----

  registerDevice(
    userId: string,
    info: { platform: string; deviceName: string; pushToken: string | null },
  ): DeviceRegistration {
    const devices = deviceStore.get(userId) || [];

    const device: DeviceRegistration = {
      id: uuid(),
      userId,
      platform: info.platform as DevicePlatform,
      deviceName: info.deviceName,
      pushToken: info.pushToken ?? undefined,
      lastSeenAt: new Date().toISOString(),
      syncEnabled: true,
      registeredAt: new Date().toISOString(),
    };

    devices.push(device);
    deviceStore.set(userId, devices);

    // Initialize sync state
    const stateKey = `${userId}:${device.id}`;
    syncStates.set(stateKey, {
      deviceId: device.id,
      lastSyncedAt: new Date().toISOString(),
      vectorClock: {},
      pendingChanges: 0,
    });

    return device;
  }

  deregisterDevice(userId: string, deviceId: string): boolean {
    const devices = deviceStore.get(userId) || [];
    const idx = devices.findIndex((d) => d.id === deviceId);
    if (idx === -1) return false;

    devices.splice(idx, 1);
    deviceStore.set(userId, devices);

    // Clean up state
    syncStates.delete(`${userId}:${deviceId}`);
    offlineQueues.delete(deviceId);
    featureOptIn.delete(deviceId);

    return true;
  }

  getDevices(userId: string): DeviceRegistration[] {
    return deviceStore.get(userId) || [];
  }

  updateDeviceLastSeen(userId: string, deviceId: string): void {
    const devices = deviceStore.get(userId) || [];
    const device = devices.find((d) => d.id === deviceId);
    if (device) {
      device.lastSeenAt = new Date().toISOString();
    }
  }

  // ---- State ----

  getState(userId: string, deviceId: string): SyncState {
    const key = `${userId}:${deviceId}`;
    return (
      syncStates.get(key) || {
        deviceId,
        lastSyncedAt: new Date().toISOString(),
        vectorClock: {},
        pendingChanges: 0,
      }
    );
  }

  // ---- Cleanup ----

  /**
   * Prune processed envelopes older than the given age (ms).
   * Call periodically to prevent unbounded memory growth.
   */
  pruneEnvelopes(maxAgeMs: number = 7 * 24 * 60 * 60 * 1000): number {
    let pruned = 0;
    const cutoff = Date.now() - maxAgeMs;

    for (const [userId, envelopes] of envelopeStore) {
      const before = envelopes.length;
      const filtered = envelopes.filter((e) => {
        if (e.processedAt && new Date(e.processedAt).getTime() < cutoff) return false;
        if (new Date(e.timestamp).getTime() < cutoff) return false;
        return true;
      });
      envelopeStore.set(userId, filtered);
      pruned += before - filtered.length;
    }

    return pruned;
  }
}
