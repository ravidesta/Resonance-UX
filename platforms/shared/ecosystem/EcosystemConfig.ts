/**
 * Luminous Cosmic Architecture™ — Ecosystem Configuration
 * Connects the astrology app into the broader Luminous Prosperity ecosystem
 */

export interface EcosystemConfig {
  api: ApiEndpoints;
  deepLinks: DeepLinkConfig;
  features: FeatureFlags;
  tiers: SubscriptionTier[];
  social: SocialSharingConfig;
  integrations: IntegrationPoints;
}

// ─── API Endpoints ────────────────────────────────────────────────

export interface ApiEndpoints {
  baseUrl: string;
  auth: {
    login: string;
    register: string;
    refreshToken: string;
    socialAuth: string;
  };
  user: {
    profile: string;
    birthChart: string;
    preferences: string;
    journalEntries: string;
    meditationHistory: string;
    readingProgress: string;
  };
  content: {
    chapters: string;
    dailyReflection: string;
    meditations: string;
    transits: string;
    moonPhase: string;
  };
  facilitator: {
    chat: string;
    voiceSession: string;
    conversationHistory: string;
  };
  community: {
    forums: string;
    events: string;
    coaches: string;
    groupSessions: string;
    sharedCharts: string;
  };
  ecosystem: {
    workshops: string;
    courses: string;
    merchandise: string;
    notifications: string;
  };
}

// ─── Deep Linking ─────────────────────────────────────────────────

export interface DeepLinkConfig {
  scheme: string; // "luminouscosmic"
  universalLinks: {
    domain: string;
    paths: {
      chart: string;       // /chart/:userId
      reflection: string;  // /reflection/:date
      chapter: string;     // /book/chapter/:id
      meditation: string;  // /meditation/:id
      facilitator: string; // /guide
      community: string;   // /community/:threadId
      share: string;       // /share/:contentId
    };
  };
  platformLinks: {
    ios: string;      // App Store URL
    android: string;  // Play Store URL
    web: string;      // Web app URL
    macos: string;    // Mac App Store URL
    windows: string;  // Microsoft Store URL
  };
}

// ─── Feature Flags ────────────────────────────────────────────────

export interface FeatureFlags {
  natalChart: boolean;
  dailyReflections: boolean;
  guidedMeditations: boolean;
  chapterLibrary: boolean;
  facilitatorText: boolean;
  facilitatorVoice: boolean;
  community: boolean;
  audiobook: boolean;
  advancedTransits: boolean;
  coachMatching: boolean;
  liveWorkshops: boolean;
  chartComparisons: boolean;
  socialSharing: boolean;
  watchComplications: boolean;
}

// ─── Subscription Tiers ───────────────────────────────────────────

export interface SubscriptionTier {
  id: string;
  name: string;
  tagline: string;
  monthlyPrice: number;
  yearlyPrice: number;
  features: FeatureFlags;
  accentColor: string;
  icon: string;
}

export const SUBSCRIPTION_TIERS: SubscriptionTier[] = [
  {
    id: "free",
    name: "Stargazer",
    tagline: "Begin your cosmic journey",
    monthlyPrice: 0,
    yearlyPrice: 0,
    features: {
      natalChart: true,
      dailyReflections: true, // limited to 1/day
      guidedMeditations: false, // preview only
      chapterLibrary: true, // Chapter 1 only
      facilitatorText: true, // 3 messages/day
      facilitatorVoice: false,
      community: false,
      audiobook: false,
      advancedTransits: false,
      coachMatching: false,
      liveWorkshops: false,
      chartComparisons: false,
      socialSharing: true,
      watchComplications: true,
    },
    accentColor: "#8A9C91",
    icon: "star",
  },
  {
    id: "seeker",
    name: "Seeker",
    tagline: "Deepen your understanding",
    monthlyPrice: 9.99,
    yearlyPrice: 89.99,
    features: {
      natalChart: true,
      dailyReflections: true,
      guidedMeditations: true,
      chapterLibrary: true, // All chapters
      facilitatorText: true, // Unlimited
      facilitatorVoice: false,
      community: false,
      audiobook: false,
      advancedTransits: true,
      coachMatching: false,
      liveWorkshops: false,
      chartComparisons: true,
      socialSharing: true,
      watchComplications: true,
    },
    accentColor: "#C5A059",
    icon: "compass",
  },
  {
    id: "luminary",
    name: "Luminary",
    tagline: "Illuminate your path",
    monthlyPrice: 19.99,
    yearlyPrice: 179.99,
    features: {
      natalChart: true,
      dailyReflections: true,
      guidedMeditations: true,
      chapterLibrary: true,
      facilitatorText: true,
      facilitatorVoice: true,
      community: true,
      audiobook: true,
      advancedTransits: true,
      coachMatching: true,
      liveWorkshops: false,
      chartComparisons: true,
      socialSharing: true,
      watchComplications: true,
    },
    accentColor: "#E6D0A1",
    icon: "sun",
  },
  {
    id: "constellation",
    name: "Constellation",
    tagline: "The complete cosmic experience",
    monthlyPrice: 49.99,
    yearlyPrice: 449.99,
    features: {
      natalChart: true,
      dailyReflections: true,
      guidedMeditations: true,
      chapterLibrary: true,
      facilitatorText: true,
      facilitatorVoice: true,
      community: true,
      audiobook: true,
      advancedTransits: true,
      coachMatching: true,
      liveWorkshops: true,
      chartComparisons: true,
      socialSharing: true,
      watchComplications: true,
    },
    accentColor: "#C5A059",
    icon: "sparkles",
  },
];

// ─── Social Sharing ───────────────────────────────────────────────

export interface SocialSharingConfig {
  platforms: SocialPlatform[];
  shareableContent: ShareableContentType[];
  branding: ShareBranding;
}

export interface SocialPlatform {
  id: string;
  name: string;
  icon: string;
  shareUrl: string;
  supportsImage: boolean;
  supportsVideo: boolean;
  maxTextLength: number;
}

export type ShareableContentType =
  | "natal_chart_image"
  | "daily_reflection"
  | "moon_phase"
  | "transit_insight"
  | "meditation_completion"
  | "chapter_quote"
  | "zodiac_season"
  | "facilitator_insight"
  | "chart_comparison";

export interface ShareBranding {
  appName: string;
  hashtags: string[];
  watermark: boolean;
  downloadUrl: string;
  tagline: string;
}

export const SOCIAL_PLATFORMS: SocialPlatform[] = [
  {
    id: "instagram",
    name: "Instagram",
    icon: "instagram",
    shareUrl: "instagram://",
    supportsImage: true,
    supportsVideo: true,
    maxTextLength: 2200,
  },
  {
    id: "instagram_stories",
    name: "Instagram Stories",
    icon: "instagram",
    shareUrl: "instagram-stories://share",
    supportsImage: true,
    supportsVideo: true,
    maxTextLength: 0,
  },
  {
    id: "tiktok",
    name: "TikTok",
    icon: "tiktok",
    shareUrl: "tiktok://",
    supportsImage: true,
    supportsVideo: true,
    maxTextLength: 2200,
  },
  {
    id: "twitter",
    name: "X (Twitter)",
    icon: "twitter",
    shareUrl: "https://twitter.com/intent/tweet",
    supportsImage: true,
    supportsVideo: false,
    maxTextLength: 280,
  },
  {
    id: "facebook",
    name: "Facebook",
    icon: "facebook",
    shareUrl: "https://www.facebook.com/sharer/sharer.php",
    supportsImage: true,
    supportsVideo: true,
    maxTextLength: 63206,
  },
  {
    id: "pinterest",
    name: "Pinterest",
    icon: "pinterest",
    shareUrl: "https://pinterest.com/pin/create/button/",
    supportsImage: true,
    supportsVideo: false,
    maxTextLength: 500,
  },
  {
    id: "threads",
    name: "Threads",
    icon: "threads",
    shareUrl: "threads://",
    supportsImage: true,
    supportsVideo: true,
    maxTextLength: 500,
  },
  {
    id: "whatsapp",
    name: "WhatsApp",
    icon: "whatsapp",
    shareUrl: "whatsapp://send",
    supportsImage: true,
    supportsVideo: true,
    maxTextLength: 65536,
  },
  {
    id: "telegram",
    name: "Telegram",
    icon: "telegram",
    shareUrl: "tg://msg_url",
    supportsImage: true,
    supportsVideo: true,
    maxTextLength: 4096,
  },
  {
    id: "snapchat",
    name: "Snapchat",
    icon: "snapchat",
    shareUrl: "snapchat://",
    supportsImage: true,
    supportsVideo: true,
    maxTextLength: 250,
  },
  {
    id: "messages",
    name: "Messages",
    icon: "message",
    shareUrl: "sms:",
    supportsImage: true,
    supportsVideo: false,
    maxTextLength: 1600,
  },
  {
    id: "email",
    name: "Email",
    icon: "mail",
    shareUrl: "mailto:",
    supportsImage: true,
    supportsVideo: false,
    maxTextLength: 100000,
  },
  {
    id: "copy_link",
    name: "Copy Link",
    icon: "link",
    shareUrl: "",
    supportsImage: false,
    supportsVideo: false,
    maxTextLength: 0,
  },
];

export const SHARE_BRANDING: ShareBranding = {
  appName: "Luminous Cosmic Architecture™",
  hashtags: [
    "#LuminousCosmic",
    "#AstrologyAsMap",
    "#CosmicArchitecture",
    "#LuminousProsperity",
    "#DevelopmentalAstrology",
    "#NatalChart",
    "#CosmicJourney",
  ],
  watermark: true,
  downloadUrl: "https://luminouscosmic.app",
  tagline: "The cosmos did not write your story — but it may have provided the alphabet.",
};

// ─── Integration Points ───────────────────────────────────────────

export interface IntegrationPoints {
  luminousProsperity: {
    mainSite: string;
    accountPortal: string;
    workshopBooking: string;
    coachDirectory: string;
    merchandiseStore: string;
  };
  healthKit: boolean;      // iOS HealthKit mindfulness minutes
  googleFit: boolean;      // Android Google Fit
  siri: boolean;           // Siri Shortcuts
  googleAssistant: boolean;
  alexa: boolean;
  widgets: {
    ios: boolean;
    android: boolean;
    macos: boolean;
    windows: boolean;
  };
  notifications: {
    dailyReflection: boolean;
    transitAlerts: boolean;
    moonPhaseAlerts: boolean;
    meditationReminders: boolean;
    communityActivity: boolean;
    newChapterAvailable: boolean;
  };
}

// ─── Default Configuration ────────────────────────────────────────

export const DEFAULT_ECOSYSTEM_CONFIG: EcosystemConfig = {
  api: {
    baseUrl: "https://api.luminouscosmic.app/v1",
    auth: {
      login: "/auth/login",
      register: "/auth/register",
      refreshToken: "/auth/refresh",
      socialAuth: "/auth/social",
    },
    user: {
      profile: "/user/profile",
      birthChart: "/user/chart",
      preferences: "/user/preferences",
      journalEntries: "/user/journal",
      meditationHistory: "/user/meditations",
      readingProgress: "/user/reading",
    },
    content: {
      chapters: "/content/chapters",
      dailyReflection: "/content/reflection",
      meditations: "/content/meditations",
      transits: "/content/transits",
      moonPhase: "/content/moon",
    },
    facilitator: {
      chat: "/facilitator/chat",
      voiceSession: "/facilitator/voice",
      conversationHistory: "/facilitator/history",
    },
    community: {
      forums: "/community/forums",
      events: "/community/events",
      coaches: "/community/coaches",
      groupSessions: "/community/groups",
      sharedCharts: "/community/charts",
    },
    ecosystem: {
      workshops: "/ecosystem/workshops",
      courses: "/ecosystem/courses",
      merchandise: "/ecosystem/shop",
      notifications: "/ecosystem/notifications",
    },
  },
  deepLinks: {
    scheme: "luminouscosmic",
    universalLinks: {
      domain: "luminouscosmic.app",
      paths: {
        chart: "/chart/:userId",
        reflection: "/reflection/:date",
        chapter: "/book/chapter/:id",
        meditation: "/meditation/:id",
        facilitator: "/guide",
        community: "/community/:threadId",
        share: "/share/:contentId",
      },
    },
    platformLinks: {
      ios: "https://apps.apple.com/app/luminous-cosmic",
      android: "https://play.google.com/store/apps/details?id=com.luminous.cosmic",
      web: "https://app.luminouscosmic.app",
      macos: "https://apps.apple.com/app/luminous-cosmic-mac",
      windows: "https://apps.microsoft.com/store/detail/luminous-cosmic",
    },
  },
  features: {
    natalChart: true,
    dailyReflections: true,
    guidedMeditations: true,
    chapterLibrary: true,
    facilitatorText: true,
    facilitatorVoice: true,
    community: true,
    audiobook: true,
    advancedTransits: true,
    coachMatching: true,
    liveWorkshops: true,
    chartComparisons: true,
    socialSharing: true,
    watchComplications: true,
  },
  tiers: SUBSCRIPTION_TIERS,
  social: {
    platforms: SOCIAL_PLATFORMS,
    shareableContent: [
      "natal_chart_image",
      "daily_reflection",
      "moon_phase",
      "transit_insight",
      "meditation_completion",
      "chapter_quote",
      "zodiac_season",
      "facilitator_insight",
      "chart_comparison",
    ],
    branding: SHARE_BRANDING,
  },
  integrations: {
    luminousProsperity: {
      mainSite: "https://luminousprosperity.com",
      accountPortal: "https://account.luminousprosperity.com",
      workshopBooking: "https://workshops.luminousprosperity.com",
      coachDirectory: "https://coaches.luminousprosperity.com",
      merchandiseStore: "https://shop.luminousprosperity.com",
    },
    healthKit: true,
    googleFit: true,
    siri: true,
    googleAssistant: true,
    alexa: true,
    widgets: { ios: true, android: true, macos: true, windows: true },
    notifications: {
      dailyReflection: true,
      transitAlerts: true,
      moonPhaseAlerts: true,
      meditationReminders: true,
      communityActivity: true,
      newChapterAvailable: true,
    },
  },
};
