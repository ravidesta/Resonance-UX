/**
 * Web Platform Configuration
 * Luminous Lifewheel — Progressive Web App
 *
 * PWA with offline support, service worker, responsive layout,
 * and integration with the landing page.
 */

export const WebConfig = {
  platform: 'web',

  // PWA manifest
  manifest: {
    name: 'Luminous Lifewheel',
    short_name: 'Lifewheel',
    description: 'Transformative living across eight dimensions',
    start_url: '/',
    display: 'standalone',
    background_color: '#FAFAF8',
    theme_color: '#C5A059',
    icons: [
      { src: '/icons/icon-192.png', sizes: '192x192', type: 'image/png' },
      { src: '/icons/icon-512.png', sizes: '512x512', type: 'image/png' },
    ],
  },

  // Service worker for offline support
  serviceWorker: {
    enabled: true,
    cacheStrategy: 'stale-while-revalidate',
    offlinePages: ['/', '/assessment', '/journal', '/writer'],
    cacheAssets: ['fonts', 'images', 'scripts'],
  },

  // Responsive breakpoints
  breakpoints: {
    mobile: 0,
    tablet: 768,
    desktop: 1024,
    wide: 1440,
  },

  // Layout adaptations
  layouts: {
    mobile: {
      navigation: 'bottomTabs',
      columns: 1,
    },
    tablet: {
      navigation: 'bottomTabs',
      columns: 2,
      sidePanel: false,
    },
    desktop: {
      navigation: 'sidebar',
      columns: 3,
      sidePanel: true,
    },
    wide: {
      navigation: 'sidebar',
      columns: 4,
      sidePanel: true,
      dashboardLayout: 'masonry',
    },
  },

  // Web-specific features
  features: {
    keyboardShortcuts: true,
    dragAndDrop: true,
    rightClickContextMenu: true,
    browserNotifications: true,
    fullscreenWriterMode: true,
    printableWorkbook: true,
    exportToPdf: true,
  },

  // Resonance UX web adaptations
  resonanceUX: {
    cssBackdropFilter: true,
    smoothScrolling: true,
    hoverAnimations: true,
    viewTransitions: true,  // Chrome View Transitions API
    glassMorphism: {
      blur: '16px',
      saturation: '110%',
    },
  },

  // SEO
  seo: {
    structuredData: true,
    openGraph: {
      title: 'Luminous Lifewheel',
      description: 'A sacred invitation to align with your highest potential across eight dimensions.',
      image: '/og-image.png',
    },
    sitemap: true,
  },
};

export default WebConfig;
