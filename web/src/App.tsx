/**
 * Resonance UX Web Application
 *
 * The main entry point for the Resonance web client.
 * Features tab-based navigation, Deep Rest theming, PWA support,
 * responsive layout, and cross-device sync initialization.
 */

import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  useMemo,
  type ReactNode,
} from 'react';
import {
  BrowserRouter,
  Routes,
  Route,
  NavLink,
  Navigate,
  useLocation,
} from 'react-router-dom';

import {
  type ResonanceTheme,
  type ThemeMode,
  createTheme,
  generateCSSCustomProperties,
  getCurrentFlowPhase,
  shouldEnableDeepRest,
  FlowPhases,
} from './theme/resonanceTheme';

import {
  GlassMorphismCard,
  IntentionalStatusBadge,
  EnergyLevelIndicator,
  SpaciousnessGauge,
  OrganicBlob,
  WaveformVisualizer,
} from './components/GlassMorphismCard';

import {
  IntentionalStatusType,
  EnergyLevel,
  FlowPhase,
  type DailyFlowState,
} from '../shared/types';

// ---------------------------------------------------------------------------
// Theme Context
// ---------------------------------------------------------------------------

interface ThemeContextValue {
  theme: ResonanceTheme;
  mode: ThemeMode;
  setMode: (mode: ThemeMode) => void;
  toggleDeepRest: () => void;
  autoDeepRest: boolean;
  setAutoDeepRest: (v: boolean) => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

export function useTheme(): ThemeContextValue {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider');
  return ctx;
}

// ---------------------------------------------------------------------------
// Sync Context
// ---------------------------------------------------------------------------

interface SyncContextValue {
  connected: boolean;
  deviceId: string;
  lastSynced: string | null;
  pendingChanges: number;
  sync: () => void;
}

const SyncContext = createContext<SyncContextValue>({
  connected: false,
  deviceId: '',
  lastSynced: null,
  pendingChanges: 0,
  sync: () => {},
});

export function useSync(): SyncContextValue {
  return useContext(SyncContext);
}

// ---------------------------------------------------------------------------
// ThemeProvider
// ---------------------------------------------------------------------------

function ThemeProvider({ children }: { children: ReactNode }) {
  const [mode, setMode] = useState<ThemeMode>(() => {
    const stored = localStorage.getItem('resonance-theme');
    if (stored === 'light' || stored === 'deep-rest') return stored;
    return 'light';
  });
  const [autoDeepRest, setAutoDeepRest] = useState(() => {
    return localStorage.getItem('resonance-auto-deep-rest') !== 'false';
  });
  const [reducedMotion, setReducedMotion] = useState(false);

  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    setReducedMotion(mq.matches);
    const handler = (e: MediaQueryListEvent) => setReducedMotion(e.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);

  // Auto switch to Deep Rest at night
  useEffect(() => {
    if (!autoDeepRest) return;
    const check = () => {
      if (shouldEnableDeepRest()) {
        setMode('deep-rest');
      }
    };
    check();
    const interval = setInterval(check, 60_000);
    return () => clearInterval(interval);
  }, [autoDeepRest]);

  useEffect(() => {
    localStorage.setItem('resonance-theme', mode);
  }, [mode]);

  useEffect(() => {
    localStorage.setItem('resonance-auto-deep-rest', String(autoDeepRest));
  }, [autoDeepRest]);

  const theme = useMemo(() => createTheme(mode, { reducedMotion }), [mode, reducedMotion]);

  // Inject CSS custom properties
  useEffect(() => {
    const id = 'resonance-theme-vars';
    let styleEl = document.getElementById(id) as HTMLStyleElement | null;
    if (!styleEl) {
      styleEl = document.createElement('style');
      styleEl.id = id;
      document.head.appendChild(styleEl);
    }
    styleEl.textContent = generateCSSCustomProperties(theme);

    // Also set data attribute for Tailwind dark mode or external CSS
    document.documentElement.setAttribute('data-theme', mode);
    document.documentElement.style.colorScheme = mode === 'deep-rest' ? 'dark' : 'light';
  }, [theme, mode]);

  const toggleDeepRest = useCallback(() => {
    setMode((prev) => (prev === 'deep-rest' ? 'light' : 'deep-rest'));
  }, []);

  const value = useMemo(
    () => ({ theme, mode, setMode, toggleDeepRest, autoDeepRest, setAutoDeepRest }),
    [theme, mode, toggleDeepRest, autoDeepRest],
  );

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

// ---------------------------------------------------------------------------
// SyncProvider (cross-device sync initialization)
// ---------------------------------------------------------------------------

function getOrCreateDeviceId(): string {
  const key = 'resonance-device-id';
  let id = localStorage.getItem(key);
  if (!id) {
    id = `web-${crypto.randomUUID()}`;
    localStorage.setItem(key, id);
  }
  return id;
}

function SyncProvider({ children }: { children: ReactNode }) {
  const [connected, setConnected] = useState(false);
  const [lastSynced, setLastSynced] = useState<string | null>(null);
  const [pendingChanges, setPendingChanges] = useState(0);
  const deviceId = useMemo(getOrCreateDeviceId, []);
  const wsRef = React.useRef<WebSocket | null>(null);

  const connect = useCallback(() => {
    const protocol = window.location.protocol === 'https:' ? 'wss' : 'ws';
    const host = import.meta.env.VITE_WS_URL || `${protocol}://${window.location.host}`;
    const ws = new WebSocket(`${host}/ws`);

    ws.onopen = () => {
      setConnected(true);
      // Authenticate
      const token = localStorage.getItem('resonance-token');
      if (token) {
        ws.send(JSON.stringify({ type: 'authenticate', payload: { token, deviceId } }));
      }
    };

    ws.onmessage = (event) => {
      try {
        const msg = JSON.parse(event.data);
        switch (msg.type) {
          case 'authenticated':
            setLastSynced(new Date().toISOString());
            break;
          case 'sync-update':
            setPendingChanges((c) => Math.max(0, c - 1));
            break;
          case 'pong':
            break;
          default:
            break;
        }
      } catch {
        // ignore malformed messages
      }
    };

    ws.onclose = () => {
      setConnected(false);
      // Reconnect with backoff
      setTimeout(connect, 3000);
    };

    ws.onerror = () => ws.close();
    wsRef.current = ws;
  }, [deviceId]);

  useEffect(() => {
    connect();
    return () => wsRef.current?.close();
  }, [connect]);

  // Periodic ping
  useEffect(() => {
    const interval = setInterval(() => {
      if (wsRef.current?.readyState === WebSocket.OPEN) {
        wsRef.current.send(JSON.stringify({ type: 'ping' }));
      }
    }, 30_000);
    return () => clearInterval(interval);
  }, []);

  const sync = useCallback(() => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({ type: 'sync-pull', payload: { deviceId, since: lastSynced } }));
    }
  }, [deviceId, lastSynced]);

  const value = useMemo(
    () => ({ connected, deviceId, lastSynced, pendingChanges, sync }),
    [connected, deviceId, lastSynced, pendingChanges, sync],
  );

  return <SyncContext.Provider value={value}>{children}</SyncContext.Provider>;
}

// ---------------------------------------------------------------------------
// Navigation
// ---------------------------------------------------------------------------

interface TabConfig {
  path: string;
  label: string;
  icon: string;
}

const TABS: TabConfig[] = [
  { path: '/flow', label: 'Flow', icon: '\u2600' },
  { path: '/focus', label: 'Focus', icon: '\u25CE' },
  { path: '/create', label: 'Create', icon: '\u270E' },
  { path: '/letters', label: 'Letters', icon: '\u2709' },
  { path: '/canvas', label: 'Canvas', icon: '\u25A1' },
];

function TabBar() {
  const { theme, mode, toggleDeepRest } = useTheme();
  const { connected } = useSync();
  const location = useLocation();

  return (
    <nav
      style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        zIndex: 200,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-around',
        height: 64,
        paddingBottom: 'env(safe-area-inset-bottom, 0px)',
        background: theme.colors.glass,
        backdropFilter: theme.glass.backdrop.light,
        WebkitBackdropFilter: theme.glass.backdrop.light,
        borderTop: `1px solid ${theme.colors.glassBorder}`,
        boxShadow: '0 -2px 12px rgba(10,28,20,0.04)',
      }}
    >
      {TABS.map((tab) => {
        const isActive = location.pathname.startsWith(tab.path);
        return (
          <NavLink
            key={tab.path}
            to={tab.path}
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 2,
              textDecoration: 'none',
              color: isActive ? theme.colors.accent : theme.colors.textMuted,
              transition: 'color 0.25s ease',
              padding: '8px 12px',
              minWidth: 56,
            }}
          >
            <span style={{ fontSize: 20 }}>{tab.icon}</span>
            <span
              style={{
                fontSize: '0.65rem',
                fontWeight: isActive ? 600 : 500,
                letterSpacing: '0.04em',
                textTransform: 'uppercase',
                fontFamily: theme.typography.families.sans,
              }}
            >
              {tab.label}
            </span>
          </NavLink>
        );
      })}

      {/* Deep Rest toggle (small moon icon) */}
      <button
        onClick={toggleDeepRest}
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 2,
          background: 'none',
          border: 'none',
          cursor: 'pointer',
          color: mode === 'deep-rest' ? theme.colors.accent : theme.colors.textMuted,
          padding: '8px 12px',
          minWidth: 48,
        }}
        title={mode === 'deep-rest' ? 'Switch to Light' : 'Enable Deep Rest'}
        aria-label="Toggle Deep Rest mode"
      >
        <span style={{ fontSize: 18 }}>{mode === 'deep-rest' ? '\u263E' : '\u263D'}</span>
        <span style={{ fontSize: '0.6rem', fontWeight: 500, letterSpacing: '0.04em' }}>
          {mode === 'deep-rest' ? 'Rest' : 'Day'}
        </span>
      </button>

      {/* Sync indicator */}
      <div
        style={{
          position: 'absolute',
          top: 4,
          right: 12,
          width: 6,
          height: 6,
          borderRadius: '50%',
          background: connected ? '#5BA37B' : '#C45D5D',
        }}
        title={connected ? 'Synced' : 'Offline'}
      />
    </nav>
  );
}

// ---------------------------------------------------------------------------
// Desktop Sidebar (shown on lg+)
// ---------------------------------------------------------------------------

function Sidebar() {
  const { theme, mode, toggleDeepRest } = useTheme();
  const { connected, lastSynced } = useSync();
  const location = useLocation();

  return (
    <aside
      style={{
        width: 220,
        flexShrink: 0,
        height: '100vh',
        position: 'sticky',
        top: 0,
        display: 'flex',
        flexDirection: 'column',
        padding: '32px 16px 24px',
        background: theme.colors.surface,
        borderRight: `1px solid ${theme.colors.border}`,
      }}
    >
      {/* Brand */}
      <div style={{ marginBottom: 40, paddingLeft: 8 }}>
        <h1
          style={{
            fontFamily: theme.typography.families.serif,
            fontSize: '1.5rem',
            fontWeight: 300,
            color: theme.colors.text,
            letterSpacing: '-0.02em',
            margin: 0,
          }}
        >
          Resonance
        </h1>
        <span
          style={{
            fontFamily: theme.typography.families.sans,
            fontSize: '0.65rem',
            fontWeight: 600,
            letterSpacing: '0.08em',
            textTransform: 'uppercase',
            color: theme.colors.textMuted,
          }}
        >
          Intentional Living
        </span>
      </div>

      {/* Nav items */}
      <nav style={{ display: 'flex', flexDirection: 'column', gap: 4, flex: 1 }}>
        {TABS.map((tab) => {
          const isActive = location.pathname.startsWith(tab.path);
          return (
            <NavLink
              key={tab.path}
              to={tab.path}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 12,
                padding: '10px 12px',
                borderRadius: 12,
                textDecoration: 'none',
                fontFamily: theme.typography.families.sans,
                fontSize: '0.9rem',
                fontWeight: isActive ? 600 : 400,
                color: isActive ? theme.colors.accent : theme.colors.textSecondary,
                background: isActive ? theme.colors.accentSubtle : 'transparent',
                transition: 'all 0.25s ease',
              }}
            >
              <span style={{ fontSize: 16, width: 24, textAlign: 'center' }}>{tab.icon}</span>
              {tab.label}
            </NavLink>
          );
        })}
      </nav>

      {/* Footer */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, paddingLeft: 8 }}>
        <button
          onClick={toggleDeepRest}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            background: 'none',
            border: 'none',
            cursor: 'pointer',
            fontFamily: theme.typography.families.sans,
            fontSize: '0.8rem',
            color: theme.colors.textMuted,
            padding: '4px 0',
          }}
        >
          {mode === 'deep-rest' ? '\u263E' : '\u2600'}{' '}
          {mode === 'deep-rest' ? 'Deep Rest' : 'Light Mode'}
        </button>

        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 6,
            fontSize: '0.7rem',
            color: theme.colors.textMuted,
            fontFamily: theme.typography.families.sans,
          }}
        >
          <span
            style={{
              width: 6,
              height: 6,
              borderRadius: '50%',
              background: connected ? '#5BA37B' : '#C45D5D',
              display: 'inline-block',
            }}
          />
          {connected ? 'Synced' : 'Offline'}
          {lastSynced && (
            <span style={{ opacity: 0.6, marginLeft: 4 }}>
              {new Date(lastSynced).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
            </span>
          )}
        </div>
      </div>
    </aside>
  );
}

// ---------------------------------------------------------------------------
// Page Shells (placeholder layouts for each tab)
// ---------------------------------------------------------------------------

function FlowPage() {
  const { theme } = useTheme();
  const phase = getCurrentFlowPhase();
  const phaseConfig = FlowPhases[phase];

  const [flowState] = useState<DailyFlowState>({
    date: new Date().toISOString().slice(0, 10),
    currentPhase: FlowPhase.MorningFocus,
    currentEnergy: EnergyLevel.High,
    spaciousness: 62,
    tasks: [],
    completedCount: 3,
    totalCount: 7,
  });

  return (
    <div style={{ padding: '32px 24px', maxWidth: 720, margin: '0 auto' }}>
      {/* Background blob */}
      <div style={{ position: 'fixed', top: -80, right: -60, zIndex: -1, opacity: 0.4 }}>
        <OrganicBlob size={320} color={phaseConfig.color} speed="slow" />
      </div>

      <header style={{ marginBottom: 40 }}>
        <p
          style={{
            fontFamily: theme.typography.families.sans,
            fontSize: '0.7rem',
            fontWeight: 600,
            letterSpacing: '0.08em',
            textTransform: 'uppercase',
            color: theme.colors.textMuted,
            marginBottom: 8,
          }}
        >
          {phaseConfig.label} Phase
        </p>
        <h2
          style={{
            fontFamily: theme.typography.families.serif,
            fontSize: '2.25rem',
            fontWeight: 300,
            color: theme.colors.text,
            margin: 0,
            lineHeight: 1.15,
          }}
        >
          Daily Flow
        </h2>
      </header>

      {/* Status + Energy */}
      <GlassMorphismCard padding="lg" style={{ marginBottom: 24 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 24 }}>
          <div>
            <IntentionalStatusBadge status={IntentionalStatusType.Focused} showLabel size="lg" />
            <div style={{ marginTop: 16 }}>
              <EnergyLevelIndicator level={flowState.currentEnergy} showLabel size="md" />
            </div>
          </div>
          <SpaciousnessGauge value={flowState.spaciousness} size={100} />
        </div>
      </GlassMorphismCard>

      {/* Phase timeline */}
      <GlassMorphismCard padding="md" style={{ marginBottom: 24 }}>
        <h3
          style={{
            fontFamily: theme.typography.families.sans,
            fontSize: '0.8rem',
            fontWeight: 600,
            letterSpacing: '0.06em',
            textTransform: 'uppercase',
            color: theme.colors.textMuted,
            marginBottom: 16,
            margin: '0 0 16px',
          }}
        >
          Today&apos;s Rhythm
        </h3>
        <div style={{ display: 'flex', gap: 4 }}>
          {Object.entries(FlowPhases).map(([key, p]) => (
            <div
              key={key}
              style={{
                flex: 1,
                height: 6,
                borderRadius: 3,
                background: key === phase ? p.color : theme.colors.border,
                transition: 'background 0.6s ease',
              }}
              title={p.label}
            />
          ))}
        </div>
      </GlassMorphismCard>

      {/* Tasks summary */}
      <GlassMorphismCard padding="md">
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'baseline',
          }}
        >
          <span
            style={{
              fontFamily: theme.typography.families.serif,
              fontSize: '1.5rem',
              fontWeight: 400,
              color: theme.colors.text,
            }}
          >
            {flowState.completedCount}
            <span style={{ color: theme.colors.textMuted, fontSize: '1rem' }}>
              /{flowState.totalCount}
            </span>
          </span>
          <span
            style={{
              fontFamily: theme.typography.families.sans,
              fontSize: '0.75rem',
              color: theme.colors.textMuted,
            }}
          >
            tasks completed
          </span>
        </div>
      </GlassMorphismCard>
    </div>
  );
}

function FocusPage() {
  const { theme } = useTheme();
  return (
    <div style={{ padding: '32px 24px', maxWidth: 720, margin: '0 auto' }}>
      <h2
        style={{
          fontFamily: theme.typography.families.serif,
          fontSize: '2.25rem',
          fontWeight: 300,
          color: theme.colors.text,
          marginBottom: 32,
        }}
      >
        Focus
      </h2>
      <GlassMorphismCard padding="lg">
        <p style={{ color: theme.colors.textSecondary, fontFamily: theme.typography.families.sans, lineHeight: 1.6 }}>
          Your tasks, organized by energy level and domain. Only what matters, when it matters.
        </p>
        <div style={{ marginTop: 24, display: 'flex', gap: 16 }}>
          {[EnergyLevel.Peak, EnergyLevel.High, EnergyLevel.Moderate, EnergyLevel.Low, EnergyLevel.Rest].map((level) => (
            <EnergyLevelIndicator key={level} level={level} size="sm" />
          ))}
        </div>
      </GlassMorphismCard>
    </div>
  );
}

function CreatePage() {
  const { theme } = useTheme();
  const sampleWaveform = useMemo(
    () => Array.from({ length: 64 }, () => 0.1 + Math.random() * 0.8),
    [],
  );

  return (
    <div style={{ padding: '32px 24px', maxWidth: 720, margin: '0 auto' }}>
      <h2
        style={{
          fontFamily: theme.typography.families.serif,
          fontSize: '2.25rem',
          fontWeight: 300,
          color: theme.colors.text,
          marginBottom: 32,
        }}
      >
        Create
      </h2>
      <GlassMorphismCard padding="lg" style={{ marginBottom: 24 }}>
        <p style={{ color: theme.colors.textSecondary, fontFamily: theme.typography.families.sans, lineHeight: 1.6, margin: 0 }}>
          A calm space for writing and creation. Luminize AI refines your prose while preserving your voice.
        </p>
      </GlassMorphismCard>
      <GlassMorphismCard padding="md">
        <p
          style={{
            fontFamily: theme.typography.families.sans,
            fontSize: '0.75rem',
            fontWeight: 600,
            letterSpacing: '0.06em',
            textTransform: 'uppercase',
            color: theme.colors.textMuted,
            marginBottom: 12,
            margin: '0 0 12px',
          }}
        >
          Voice Note Preview
        </p>
        <WaveformVisualizer data={sampleWaveform} width={320} height={40} progress={0.4} />
      </GlassMorphismCard>
    </div>
  );
}

function LettersPage() {
  const { theme } = useTheme();
  return (
    <div style={{ padding: '32px 24px', maxWidth: 720, margin: '0 auto' }}>
      <h2
        style={{
          fontFamily: theme.typography.families.serif,
          fontSize: '2.25rem',
          fontWeight: 300,
          color: theme.colors.text,
          marginBottom: 32,
        }}
      >
        Letters
      </h2>
      <GlassMorphismCard padding="lg">
        <p style={{ color: theme.colors.textSecondary, fontFamily: theme.typography.families.sans, lineHeight: 1.6, margin: 0 }}>
          Intentional communication. Messages, voice letters, and video calls designed around calm exchange rather than urgency.
        </p>
      </GlassMorphismCard>
    </div>
  );
}

function CanvasPage() {
  const { theme } = useTheme();
  return (
    <div style={{ padding: '32px 24px', maxWidth: 720, margin: '0 auto' }}>
      <h2
        style={{
          fontFamily: theme.typography.families.serif,
          fontSize: '2.25rem',
          fontWeight: 300,
          color: theme.colors.text,
          marginBottom: 32,
        }}
      >
        Canvas
      </h2>
      <GlassMorphismCard padding="lg">
        <p style={{ color: theme.colors.textSecondary, fontFamily: theme.typography.families.sans, lineHeight: 1.6, margin: 0 }}>
          Your document workspace. Long-form writing, notes, and compositions with distraction-free editing and Luminize refinement.
        </p>
      </GlassMorphismCard>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Responsive Layout Shell
// ---------------------------------------------------------------------------

function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() => window.matchMedia(query).matches);
  useEffect(() => {
    const mq = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    mq.addEventListener('change', handler);
    setMatches(mq.matches);
    return () => mq.removeEventListener('change', handler);
  }, [query]);
  return matches;
}

function AppLayout() {
  const isDesktop = useMediaQuery('(min-width: 1024px)');
  const { theme } = useTheme();

  return (
    <div
      style={{
        display: 'flex',
        minHeight: '100vh',
        background: theme.colors.base,
        color: theme.colors.text,
        fontFamily: theme.typography.families.sans,
        transition: 'background 0.6s ease, color 0.4s ease',
      }}
    >
      {isDesktop && <Sidebar />}

      <main
        style={{
          flex: 1,
          paddingBottom: isDesktop ? 0 : 80, // space for bottom tab bar
          minHeight: '100vh',
          position: 'relative',
        }}
      >
        <Routes>
          <Route path="/flow" element={<FlowPage />} />
          <Route path="/focus" element={<FocusPage />} />
          <Route path="/create" element={<CreatePage />} />
          <Route path="/letters" element={<LettersPage />} />
          <Route path="/canvas" element={<CanvasPage />} />
          <Route path="*" element={<Navigate to="/flow" replace />} />
        </Routes>
      </main>

      {!isDesktop && <TabBar />}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Service Worker Registration
// ---------------------------------------------------------------------------

async function registerServiceWorker() {
  if ('serviceWorker' in navigator && import.meta.env.PROD) {
    try {
      const registration = await navigator.serviceWorker.register('/sw.js', { scope: '/' });
      registration.addEventListener('updatefound', () => {
        const newWorker = registration.installing;
        if (newWorker) {
          newWorker.addEventListener('statechange', () => {
            if (newWorker.state === 'activated') {
              console.info('[Resonance] New service worker activated. Refresh for updates.');
            }
          });
        }
      });
      console.info('[Resonance] Service worker registered.');
    } catch (err) {
      console.warn('[Resonance] Service worker registration failed:', err);
    }
  }
}

// ---------------------------------------------------------------------------
// Root App
// ---------------------------------------------------------------------------

export default function App() {
  useEffect(() => {
    registerServiceWorker();
  }, []);

  return (
    <BrowserRouter>
      <ThemeProvider>
        <SyncProvider>
          <AppLayout />
        </SyncProvider>
      </ThemeProvider>
    </BrowserRouter>
  );
}
