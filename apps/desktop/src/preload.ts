/**
 * Luminous Attachment - Preload Script
 * Secure IPC bridge between renderer and main process.
 *
 * Exposes a carefully curated API surface via contextBridge,
 * enabling social sharing, file system access, notifications,
 * audio playback control, and system integration.
 */

import { contextBridge, ipcRenderer } from 'electron';

// ---------------------------------------------------------------------------
// Type definitions for the exposed API
// ---------------------------------------------------------------------------
export interface LuminousAPI {
  // Theme
  getSystemTheme: () => Promise<'day' | 'night'>;
  onSystemThemeChanged: (callback: (theme: 'day' | 'night') => void) => void;
  onSetTheme: (callback: (theme: 'day' | 'night') => void) => void;

  // Navigation
  onNavigate: (callback: (page: string) => void) => void;
  onAction: (callback: (action: string, ...args: unknown[]) => void) => void;
  onDeepLink: (callback: (data: { route: string; params: Record<string, string> }) => void) => void;

  // Notifications
  showNotification: (opts: { title: string; body: string; silent?: boolean }) => Promise<boolean>;

  // Daily insight
  getDailyInsight: () => Promise<string>;

  // Journal file system
  saveJournal: (data: { id: string; content: string }) => Promise<string>;
  loadJournals: () => Promise<unknown[]>;
  deleteJournal: (id: string) => Promise<boolean>;
  exportJournal: (data: { content: string; format: string }) => Promise<string | null>;

  // Audio
  saveAudio: (data: { id: string; buffer: ArrayBuffer }) => Promise<string>;
  onAudioControl: (callback: (action: string) => void) => void;

  // Social sharing
  shareToPlatform: (data: { platform: string; text: string; url?: string }) => Promise<boolean>;
  saveShareImage: (data: { dataUrl: string; filename: string }) => Promise<string | null>;

  // Window controls
  windowMinimize: () => Promise<void>;
  windowMaximize: () => Promise<void>;
  windowClose: () => Promise<void>;
  windowIsMaximized: () => Promise<boolean>;

  // App info
  getAppInfo: () => Promise<{
    version: string;
    name: string;
    platform: string;
    arch: string;
    electronVersion: string;
    userDataPath: string;
  }>;

  // Updates
  checkForUpdates: () => Promise<void>;
  downloadUpdate: () => Promise<void>;
  installUpdate: () => Promise<void>;
  onUpdateAvailable: (callback: (info: { version: string }) => void) => void;
  onUpdateDownloaded: (callback: () => void) => void;

  // Platform detection
  platform: string;
  isElectron: true;
}

// ---------------------------------------------------------------------------
// Helper to create safe event listeners that can be removed
// ---------------------------------------------------------------------------
function createListener(channel: string, callback: (...args: unknown[]) => void): void {
  const handler = (_event: Electron.IpcRendererEvent, ...args: unknown[]) => callback(...args);
  ipcRenderer.on(channel, handler);
}

// ---------------------------------------------------------------------------
// Expose API via context bridge
// ---------------------------------------------------------------------------
const api: LuminousAPI = {
  // ---- Theme ----
  getSystemTheme: () => ipcRenderer.invoke('get-system-theme'),
  onSystemThemeChanged: (callback) => createListener('system-theme-changed', callback),
  onSetTheme: (callback) => createListener('set-theme', callback as (...args: unknown[]) => void),

  // ---- Navigation ----
  onNavigate: (callback) => createListener('navigate', callback as (...args: unknown[]) => void),
  onAction: (callback) => createListener('action', callback as (...args: unknown[]) => void),
  onDeepLink: (callback) => createListener('deep-link', callback as (...args: unknown[]) => void),

  // ---- Notifications ----
  showNotification: (opts) => ipcRenderer.invoke('show-notification', opts),

  // ---- Daily insight ----
  getDailyInsight: () => ipcRenderer.invoke('get-daily-insight'),

  // ---- Journal ----
  saveJournal: (data) => ipcRenderer.invoke('save-journal', data),
  loadJournals: () => ipcRenderer.invoke('load-journals'),
  deleteJournal: (id) => ipcRenderer.invoke('delete-journal', id),
  exportJournal: (data) => ipcRenderer.invoke('export-journal-file', data),

  // ---- Audio ----
  saveAudio: (data) => ipcRenderer.invoke('save-audio', data),
  onAudioControl: (callback) => createListener('audio-control', callback as (...args: unknown[]) => void),

  // ---- Social sharing ----
  shareToPlatform: (data) => ipcRenderer.invoke('share-to-platform', data),
  saveShareImage: (data) => ipcRenderer.invoke('save-share-image', data),

  // ---- Window controls ----
  windowMinimize: () => ipcRenderer.invoke('window-minimize'),
  windowMaximize: () => ipcRenderer.invoke('window-maximize'),
  windowClose: () => ipcRenderer.invoke('window-close'),
  windowIsMaximized: () => ipcRenderer.invoke('window-is-maximized'),

  // ---- App info ----
  getAppInfo: () => ipcRenderer.invoke('get-app-info'),

  // ---- Updates ----
  checkForUpdates: () => ipcRenderer.invoke('check-for-updates'),
  downloadUpdate: () => ipcRenderer.invoke('download-update'),
  installUpdate: () => ipcRenderer.invoke('install-update'),
  onUpdateAvailable: (callback) => createListener('update-available', callback as (...args: unknown[]) => void),
  onUpdateDownloaded: (callback) => createListener('update-downloaded', callback as (...args: unknown[]) => void),

  // ---- Platform ----
  platform: process.platform,
  isElectron: true,
};

contextBridge.exposeInMainWorld('luminous', api);

// ---------------------------------------------------------------------------
// Also expose a minimal version detection for the renderer
// ---------------------------------------------------------------------------
contextBridge.exposeInMainWorld('versions', {
  node: process.versions.node,
  chrome: process.versions.chrome,
  electron: process.versions.electron,
});
