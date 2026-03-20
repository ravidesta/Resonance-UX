/**
 * Windows Platform Configuration
 * Luminous Lifewheel — Desktop Experience
 *
 * Optimized for mouse/keyboard, large screens, multi-window,
 * and Windows-specific features like Live Tiles and widgets.
 */

export const WindowsConfig = {
  platform: 'windows',
  minVersion: '10.0.19041',  // Windows 10 2004+

  // React Native Windows settings
  reactNativeWindows: {
    solutionFile: 'windows/LuminousLifewheel.sln',
    project: {
      projectName: 'LuminousLifewheel',
      mainComponentName: 'LuminousLifewheel',
      projectGuid: '{B7D0B214-5A8A-4F2C-A2E4-8C9A6F8D3E1B}',
    },
  },

  // Window management
  windows: {
    main: {
      title: 'Luminous Lifewheel',
      minWidth: 800,
      minHeight: 600,
      defaultWidth: 1280,
      defaultHeight: 900,
      titleBarStyle: 'acrylic',  // Mica/Acrylic title bar
      theme: 'followSystem',
    },
    writerPopout: {
      title: 'Sanctuary Writer',
      defaultWidth: 720,
      defaultHeight: 900,
      // Writer can pop out to its own focused window
    },
  },

  // Windows-specific features
  features: {
    // Widgets
    widgets: {
      dailyCheckin: {
        size: 'medium',
        refreshInterval: 3600000, // 1 hour
        content: 'Daily check-in reminder with phase-of-day',
      },
      lifewheelMini: {
        size: 'large',
        content: 'Mini lifewheel visualization with scores',
      },
    },

    // Notifications
    notifications: {
      provider: 'windows-notification',
      categories: [
        { id: 'dailyCheckin', name: 'Daily Check-In Reminder' },
        { id: 'practiceReminder', name: 'Micro-Practice Reminders' },
        { id: 'communityUpdate', name: 'Community Circle Updates' },
        { id: 'coachSession', name: 'Coaching Session Alerts' },
      ],
    },

    // Keyboard shortcuts
    shortcuts: {
      'Ctrl+N': 'newJournalEntry',
      'Ctrl+Shift+W': 'openWriter',
      'Ctrl+D': 'dailyCheckin',
      'Ctrl+L': 'viewLifewheel',
      'Ctrl+,': 'settings',
      'F11': 'focusMode',
    },

    // System tray
    systemTray: {
      enabled: true,
      tooltip: 'Luminous Lifewheel',
      quickActions: ['dailyCheckin', 'openWriter', 'viewWheel'],
    },
  },

  // Resonance UX desktop adaptations
  resonanceUX: {
    glassEffect: 'acrylic',  // Windows Acrylic material
    hoverStates: true,        // Full hover interactions
    sidebarLayout: true,      // Sidebar navigation on wide screens
    multiColumnDashboard: true,
    contextMenus: true,
    dragAndDrop: true,
  },
};

export default WindowsConfig;
