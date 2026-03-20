import {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  type ReactNode,
} from 'react';
import React from 'react';

export type ThemeMode = 'day' | 'night';

interface ThemeContextValue {
  mode: ThemeMode;
  toggle: () => void;
  setMode: (mode: ThemeMode) => void;
  isDark: boolean;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

const STORAGE_KEY = 'lca-theme-mode';

function getInitialMode(): ThemeMode {
  if (typeof window === 'undefined') return 'day';
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored === 'day' || stored === 'night') return stored;
  return window.matchMedia('(prefers-color-scheme: dark)').matches
    ? 'night'
    : 'day';
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [mode, setModeState] = useState<ThemeMode>(getInitialMode);

  const setMode = useCallback((newMode: ThemeMode) => {
    setModeState(newMode);
    localStorage.setItem(STORAGE_KEY, newMode);
    document.documentElement.setAttribute('data-theme', newMode);
  }, []);

  const toggle = useCallback(() => {
    setMode(mode === 'day' ? 'night' : 'day');
  }, [mode, setMode]);

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', mode);
  }, [mode]);

  const value: ThemeContextValue = {
    mode,
    toggle,
    setMode,
    isDark: mode === 'night',
  };

  return React.createElement(ThemeContext.Provider, { value }, children);
}

export function useTheme(): ThemeContextValue {
  const ctx = useContext(ThemeContext);
  if (!ctx) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return ctx;
}

export default useTheme;
