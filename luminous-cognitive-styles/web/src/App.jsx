import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  useMemo,
  useRef,
} from 'react';
import { HashRouter, Routes, Route, useLocation } from 'react-router-dom';
import { AnimatePresence, motion } from 'framer-motion';
import Navigation from './components/Navigation';
import LandingPage from './components/LandingPage';
import QuickProfile from './components/QuickProfile';
import FullAssessment from './components/FullAssessment';
import CognitiveSignature from './components/CognitiveSignature';
import ResonanceIntegration from './components/ResonanceIntegration';

/* ============================================================
   Contexts
   ============================================================ */

// --- Theme Context ---
const ThemeContext = createContext();

export const useTheme = () => {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider');
  return ctx;
};

const ThemeProvider = ({ children }) => {
  const [darkMode, setDarkMode] = useState(() => {
    try {
      const saved = localStorage.getItem('lcs-dark-mode');
      if (saved !== null) return JSON.parse(saved);
      return window.matchMedia?.('(prefers-color-scheme: dark)').matches || false;
    } catch {
      return false;
    }
  });

  const [readingMode, setReadingMode] = useState(() => {
    try {
      const saved = localStorage.getItem('lcs-reading-mode');
      return saved ? JSON.parse(saved) : false;
    } catch {
      return false;
    }
  });

  const [fontSize, setFontSize] = useState(() => {
    try {
      const saved = localStorage.getItem('lcs-font-size');
      return saved ? JSON.parse(saved) : 'medium';
    } catch {
      return 'medium';
    }
  });

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', darkMode ? 'dark' : 'light');
    localStorage.setItem('lcs-dark-mode', JSON.stringify(darkMode));
  }, [darkMode]);

  useEffect(() => {
    localStorage.setItem('lcs-reading-mode', JSON.stringify(readingMode));
  }, [readingMode]);

  useEffect(() => {
    localStorage.setItem('lcs-font-size', JSON.stringify(fontSize));
    const sizeMap = { small: '14px', medium: '16px', large: '18px', xlarge: '20px' };
    document.documentElement.style.fontSize = sizeMap[fontSize] || '16px';
  }, [fontSize]);

  const value = useMemo(() => ({
    darkMode, setDarkMode,
    readingMode, setReadingMode,
    fontSize, setFontSize,
  }), [darkMode, readingMode, fontSize]);

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
};

// --- User Context ---
const UserContext = createContext();

export const useUser = () => {
  const ctx = useContext(UserContext);
  if (!ctx) throw new Error('useUser must be used within UserProvider');
  return ctx;
};

const loadFromStorage = (key, fallback) => {
  try {
    const saved = localStorage.getItem(key);
    return saved ? JSON.parse(saved) : fallback;
  } catch {
    return fallback;
  }
};

const saveToStorage = (key, value) => {
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch {
    /* storage full or unavailable */
  }
};

const UserProvider = ({ children }) => {
  const [auth, setAuth] = useState(() =>
    loadFromStorage('lcs-auth', { isLoggedIn: false, user: null })
  );
  const [profileScores, setProfileScores] = useState(() =>
    loadFromStorage('lcs-profile-scores', null)
  );
  const [assessmentHistory, setAssessmentHistory] = useState(() =>
    loadFromStorage('lcs-assessment-history', [])
  );
  const [purchases, setPurchases] = useState(() =>
    loadFromStorage('lcs-purchases', { book: false, audiobook: false, coachingTier: 'free' })
  );
  const [notifications, setNotifications] = useState(() =>
    loadFromStorage('lcs-notifications', [])
  );
  const [audiobookState, setAudiobookState] = useState(() =>
    loadFromStorage('lcs-audiobook-state', {
      isPlaying: false,
      currentChapter: 0,
      currentTime: 0,
      duration: 0,
    })
  );
  const [cartItems, setCartItems] = useState(() =>
    loadFromStorage('lcs-cart', [])
  );

  // Persist on change
  useEffect(() => { saveToStorage('lcs-auth', auth); }, [auth]);
  useEffect(() => { saveToStorage('lcs-profile-scores', profileScores); }, [profileScores]);
  useEffect(() => { saveToStorage('lcs-assessment-history', assessmentHistory); }, [assessmentHistory]);
  useEffect(() => { saveToStorage('lcs-purchases', purchases); }, [purchases]);
  useEffect(() => { saveToStorage('lcs-notifications', notifications); }, [notifications]);
  useEffect(() => { saveToStorage('lcs-audiobook-state', audiobookState); }, [audiobookState]);
  useEffect(() => { saveToStorage('lcs-cart', cartItems); }, [cartItems]);

  const addNotification = useCallback((notification) => {
    setNotifications((prev) => [{
      id: Date.now(),
      title: notification.title,
      message: notification.message,
      read: false,
      timestamp: new Date().toISOString(),
      ...notification,
    }, ...prev].slice(0, 50));
  }, []);

  const markNotificationRead = useCallback((id) => {
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, read: true } : n))
    );
  }, []);

  const clearNotifications = useCallback(() => {
    setNotifications([]);
  }, []);

  const saveAssessment = useCallback((profile) => {
    setProfileScores(profile.scores);
    setAssessmentHistory((prev) => [{
      id: Date.now(),
      date: new Date().toISOString(),
      type: profile.type || 'quick',
      scores: profile.scores,
      fullProfile: profile,
    }, ...prev].slice(0, 20));
    addNotification({
      title: 'Assessment Complete',
      message: 'Your Cognitive Signature has been updated.',
    });
  }, [addNotification]);

  const addToCart = useCallback((item) => {
    setCartItems((prev) => {
      const exists = prev.find((i) => i.id === item.id);
      if (exists) return prev;
      return [...prev, item];
    });
  }, []);

  const removeFromCart = useCallback((itemId) => {
    setCartItems((prev) => prev.filter((i) => i.id !== itemId));
  }, []);

  const completePurchase = useCallback((items) => {
    items.forEach((item) => {
      if (item.type === 'book') {
        setPurchases((prev) => ({ ...prev, book: true }));
      } else if (item.type === 'audiobook') {
        setPurchases((prev) => ({ ...prev, audiobook: true }));
      } else if (item.type === 'coaching') {
        setPurchases((prev) => ({ ...prev, coachingTier: item.tier }));
      }
    });
    setCartItems([]);
    addNotification({
      title: 'Purchase Complete',
      message: 'Thank you! Your content is now available.',
    });
  }, [addNotification]);

  const value = useMemo(() => ({
    auth, setAuth,
    profileScores, setProfileScores,
    assessmentHistory, setAssessmentHistory,
    purchases, setPurchases,
    notifications, setNotifications,
    audiobookState, setAudiobookState,
    cartItems,
    addNotification,
    markNotificationRead,
    clearNotifications,
    saveAssessment,
    addToCart,
    removeFromCart,
    completePurchase,
  }), [
    auth, profileScores, assessmentHistory, purchases,
    notifications, audiobookState, cartItems,
    addNotification, markNotificationRead, clearNotifications,
    saveAssessment, addToCart, removeFromCart, completePurchase,
  ]);

  return <UserContext.Provider value={value}>{children}</UserContext.Provider>;
};

/* ============================================================
   Notification Toast System
   ============================================================ */

const NotificationToast = () => {
  const { notifications } = useUser();
  const [visibleToasts, setVisibleToasts] = useState([]);
  const prevLengthRef = useRef(notifications.length);

  useEffect(() => {
    if (notifications.length > prevLengthRef.current && notifications.length > 0) {
      const latest = notifications[0];
      setVisibleToasts((prev) => [...prev, latest].slice(-3));
      setTimeout(() => {
        setVisibleToasts((prev) => prev.filter((t) => t.id !== latest.id));
      }, 4000);
    }
    prevLengthRef.current = notifications.length;
  }, [notifications]);

  return (
    <div style={{
      position: 'fixed',
      bottom: '2rem',
      right: '2rem',
      zIndex: 2000,
      display: 'flex',
      flexDirection: 'column',
      gap: '0.75rem',
      pointerEvents: 'none',
    }}>
      <AnimatePresence>
        {visibleToasts.map((toast) => (
          <motion.div
            key={toast.id}
            initial={{ opacity: 0, y: 20, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.95 }}
            transition={{ duration: 0.3 }}
            style={{
              background: 'var(--color-surface-elevated)',
              border: '1px solid var(--color-border)',
              borderLeft: '4px solid var(--color-accent)',
              borderRadius: 'var(--radius-lg)',
              padding: '1rem 1.25rem',
              boxShadow: 'var(--shadow-lg)',
              minWidth: '280px',
              maxWidth: '380px',
              pointerEvents: 'auto',
            }}
          >
            <div style={{
              fontFamily: "'Manrope', sans-serif",
              fontWeight: 600,
              fontSize: '0.875rem',
              color: 'var(--color-text)',
              marginBottom: '0.25rem',
            }}>
              {toast.title}
            </div>
            <div style={{
              fontFamily: "'Manrope', sans-serif",
              fontSize: '0.8125rem',
              color: 'var(--color-text-muted)',
              lineHeight: 1.4,
            }}>
              {toast.message}
            </div>
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  );
};

/* ============================================================
   Mini Audio Player (persistent when audiobook playing)
   ============================================================ */

const MiniAudioPlayer = () => {
  const { audiobookState, setAudiobookState } = useUser();

  if (!audiobookState.isPlaying && audiobookState.currentTime === 0) return null;

  const chapters = [
    'Introduction', 'Perceptual Mode', 'Processing Rhythm',
    'Generative Orientation', 'Representational Channel',
    'Relational Orientation', 'Somatic Integration',
    'Complexity Tolerance', 'Your Cognitive Signature',
    'Growth & Development', 'Conclusion',
  ];

  const currentChapterName = chapters[audiobookState.currentChapter] || 'Chapter';
  const progress = audiobookState.duration > 0
    ? (audiobookState.currentTime / audiobookState.duration) * 100
    : 0;

  const formatTime = (seconds) => {
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${m}:${s.toString().padStart(2, '0')}`;
  };

  return (
    <motion.div
      initial={{ y: 80 }}
      animate={{ y: 0 }}
      exit={{ y: 80 }}
      style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        zIndex: 1500,
        height: '64px',
        background: 'var(--glass-bg)',
        backdropFilter: 'blur(20px)',
        WebkitBackdropFilter: 'blur(20px)',
        borderTop: '1px solid var(--glass-border)',
        display: 'flex',
        alignItems: 'center',
        padding: '0 1.5rem',
        gap: '1rem',
      }}
    >
      {/* Progress bar at top of player */}
      <div style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        height: '3px',
        background: 'var(--color-border)',
      }}>
        <div style={{
          width: `${progress}%`,
          height: '100%',
          background: 'linear-gradient(90deg, var(--color-gold-dark), var(--color-gold))',
          borderRadius: '0 2px 2px 0',
          transition: 'width 0.3s ease',
        }} />
      </div>

      {/* Play/Pause */}
      <button
        style={{
          width: 36,
          height: 36,
          borderRadius: '50%',
          background: 'var(--color-accent)',
          border: 'none',
          color: '#FFFFFF',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer',
          flexShrink: 0,
        }}
        onClick={() => setAudiobookState((prev) => ({
          ...prev,
          isPlaying: !prev.isPlaying,
        }))}
      >
        {audiobookState.isPlaying ? (
          <svg width="14" height="14" viewBox="0 0 14 14" fill="currentColor">
            <rect x="1" y="1" width="4" height="12" rx="1" />
            <rect x="9" y="1" width="4" height="12" rx="1" />
          </svg>
        ) : (
          <svg width="14" height="14" viewBox="0 0 14 14" fill="currentColor">
            <polygon points="2,0 14,7 2,14" />
          </svg>
        )}
      </button>

      {/* Chapter info */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontFamily: "'Manrope', sans-serif",
          fontSize: '0.8125rem',
          fontWeight: 600,
          color: 'var(--color-text)',
          whiteSpace: 'nowrap',
          overflow: 'hidden',
          textOverflow: 'ellipsis',
        }}>
          {currentChapterName}
        </div>
        <div style={{
          fontFamily: "'Manrope', sans-serif",
          fontSize: '0.75rem',
          color: 'var(--color-text-muted)',
        }}>
          {formatTime(audiobookState.currentTime)} / {formatTime(audiobookState.duration || 0)}
        </div>
      </div>

      {/* Close */}
      <button
        style={{
          width: 28,
          height: 28,
          borderRadius: '50%',
          background: 'transparent',
          border: 'none',
          color: 'var(--color-text-muted)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer',
        }}
        onClick={() => setAudiobookState({
          isPlaying: false,
          currentChapter: 0,
          currentTime: 0,
          duration: 0,
        })}
        aria-label="Close player"
      >
        <svg width="12" height="12" viewBox="0 0 12 12" fill="none" stroke="currentColor" strokeWidth="2">
          <line x1="1" y1="1" x2="11" y2="11" />
          <line x1="11" y1="1" x2="1" y2="11" />
        </svg>
      </button>
    </motion.div>
  );
};

/* ============================================================
   Placeholder Pages (for routes that don't have dedicated components yet)
   ============================================================ */

const PlaceholderPage = ({ title, description, icon }) => (
  <div style={{
    minHeight: '100vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    paddingTop: 'var(--nav-height)',
    position: 'relative',
    zIndex: 1,
  }}>
    <div style={{ textAlign: 'center', maxWidth: '480px', padding: '2rem' }}>
      <div style={{
        fontSize: '3rem',
        marginBottom: '1.5rem',
        animation: 'float 3s ease-in-out infinite',
      }}>
        {icon}
      </div>
      <h1 style={{
        fontFamily: "'Cormorant Garamond', serif",
        fontSize: 'clamp(2rem, 5vw, 3rem)',
        fontWeight: 600,
        color: 'var(--color-text)',
        marginBottom: '1rem',
        lineHeight: 1.1,
      }}>
        {title}
      </h1>
      <p style={{
        fontFamily: "'Manrope', sans-serif",
        fontSize: '1.0625rem',
        color: 'var(--color-text-secondary)',
        lineHeight: 1.6,
        marginBottom: '2rem',
      }}>
        {description}
      </p>
      <div style={{
        width: '60px',
        height: '2px',
        background: 'var(--color-accent)',
        margin: '0 auto',
        borderRadius: '1px',
      }} />
    </div>
  </div>
);

const EBookReaderPlaceholder = () => (
  <PlaceholderPage
    title="eBook Reader"
    description="Your premium reading experience is being crafted. The Luminous Cognitive Styles eBook will be available here with beautiful typography, annotations, and cross-references to your personal cognitive profile."
    icon="\uD83D\uDCD6"
  />
);

const AudiobookPlayerPlaceholder = () => (
  <PlaceholderPage
    title="Audiobook Player"
    description="An immersive listening experience with chapter navigation, playback speed control, bookmarks, and synchronized highlights that connect to your cognitive signature."
    icon="\uD83C\uDFA7"
  />
);

const CognitiveCoachPlaceholder = () => (
  <PlaceholderPage
    title="Cognitive Coach"
    description="Your personal AI-powered coaching experience. Get tailored exercises, reflective prompts, and developmental guidance based on your unique cognitive profile."
    icon="\uD83E\uDDD1\u200D\uD83C\uDFEB"
  />
);

const SocialSharePlaceholder = () => (
  <PlaceholderPage
    title="Share Your Signature"
    description="Create beautiful, shareable visualizations of your cognitive profile. Compare with friends, share on social media, or generate team compatibility reports."
    icon="\uD83D\uDD17"
  />
);

const JournalIntegrationPlaceholder = () => (
  <PlaceholderPage
    title="Journal Integration"
    description="Your cognitive insights flow seamlessly into your Resonance Journal. Track how your cognitive patterns show up in daily life and discover growth opportunities."
    icon="\uD83D\uDCD3"
  />
);

const ProfilePage = () => (
  <PlaceholderPage
    title="Your Profile"
    description="Your unified account across the Luminous Prosperity ecosystem. Manage your subscriptions, view your assessment history, and customize your experience."
    icon="\u2728"
  />
);

/* ============================================================
   Animated Routes
   ============================================================ */

const AnimatedRoutes = () => {
  const location = useLocation();

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={location.pathname}
        initial={{ opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -8 }}
        transition={{ duration: 0.3, ease: 'easeInOut' }}
        style={{ flex: 1 }}
      >
        <Routes location={location}>
          <Route path="/" element={<LandingPage />} />
          <Route path="/assess" element={<QuickProfile />} />
          <Route path="/assess/full" element={<FullAssessment />} />
          <Route path="/results" element={<CognitiveSignature />} />
          <Route path="/book" element={<EBookReaderPlaceholder />} />
          <Route path="/audiobook" element={<AudiobookPlayerPlaceholder />} />
          <Route path="/coach" element={<CognitiveCoachPlaceholder />} />
          <Route path="/share" element={<SocialSharePlaceholder />} />
          <Route path="/journal" element={<JournalIntegrationPlaceholder />} />
          <Route path="/profile" element={<ProfilePage />} />
          <Route path="/ecosystem" element={<ResonanceIntegration />} />
          <Route path="*" element={
            <PlaceholderPage
              title="Page Not Found"
              description="The page you're looking for doesn't exist. Perhaps it's waiting to be discovered, like an unexplored dimension of your cognitive landscape."
              icon="\uD83C\uDF0C"
            />
          } />
        </Routes>
      </motion.div>
    </AnimatePresence>
  );
};

/* ============================================================
   Blob Background
   ============================================================ */

const BlobBackground = () => (
  <div className="blob-bg" aria-hidden="true">
    <div className="blob" />
    <div className="blob" />
    <div className="blob" />
    <div className="blob" />
    <div className="blob" />
    <div className="blob" />
    <div className="blob" />
  </div>
);

/* ============================================================
   Main App Shell
   ============================================================ */

const AppContent = () => {
  const { darkMode, setDarkMode } = useTheme();
  const { notifications, cartItems, audiobookState } = useUser();

  return (
    <>
      <BlobBackground />
      <Navigation
        darkMode={darkMode}
        setDarkMode={setDarkMode}
        cartCount={cartItems.length}
        notifications={notifications}
      />
      <AnimatedRoutes />
      <AnimatePresence>
        {(audiobookState.isPlaying || audiobookState.currentTime > 0) && (
          <MiniAudioPlayer />
        )}
      </AnimatePresence>
      <NotificationToast />
    </>
  );
};

const App = () => {
  return (
    <HashRouter>
      <ThemeProvider>
        <UserProvider>
          <AppContent />
        </UserProvider>
      </ThemeProvider>
    </HashRouter>
  );
};

export default App;
