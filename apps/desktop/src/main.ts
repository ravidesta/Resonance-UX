/**
 * Luminous Attachment - Electron Main Process
 * Resonance UX Desktop Application
 *
 * Handles window creation with vibrancy/transparency for glass morphism,
 * IPC communication, system tray, menu bar, auto-updates, and deep linking.
 */

import {
  app,
  BrowserWindow,
  ipcMain,
  Tray,
  Menu,
  nativeTheme,
  nativeImage,
  Notification,
  shell,
  globalShortcut,
  dialog,
  protocol,
  screen,
} from 'electron';
import { autoUpdater } from 'electron-updater';
import * as path from 'path';
import * as fs from 'fs';
import * as os from 'os';

// ---------------------------------------------------------------------------
// Constants & paths
// ---------------------------------------------------------------------------
const IS_DEV = !app.isPackaged;
const PROTOCOL_NAME = 'luminous-attachment';
const USER_DATA_PATH = app.getPath('userData');
const JOURNAL_DIR = path.join(USER_DATA_PATH, 'journals');
const AUDIO_DIR = path.join(USER_DATA_PATH, 'audio');
const SHARE_DIR = path.join(USER_DATA_PATH, 'shares');

// Ensure data directories exist
for (const dir of [JOURNAL_DIR, AUDIO_DIR, SHARE_DIR]) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

// ---------------------------------------------------------------------------
// Window state persistence
// ---------------------------------------------------------------------------
interface WindowState {
  x?: number;
  y?: number;
  width: number;
  height: number;
  isMaximized: boolean;
}

const STATE_FILE = path.join(USER_DATA_PATH, 'window-state.json');

function loadWindowState(): WindowState {
  try {
    if (fs.existsSync(STATE_FILE)) {
      return JSON.parse(fs.readFileSync(STATE_FILE, 'utf-8'));
    }
  } catch {
    /* use defaults */
  }
  return { width: 1280, height: 860, isMaximized: false };
}

function saveWindowState(win: BrowserWindow): void {
  const bounds = win.getBounds();
  const state: WindowState = {
    x: bounds.x,
    y: bounds.y,
    width: bounds.width,
    height: bounds.height,
    isMaximized: win.isMaximized(),
  };
  try {
    fs.writeFileSync(STATE_FILE, JSON.stringify(state));
  } catch {
    /* ignore write failures */
  }
}

// ---------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------
let mainWindow: BrowserWindow | null = null;
let tray: Tray | null = null;
let isQuitting = false;

// ---------------------------------------------------------------------------
// Deep linking / single instance
// ---------------------------------------------------------------------------
const gotLock = app.requestSingleInstanceLock();
if (!gotLock) {
  app.quit();
} else {
  app.on('second-instance', (_event, argv) => {
    if (mainWindow) {
      if (mainWindow.isMinimized()) mainWindow.restore();
      mainWindow.focus();
      // Handle deep link from argv on Windows/Linux
      const deepLink = argv.find((arg) => arg.startsWith(`${PROTOCOL_NAME}://`));
      if (deepLink) handleDeepLink(deepLink);
    }
  });
}

if (process.defaultApp) {
  if (process.argv.length >= 2) {
    app.setAsDefaultProtocolClient(PROTOCOL_NAME, process.execPath, [
      path.resolve(process.argv[1]),
    ]);
  }
} else {
  app.setAsDefaultProtocolClient(PROTOCOL_NAME);
}

function handleDeepLink(url: string): void {
  try {
    const parsed = new URL(url);
    const route = parsed.pathname.replace(/^\/+/, '');
    mainWindow?.webContents.send('deep-link', { route, params: Object.fromEntries(parsed.searchParams) });
  } catch {
    /* invalid URL, ignore */
  }
}

app.on('open-url', (_event, url) => {
  handleDeepLink(url);
});

// ---------------------------------------------------------------------------
// Daily insights for tray / notifications
// ---------------------------------------------------------------------------
const DAILY_INSIGHTS = [
  'Your attachment style is not your destiny -- it is your starting point.',
  'Secure attachment begins with how you speak to yourself.',
  'Notice the pause between trigger and reaction. That is where growth lives.',
  'You deserve relationships that feel safe and nourishing.',
  'Healing is not linear. Every small step counts.',
  'Today, practice naming your emotions without judging them.',
  'Vulnerability is not weakness -- it is the birthplace of connection.',
  'Your nervous system remembers what your mind forgets. Be gentle.',
  'A secure base within yourself makes all relationships richer.',
  'You are allowed to need people. That is not a flaw.',
  'Boundaries are an act of self-respect, not rejection.',
  'The way you attach is a story you can rewrite.',
  'Rupture and repair strengthen bonds. Perfection is not required.',
  'Self-compassion is the foundation of secure attachment.',
  'Rest is not earned -- it is essential.',
  'Your feelings are valid messengers. Listen before you dismiss.',
  'Connection does not require losing yourself.',
  'Slow down. Your worth is not measured by productivity.',
  'Attunement starts with being attuned to yourself.',
  'Every relationship is an opportunity to practice secure attachment.',
];

function getDailyInsight(): string {
  const dayOfYear = Math.floor(
    (Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) / 86400000
  );
  return DAILY_INSIGHTS[dayOfYear % DAILY_INSIGHTS.length];
}

// ---------------------------------------------------------------------------
// Create main window
// ---------------------------------------------------------------------------
function createMainWindow(): void {
  const state = loadWindowState();
  const { width: screenW, height: screenH } = screen.getPrimaryDisplay().workAreaSize;

  mainWindow = new BrowserWindow({
    x: state.x ?? Math.round((screenW - state.width) / 2),
    y: state.y ?? Math.round((screenH - state.height) / 2),
    width: state.width,
    height: state.height,
    minWidth: 900,
    minHeight: 600,
    title: 'Luminous Attachment',
    icon: path.join(__dirname, '..', 'resources', 'icon.png'),
    frame: process.platform === 'darwin' ? true : true,
    titleBarStyle: process.platform === 'darwin' ? 'hiddenInset' : 'default',
    titleBarOverlay:
      process.platform === 'win32'
        ? { color: '#0A1C14', symbolColor: '#C5A059', height: 36 }
        : undefined,
    transparent: false,
    backgroundColor: '#05100B',
    vibrancy: process.platform === 'darwin' ? 'under-window' : undefined,
    visualEffectState: 'active',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false,
      webviewTag: false,
      spellcheck: true,
    },
    show: false,
  });

  if (state.isMaximized) mainWindow.maximize();

  // Graceful show to avoid white flash
  mainWindow.once('ready-to-show', () => {
    mainWindow?.show();
    if (IS_DEV) mainWindow?.webContents.openDevTools({ mode: 'detach' });
  });

  mainWindow.loadFile(path.join(__dirname, 'renderer.html'));

  // Save state on close
  mainWindow.on('close', (e) => {
    if (!isQuitting && tray) {
      e.preventDefault();
      mainWindow?.hide();
      return;
    }
    if (mainWindow) saveWindowState(mainWindow);
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  // External links open in browser
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });
}

// ---------------------------------------------------------------------------
// System tray
// ---------------------------------------------------------------------------
function createTray(): void {
  // Create a simple 16x16 tray icon placeholder (gold circle on transparent)
  const icon = nativeImage.createEmpty();
  tray = new Tray(icon);
  tray.setToolTip('Luminous Attachment');

  const updateTrayMenu = () => {
    const insight = getDailyInsight();
    const contextMenu = Menu.buildFromTemplate([
      {
        label: 'Luminous Attachment',
        enabled: false,
        icon: undefined,
      },
      { type: 'separator' },
      {
        label: 'Daily Insight',
        enabled: false,
      },
      {
        label: insight.length > 60 ? insight.substring(0, 57) + '...' : insight,
        enabled: false,
      },
      { type: 'separator' },
      {
        label: 'Open App',
        click: () => {
          mainWindow?.show();
          mainWindow?.focus();
        },
      },
      {
        label: 'Quick Journal Entry',
        click: () => {
          mainWindow?.show();
          mainWindow?.focus();
          mainWindow?.webContents.send('navigate', 'journal');
        },
      },
      {
        label: 'Start Breathing Exercise',
        click: () => {
          mainWindow?.show();
          mainWindow?.focus();
          mainWindow?.webContents.send('navigate', 'home');
          mainWindow?.webContents.send('action', 'start-breathing');
        },
      },
      { type: 'separator' },
      {
        label: 'Audiobook Controls',
        submenu: [
          {
            label: 'Play / Pause',
            click: () => mainWindow?.webContents.send('audio-control', 'toggle'),
          },
          {
            label: 'Next Chapter',
            click: () => mainWindow?.webContents.send('audio-control', 'next'),
          },
          {
            label: 'Previous Chapter',
            click: () => mainWindow?.webContents.send('audio-control', 'prev'),
          },
        ],
      },
      { type: 'separator' },
      {
        label: 'Day Mode',
        type: 'radio',
        checked: !nativeTheme.shouldUseDarkColors,
        click: () => mainWindow?.webContents.send('set-theme', 'day'),
      },
      {
        label: 'Night Mode',
        type: 'radio',
        checked: nativeTheme.shouldUseDarkColors,
        click: () => mainWindow?.webContents.send('set-theme', 'night'),
      },
      { type: 'separator' },
      {
        label: 'Quit',
        click: () => {
          isQuitting = true;
          app.quit();
        },
      },
    ]);
    tray?.setContextMenu(contextMenu);
  };

  updateTrayMenu();
  // Refresh tray menu every hour for new insight
  setInterval(updateTrayMenu, 3600000);

  tray.on('click', () => {
    if (mainWindow?.isVisible()) {
      mainWindow.focus();
    } else {
      mainWindow?.show();
    }
  });
}

// ---------------------------------------------------------------------------
// Application menu
// ---------------------------------------------------------------------------
function createMenu(): void {
  const isMac = process.platform === 'darwin';

  const template: Electron.MenuItemConstructorOptions[] = [
    ...(isMac
      ? [
          {
            label: app.name,
            submenu: [
              { role: 'about' as const },
              { type: 'separator' as const },
              {
                label: 'Preferences...',
                accelerator: 'CmdOrCtrl+,',
                click: () => mainWindow?.webContents.send('action', 'open-settings'),
              },
              { type: 'separator' as const },
              { role: 'services' as const },
              { type: 'separator' as const },
              { role: 'hide' as const },
              { role: 'hideOthers' as const },
              { role: 'unhide' as const },
              { type: 'separator' as const },
              { role: 'quit' as const },
            ],
          } as Electron.MenuItemConstructorOptions,
        ]
      : []),
    {
      label: 'File',
      submenu: [
        {
          label: 'New Journal Entry',
          accelerator: 'CmdOrCtrl+N',
          click: () => {
            mainWindow?.webContents.send('navigate', 'journal');
            mainWindow?.webContents.send('action', 'new-entry');
          },
        },
        { type: 'separator' },
        {
          label: 'Export Journal...',
          accelerator: 'CmdOrCtrl+Shift+E',
          click: async () => {
            const result = await dialog.showSaveDialog(mainWindow!, {
              title: 'Export Journal',
              defaultPath: `luminous-journal-${new Date().toISOString().split('T')[0]}.json`,
              filters: [
                { name: 'JSON', extensions: ['json'] },
                { name: 'Text', extensions: ['txt'] },
              ],
            });
            if (!result.canceled && result.filePath) {
              mainWindow?.webContents.send('action', 'export-journal', result.filePath);
            }
          },
        },
        { type: 'separator' },
        isMac ? { role: 'close' } : { role: 'quit' },
      ],
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' },
        { role: 'selectAll' },
      ],
    },
    {
      label: 'View',
      submenu: [
        {
          label: 'Home',
          accelerator: 'CmdOrCtrl+1',
          click: () => mainWindow?.webContents.send('navigate', 'home'),
        },
        {
          label: 'Learn',
          accelerator: 'CmdOrCtrl+2',
          click: () => mainWindow?.webContents.send('navigate', 'learn'),
        },
        {
          label: 'Journal',
          accelerator: 'CmdOrCtrl+3',
          click: () => mainWindow?.webContents.send('navigate', 'journal'),
        },
        {
          label: 'Coach',
          accelerator: 'CmdOrCtrl+4',
          click: () => mainWindow?.webContents.send('navigate', 'coach'),
        },
        {
          label: 'Library',
          accelerator: 'CmdOrCtrl+5',
          click: () => mainWindow?.webContents.send('navigate', 'library'),
        },
        {
          label: 'Share',
          accelerator: 'CmdOrCtrl+6',
          click: () => mainWindow?.webContents.send('navigate', 'share'),
        },
        { type: 'separator' },
        {
          label: 'Toggle Day/Night Mode',
          accelerator: 'CmdOrCtrl+Shift+D',
          click: () => mainWindow?.webContents.send('action', 'toggle-theme'),
        },
        { type: 'separator' },
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'resetZoom' },
        { role: 'zoomIn' },
        { role: 'zoomOut' },
        { type: 'separator' },
        { role: 'togglefullscreen' },
      ],
    },
    {
      label: 'Navigate',
      submenu: [
        {
          label: 'Start Breathing Exercise',
          accelerator: 'CmdOrCtrl+B',
          click: () => {
            mainWindow?.webContents.send('navigate', 'home');
            mainWindow?.webContents.send('action', 'start-breathing');
          },
        },
        {
          label: 'Quick Mood Check-in',
          accelerator: 'CmdOrCtrl+M',
          click: () => {
            mainWindow?.webContents.send('navigate', 'home');
            mainWindow?.webContents.send('action', 'mood-checkin');
          },
        },
        { type: 'separator' },
        {
          label: 'Play/Pause Audiobook',
          accelerator: 'Space',
          click: () => mainWindow?.webContents.send('audio-control', 'toggle'),
          registerAccelerator: false,
        },
      ],
    },
    {
      label: 'Window',
      submenu: [
        { role: 'minimize' },
        { role: 'zoom' },
        ...(isMac
          ? [{ type: 'separator' as const }, { role: 'front' as const }]
          : [{ role: 'close' as const }]),
      ],
    },
    {
      label: 'Help',
      submenu: [
        {
          label: 'About Luminous Attachment',
          click: () => {
            dialog.showMessageBox(mainWindow!, {
              type: 'info',
              title: 'Luminous Attachment',
              message: 'Luminous Attachment v1.0.0',
              detail:
                'By Resonance UX\n\nYour guided journey toward secure, confident relationships.\n\nAttachment theory meets modern self-development.',
            });
          },
        },
        {
          label: 'Learn More',
          click: () => shell.openExternal('https://resonanceux.com'),
        },
        { type: 'separator' },
        {
          label: 'Report Issue',
          click: () =>
            shell.openExternal(
              'https://github.com/resonance-ux/luminous-attachment/issues'
            ),
        },
      ],
    },
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

// ---------------------------------------------------------------------------
// IPC Handlers
// ---------------------------------------------------------------------------
function setupIPC(): void {
  // Theme detection
  ipcMain.handle('get-system-theme', () => {
    return nativeTheme.shouldUseDarkColors ? 'night' : 'day';
  });

  nativeTheme.on('updated', () => {
    mainWindow?.webContents.send(
      'system-theme-changed',
      nativeTheme.shouldUseDarkColors ? 'night' : 'day'
    );
  });

  // Notifications
  ipcMain.handle('show-notification', (_event, opts: { title: string; body: string; silent?: boolean }) => {
    if (Notification.isSupported()) {
      const notif = new Notification({
        title: opts.title,
        body: opts.body,
        silent: opts.silent ?? false,
        icon: path.join(__dirname, '..', 'resources', 'icon.png'),
      });
      notif.on('click', () => {
        mainWindow?.show();
        mainWindow?.focus();
      });
      notif.show();
      return true;
    }
    return false;
  });

  // Daily insight
  ipcMain.handle('get-daily-insight', () => getDailyInsight());

  // File system - journals
  ipcMain.handle('save-journal', (_event, data: { id: string; content: string }) => {
    const filePath = path.join(JOURNAL_DIR, `${data.id}.json`);
    fs.writeFileSync(filePath, data.content, 'utf-8');
    return filePath;
  });

  ipcMain.handle('load-journals', () => {
    const files = fs.readdirSync(JOURNAL_DIR).filter((f) => f.endsWith('.json'));
    return files.map((f) => {
      const content = fs.readFileSync(path.join(JOURNAL_DIR, f), 'utf-8');
      try {
        return JSON.parse(content);
      } catch {
        return null;
      }
    }).filter(Boolean);
  });

  ipcMain.handle('delete-journal', (_event, id: string) => {
    const filePath = path.join(JOURNAL_DIR, `${id}.json`);
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    return true;
  });

  // Audio recording save
  ipcMain.handle('save-audio', (_event, data: { id: string; buffer: ArrayBuffer }) => {
    const filePath = path.join(AUDIO_DIR, `${data.id}.webm`);
    fs.writeFileSync(filePath, Buffer.from(data.buffer));
    return filePath;
  });

  // Share card image save
  ipcMain.handle('save-share-image', async (_event, data: { dataUrl: string; filename: string }) => {
    const result = await dialog.showSaveDialog(mainWindow!, {
      title: 'Save Share Card',
      defaultPath: data.filename,
      filters: [{ name: 'Images', extensions: ['png'] }],
    });
    if (!result.canceled && result.filePath) {
      const base64 = data.dataUrl.replace(/^data:image\/png;base64,/, '');
      fs.writeFileSync(result.filePath, Buffer.from(base64, 'base64'));
      return result.filePath;
    }
    return null;
  });

  // Social sharing via shell
  ipcMain.handle('share-to-platform', (_event, data: { platform: string; text: string; url?: string }) => {
    const encodedText = encodeURIComponent(data.text);
    const encodedUrl = encodeURIComponent(data.url || 'https://resonanceux.com/luminous-attachment');
    const shareUrls: Record<string, string> = {
      twitter: `https://twitter.com/intent/tweet?text=${encodedText}&url=${encodedUrl}`,
      facebook: `https://www.facebook.com/sharer/sharer.php?u=${encodedUrl}&quote=${encodedText}`,
      linkedin: `https://www.linkedin.com/shareArticle?mini=true&url=${encodedUrl}&title=${encodedText}`,
      reddit: `https://reddit.com/submit?url=${encodedUrl}&title=${encodedText}`,
      pinterest: `https://pinterest.com/pin/create/button/?url=${encodedUrl}&description=${encodedText}`,
      whatsapp: `https://wa.me/?text=${encodedText}%20${encodedUrl}`,
      telegram: `https://t.me/share/url?url=${encodedUrl}&text=${encodedText}`,
      threads: `https://threads.net/intent/post?text=${encodedText}`,
      email: `mailto:?subject=Luminous%20Attachment&body=${encodedText}%0A%0A${encodedUrl}`,
    };
    const shareUrl = shareUrls[data.platform];
    if (shareUrl) {
      shell.openExternal(shareUrl);
      return true;
    }
    return false;
  });

  // Export journal
  ipcMain.handle('export-journal-file', async (_event, data: { content: string; format: string }) => {
    const result = await dialog.showSaveDialog(mainWindow!, {
      title: 'Export Journal',
      defaultPath: `luminous-journal-${new Date().toISOString().split('T')[0]}.${data.format}`,
      filters: [{ name: data.format.toUpperCase(), extensions: [data.format] }],
    });
    if (!result.canceled && result.filePath) {
      fs.writeFileSync(result.filePath, data.content, 'utf-8');
      return result.filePath;
    }
    return null;
  });

  // App info
  ipcMain.handle('get-app-info', () => ({
    version: app.getVersion(),
    name: app.getName(),
    platform: process.platform,
    arch: process.arch,
    electronVersion: process.versions.electron,
    userDataPath: USER_DATA_PATH,
  }));

  // Window controls
  ipcMain.handle('window-minimize', () => mainWindow?.minimize());
  ipcMain.handle('window-maximize', () => {
    if (mainWindow?.isMaximized()) {
      mainWindow.unmaximize();
    } else {
      mainWindow?.maximize();
    }
  });
  ipcMain.handle('window-close', () => mainWindow?.close());
  ipcMain.handle('window-is-maximized', () => mainWindow?.isMaximized() ?? false);
}

// ---------------------------------------------------------------------------
// Global shortcuts
// ---------------------------------------------------------------------------
function registerShortcuts(): void {
  // Quick journal entry from anywhere
  globalShortcut.register('CmdOrCtrl+Shift+J', () => {
    mainWindow?.show();
    mainWindow?.focus();
    mainWindow?.webContents.send('navigate', 'journal');
    mainWindow?.webContents.send('action', 'new-entry');
  });

  // Quick breathing exercise
  globalShortcut.register('CmdOrCtrl+Shift+B', () => {
    mainWindow?.show();
    mainWindow?.focus();
    mainWindow?.webContents.send('navigate', 'home');
    mainWindow?.webContents.send('action', 'start-breathing');
  });
}

// ---------------------------------------------------------------------------
// Auto updater
// ---------------------------------------------------------------------------
function setupAutoUpdater(): void {
  autoUpdater.autoDownload = false;
  autoUpdater.autoInstallOnAppQuit = true;

  autoUpdater.on('update-available', (info) => {
    mainWindow?.webContents.send('update-available', info);
    if (Notification.isSupported()) {
      const notif = new Notification({
        title: 'Update Available',
        body: `Luminous Attachment v${info.version} is available. Click to download.`,
      });
      notif.on('click', () => autoUpdater.downloadUpdate());
      notif.show();
    }
  });

  autoUpdater.on('update-downloaded', () => {
    mainWindow?.webContents.send('update-downloaded');
    if (Notification.isSupported()) {
      const notif = new Notification({
        title: 'Update Ready',
        body: 'Restart to install the latest version of Luminous Attachment.',
      });
      notif.on('click', () => autoUpdater.quitAndInstall());
      notif.show();
    }
  });

  ipcMain.handle('check-for-updates', () => autoUpdater.checkForUpdates());
  ipcMain.handle('download-update', () => autoUpdater.downloadUpdate());
  ipcMain.handle('install-update', () => autoUpdater.quitAndInstall());
}

// ---------------------------------------------------------------------------
// Schedule daily insight notification
// ---------------------------------------------------------------------------
function scheduleDailyInsight(): void {
  const sendInsight = () => {
    if (Notification.isSupported()) {
      const notif = new Notification({
        title: 'Daily Insight',
        body: getDailyInsight(),
        icon: path.join(__dirname, '..', 'resources', 'icon.png'),
      });
      notif.on('click', () => {
        mainWindow?.show();
        mainWindow?.focus();
      });
      notif.show();
    }
  };

  // Send insight at 9 AM local time
  const now = new Date();
  const target = new Date(now);
  target.setHours(9, 0, 0, 0);
  if (target <= now) target.setDate(target.getDate() + 1);

  const delay = target.getTime() - now.getTime();
  setTimeout(() => {
    sendInsight();
    // Then every 24 hours
    setInterval(sendInsight, 24 * 60 * 60 * 1000);
  }, delay);
}

// ---------------------------------------------------------------------------
// App lifecycle
// ---------------------------------------------------------------------------
app.whenReady().then(() => {
  setupIPC();
  createMainWindow();
  createTray();
  createMenu();
  registerShortcuts();
  setupAutoUpdater();
  scheduleDailyInsight();

  // Check for updates after a short delay
  if (!IS_DEV) {
    setTimeout(() => autoUpdater.checkForUpdates(), 5000);
  }

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow();
    } else {
      mainWindow?.show();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('before-quit', () => {
  isQuitting = true;
  globalShortcut.unregisterAll();
});

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
});
