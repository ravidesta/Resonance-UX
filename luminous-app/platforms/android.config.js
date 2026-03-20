/**
 * Android Platform Configuration
 * Luminous Lifewheel — Material You Integration
 *
 * Native Android features: Material You theming, widgets,
 * Wear OS companion, notification channels, and accessibility.
 */

export const AndroidConfig = {
  platform: 'android',
  minSdk: 26,      // Android 8.0+
  targetSdk: 35,   // Android 15

  // Material You integration
  materialYou: {
    dynamicColor: true,       // Adapt accent colors from wallpaper
    adaptiveIcon: true,
    monet: {
      // Map Luminous gold/green to Material You color roles
      seed: '#C5A059',        // Gold as seed color
      secondarySeed: '#122E21', // Deep green
    },
  },

  // Widgets
  widgets: {
    dailyCheckin: {
      type: 'glance',
      sizes: ['2x2', '4x2'],
      description: 'Quick daily luminous check-in',
      refreshInterval: 1800000,
    },
    lifewheelWidget: {
      type: 'glance',
      sizes: ['3x3', '4x4'],
      description: 'Your current Lifewheel visualization',
      refreshInterval: 3600000,
    },
    quoteWidget: {
      type: 'glance',
      sizes: ['4x1', '4x2'],
      description: 'Daily luminous inspiration',
      refreshInterval: 86400000,
    },
  },

  // Wear OS companion
  wearOS: {
    enabled: true,
    complications: [
      { id: 'dailyPhase', type: 'SHORT_TEXT', description: 'Current daily phase (Ascend/Zenith/Descent/Rest)' },
      { id: 'practiceReminder', type: 'SMALL_IMAGE', description: 'Micro-practice reminder' },
      { id: 'wheelScore', type: 'RANGED_VALUE', description: 'Average lifewheel score' },
    ],
    tiles: [
      { id: 'quickCheckin', description: '2-minute check-in on your wrist' },
      { id: 'breathePractice', description: 'Guided 3-breath arrival practice' },
    ],
  },

  // Notification channels
  notifications: {
    channels: [
      { id: 'daily_checkin', name: 'Daily Check-In', importance: 'default', sound: 'gentle_chime' },
      { id: 'micro_practice', name: 'Micro-Practice', importance: 'low', sound: 'soft_bell' },
      { id: 'community', name: 'Community', importance: 'default' },
      { id: 'coach', name: 'Coaching', importance: 'high' },
    ],
  },

  // Accessibility
  accessibility: {
    talkBack: true,
    contentDescriptions: true,
    minimumTouchTarget: 48,
    highContrast: true,
    reduceMotion: true,
  },

  // Resonance UX Android adaptations
  resonanceUX: {
    navigationStyle: 'gestural',
    statusBarStyle: 'transparent',
    edgeToEdge: true,
    haptics: {
      onScore: 'EFFECT_TICK',
      onComplete: 'EFFECT_HEAVY_CLICK',
      onNavigate: 'EFFECT_CLICK',
    },
  },
};

export default AndroidConfig;
