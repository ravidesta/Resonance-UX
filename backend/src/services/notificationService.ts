/**
 * Resonance UX Calm Notification Service
 *
 * A philosophy-driven notification system that:
 * - Respects the user's current flow phase (no interruptions during Deep Rest)
 * - Classifies urgency (only truly urgent notifications interrupt)
 * - Batches non-urgent notifications for delivery at appropriate phase transitions
 * - Routes to the correct device(s) via APNs, FCM, WNS, and Web Push
 * - Supports quiet hours and per-device muting
 */

import { v4 as uuid } from 'uuid';
import type {
  DeviceRegistration,
  DevicePlatform,
  NotificationUrgency,
  FlowPhase,
  DailyPhaseConfig,
} from '../../../shared/types';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface NotificationPayload {
  id: string;
  userId: string;
  title: string;
  body: string;
  urgency: NotificationUrgency;
  category?: string; // e.g. 'message', 'task', 'wellness', 'system'
  data?: Record<string, string>;
  imageUrl?: string;
  actionUrl?: string;
  sound?: 'default' | 'gentle' | 'none';
  badge?: number;
  collapseKey?: string; // group related notifications
  ttlSeconds?: number;
  createdAt: string;
}

export interface DeliveryResult {
  notificationId: string;
  deviceId: string;
  platform: string;
  success: boolean;
  error?: string;
  deliveredAt?: string;
}

export interface BatchedNotification {
  notification: NotificationPayload;
  scheduledFor: string; // ISO timestamp when it should be delivered
  batchKey: string;
}

interface QuietHoursConfig {
  enabled: boolean;
  start: string; // HH:mm
  end: string;   // HH:mm
}

interface UserNotificationConfig {
  quietHours: QuietHoursConfig;
  phaseConfigs: DailyPhaseConfig[];
  devices: DeviceRegistration[];
  currentPhase: FlowPhase;
  mutedCategories: Set<string>;
}

// ---------------------------------------------------------------------------
// Urgency Classification
// ---------------------------------------------------------------------------

/**
 * Determines whether a notification should interrupt based on urgency
 * and the user's current flow state.
 */
function shouldInterrupt(urgency: NotificationUrgency, phase: FlowPhase): boolean {
  switch (urgency) {
    case 'critical':
      // Always deliver critical notifications (emergency, security)
      return true;
    case 'high':
      // Deliver during active phases, batch during rest
      return phase !== 'deep-rest';
    case 'normal':
      // Only during morning, midday, afternoon
      return ['morning-focus', 'midday', 'afternoon'].includes(phase);
    case 'low':
      // Only during midday (break-like phase)
      return phase === 'midday';
    case 'silent':
      // Never interrupt, always batch
      return false;
    default:
      return false;
  }
}

/**
 * Infer the urgency of a notification based on category and content heuristics.
 */
function classifyUrgency(
  category: string | undefined,
  title: string,
  body: string,
): NotificationUrgency {
  const text = `${title} ${body}`.toLowerCase();

  // Critical: security, emergency
  if (text.includes('security') || text.includes('emergency') || text.includes('urgent')) {
    return 'critical';
  }

  // High: direct messages, active calls
  if (category === 'call' || category === 'video-call') return 'high';
  if (category === 'message' && text.includes('voice')) return 'high';

  // Normal: regular messages, task reminders
  if (category === 'message') return 'normal';
  if (category === 'task') return 'normal';

  // Low: wellness updates, system info
  if (category === 'wellness') return 'low';
  if (category === 'system') return 'low';

  return 'normal';
}

// ---------------------------------------------------------------------------
// Time Utilities
// ---------------------------------------------------------------------------

function parseTime(hhmm: string): { hours: number; minutes: number } {
  const [h, m] = hhmm.split(':').map(Number);
  return { hours: h || 0, minutes: m || 0 };
}

function isInQuietHours(config: QuietHoursConfig): boolean {
  if (!config.enabled) return false;

  const now = new Date();
  const currentMinutes = now.getHours() * 60 + now.getMinutes();
  const start = parseTime(config.start);
  const end = parseTime(config.end);
  const startMinutes = start.hours * 60 + start.minutes;
  const endMinutes = end.hours * 60 + end.minutes;

  if (startMinutes <= endMinutes) {
    // Same day (e.g., 09:00 - 17:00)
    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  } else {
    // Crosses midnight (e.g., 22:00 - 07:00)
    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }
}

function getNextPhaseTransition(phaseConfigs: DailyPhaseConfig[], currentPhase: FlowPhase): Date {
  const now = new Date();
  const currentConfig = phaseConfigs.find((p) => p.phase === currentPhase);

  if (currentConfig) {
    const endTime = parseTime(currentConfig.endTime);
    const nextTransition = new Date(now);
    nextTransition.setHours(endTime.hours, endTime.minutes, 0, 0);

    if (nextTransition <= now) {
      // Already past, add a day
      nextTransition.setDate(nextTransition.getDate() + 1);
    }

    return nextTransition;
  }

  // Default: next hour
  const next = new Date(now);
  next.setHours(next.getHours() + 1, 0, 0, 0);
  return next;
}

// ---------------------------------------------------------------------------
// Platform Push Adapters
// ---------------------------------------------------------------------------

interface PushAdapter {
  send(device: DeviceRegistration, notification: NotificationPayload): Promise<DeliveryResult>;
}

class APNsAdapter implements PushAdapter {
  async send(device: DeviceRegistration, notification: NotificationPayload): Promise<DeliveryResult> {
    // In production: use @parse/node-apn or HTTP/2 to APNs
    console.log(`[APNs] Sending to ${device.deviceName}: ${notification.title}`);
    return {
      notificationId: notification.id,
      deviceId: device.id,
      platform: 'ios',
      success: true,
      deliveredAt: new Date().toISOString(),
    };
  }
}

class FCMAdapter implements PushAdapter {
  async send(device: DeviceRegistration, notification: NotificationPayload): Promise<DeliveryResult> {
    // In production: use firebase-admin SDK
    console.log(`[FCM] Sending to ${device.deviceName}: ${notification.title}`);
    return {
      notificationId: notification.id,
      deviceId: device.id,
      platform: 'android',
      success: true,
      deliveredAt: new Date().toISOString(),
    };
  }
}

class WNSAdapter implements PushAdapter {
  async send(device: DeviceRegistration, notification: NotificationPayload): Promise<DeliveryResult> {
    // In production: use WNS HTTP API
    console.log(`[WNS] Sending to ${device.deviceName}: ${notification.title}`);
    return {
      notificationId: notification.id,
      deviceId: device.id,
      platform: 'windows',
      success: true,
      deliveredAt: new Date().toISOString(),
    };
  }
}

class WebPushAdapter implements PushAdapter {
  async send(device: DeviceRegistration, notification: NotificationPayload): Promise<DeliveryResult> {
    // In production: use web-push library with VAPID keys
    console.log(`[WebPush] Sending to ${device.deviceName}: ${notification.title}`);
    return {
      notificationId: notification.id,
      deviceId: device.id,
      platform: 'web',
      success: true,
      deliveredAt: new Date().toISOString(),
    };
  }
}

function getAdapterForPlatform(platform: DevicePlatform | string): PushAdapter {
  switch (platform) {
    case 'ios':
    case 'macos':
    case 'watchos':
    case 'tvos':
      return new APNsAdapter();
    case 'android':
      return new FCMAdapter();
    case 'windows':
      return new WNSAdapter();
    case 'web':
    case 'linux':
    default:
      return new WebPushAdapter();
  }
}

// ---------------------------------------------------------------------------
// Notification Service (Singleton)
// ---------------------------------------------------------------------------

export class NotificationService {
  private static instance: NotificationService;

  private userConfigs: Map<string, UserNotificationConfig> = new Map();
  private batchQueue: Map<string, BatchedNotification[]> = new Map(); // userId -> batched
  private deliveryLog: DeliveryResult[] = [];
  private batchTimer: ReturnType<typeof setInterval>;

  private constructor() {
    // Process batched notifications every minute
    this.batchTimer = setInterval(() => this.processBatchQueue(), 60_000);
  }

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  destroy(): void {
    clearInterval(this.batchTimer);
  }

  // ---- Configuration ----

  setUserConfig(userId: string, config: Partial<UserNotificationConfig>): void {
    const existing = this.userConfigs.get(userId) || {
      quietHours: { enabled: false, start: '22:00', end: '07:00' },
      phaseConfigs: [],
      devices: [],
      currentPhase: 'morning-focus' as FlowPhase,
      mutedCategories: new Set<string>(),
    };

    this.userConfigs.set(userId, { ...existing, ...config });
  }

  getUserConfig(userId: string): UserNotificationConfig | undefined {
    return this.userConfigs.get(userId);
  }

  updateCurrentPhase(userId: string, phase: FlowPhase): void {
    const config = this.userConfigs.get(userId);
    if (config) {
      config.currentPhase = phase;
    }
  }

  registerDevice(userId: string, device: DeviceRegistration): void {
    const config = this.userConfigs.get(userId);
    if (config) {
      const existing = config.devices.findIndex((d) => d.id === device.id);
      if (existing !== -1) {
        config.devices[existing] = device;
      } else {
        config.devices.push(device);
      }
    }
  }

  unregisterDevice(userId: string, deviceId: string): void {
    const config = this.userConfigs.get(userId);
    if (config) {
      config.devices = config.devices.filter((d) => d.id !== deviceId);
    }
  }

  muteCategory(userId: string, category: string): void {
    const config = this.userConfigs.get(userId);
    if (config) config.mutedCategories.add(category);
  }

  unmuteCategory(userId: string, category: string): void {
    const config = this.userConfigs.get(userId);
    if (config) config.mutedCategories.delete(category);
  }

  // ---- Send ----

  async send(
    notification: Omit<NotificationPayload, 'id' | 'createdAt'>,
  ): Promise<{ delivered: DeliveryResult[]; batched: boolean }> {
    const fullNotification: NotificationPayload = {
      ...notification,
      id: uuid(),
      createdAt: new Date().toISOString(),
      urgency: notification.urgency || classifyUrgency(notification.category, notification.title, notification.body),
      sound: notification.sound || (notification.urgency === 'critical' ? 'default' : 'gentle'),
    };

    const config = this.userConfigs.get(notification.userId);

    // No config: deliver immediately to all known devices
    if (!config) {
      return { delivered: [], batched: false };
    }

    // Check muted categories
    if (notification.category && config.mutedCategories.has(notification.category)) {
      return { delivered: [], batched: false };
    }

    // Check quiet hours (critical overrides)
    if (
      fullNotification.urgency !== 'critical' &&
      isInQuietHours(config.quietHours)
    ) {
      this.addToBatch(notification.userId, fullNotification, config);
      return { delivered: [], batched: true };
    }

    // Check phase-based delivery
    if (!shouldInterrupt(fullNotification.urgency, config.currentPhase)) {
      this.addToBatch(notification.userId, fullNotification, config);
      return { delivered: [], batched: true };
    }

    // Deliver to all devices
    const results = await this.deliverToDevices(fullNotification, config.devices);
    return { delivered: results, batched: false };
  }

  // ---- Batch Processing ----

  private addToBatch(userId: string, notification: NotificationPayload, config: UserNotificationConfig): void {
    const batched = this.batchQueue.get(userId) || [];
    const scheduledFor = getNextPhaseTransition(config.phaseConfigs, config.currentPhase);

    batched.push({
      notification,
      scheduledFor: scheduledFor.toISOString(),
      batchKey: notification.collapseKey || notification.category || 'default',
    });

    // Collapse notifications with the same key
    const collapsed = this.collapseNotifications(batched);
    this.batchQueue.set(userId, collapsed);
  }

  private collapseNotifications(batch: BatchedNotification[]): BatchedNotification[] {
    const groups = new Map<string, BatchedNotification[]>();

    for (const item of batch) {
      const group = groups.get(item.batchKey) || [];
      group.push(item);
      groups.set(item.batchKey, group);
    }

    const result: BatchedNotification[] = [];

    for (const [, group] of groups) {
      if (group.length <= 1) {
        result.push(...group);
        continue;
      }

      // Keep the most recent, update body to indicate count
      const latest = group[group.length - 1];
      const count = group.length;

      result.push({
        ...latest,
        notification: {
          ...latest.notification,
          body: count > 1
            ? `${latest.notification.body} (+${count - 1} more)`
            : latest.notification.body,
          badge: count,
        },
      });
    }

    return result;
  }

  private async processBatchQueue(): Promise<void> {
    const now = new Date();

    for (const [userId, batch] of this.batchQueue) {
      const config = this.userConfigs.get(userId);
      if (!config) continue;

      // Skip if still in quiet hours
      if (isInQuietHours(config.quietHours)) continue;

      const ready = batch.filter((b) => new Date(b.scheduledFor) <= now);
      const pending = batch.filter((b) => new Date(b.scheduledFor) > now);

      if (ready.length > 0) {
        for (const item of ready) {
          await this.deliverToDevices(item.notification, config.devices);
        }
        this.batchQueue.set(userId, pending);
      }
    }
  }

  // ---- Delivery ----

  private async deliverToDevices(
    notification: NotificationPayload,
    devices: DeviceRegistration[],
  ): Promise<DeliveryResult[]> {
    // Only deliver to devices that have push tokens and sync enabled
    const eligibleDevices = devices.filter((d) => d.pushToken && d.syncEnabled);

    if (eligibleDevices.length === 0) return [];

    // Route to the most recently active device for non-critical
    const targetDevices =
      notification.urgency === 'critical'
        ? eligibleDevices
        : this.selectDeliveryDevices(eligibleDevices);

    const results: DeliveryResult[] = [];

    for (const device of targetDevices) {
      const adapter = getAdapterForPlatform(device.platform);
      try {
        const result = await adapter.send(device, notification);
        results.push(result);
        this.deliveryLog.push(result);
      } catch (err) {
        results.push({
          notificationId: notification.id,
          deviceId: device.id,
          platform: device.platform,
          success: false,
          error: err instanceof Error ? err.message : 'Unknown error',
        });
      }
    }

    return results;
  }

  /**
   * For non-critical notifications, deliver to the most recently active device
   * to avoid buzzing all devices simultaneously.
   */
  private selectDeliveryDevices(devices: DeviceRegistration[]): DeviceRegistration[] {
    if (devices.length <= 1) return devices;

    // Sort by lastSeenAt descending
    const sorted = [...devices].sort(
      (a, b) => new Date(b.lastSeenAt).getTime() - new Date(a.lastSeenAt).getTime(),
    );

    // Deliver to the most recent device, plus any wearables
    const primary = sorted[0];
    const wearables = sorted.filter(
      (d) => d.platform === ('watchos' as DevicePlatform) && d.id !== primary.id,
    );

    return [primary, ...wearables];
  }

  // ---- Stats ----

  getDeliveryLog(userId?: string, limit = 50): DeliveryResult[] {
    let results = this.deliveryLog;
    // In production, filter by userId via DB
    results = results.slice(-limit);
    return results;
  }

  getBatchQueueSize(userId: string): number {
    return this.batchQueue.get(userId)?.length ?? 0;
  }

  getPendingBatches(userId: string): BatchedNotification[] {
    return this.batchQueue.get(userId) || [];
  }
}
