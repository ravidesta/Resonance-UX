/** Resonance UX Design System - Luminous Cosmic Architecture Theme Tokens */

export const colors = {
  /** Deep forest greens */
  forest: {
    900: '#0A1C14',
    800: '#122E21',
    700: '#1B402E',
    600: '#24523B',
    500: '#2D6449',
  },

  /** Gold accents */
  gold: {
    900: '#6B5420',
    800: '#9A7A3A',
    700: '#B8924A',
    600: '#C5A059',
    500: '#D4B36E',
    400: '#E6D0A1',
    300: '#F0E4C6',
    200: '#F7F0DF',
  },

  /** Cream base */
  cream: {
    100: '#FAFAF8',
    200: '#F5F4EE',
    300: '#EDECE4',
    400: '#E2E0D6',
  },

  /** Muted greens for text */
  sage: {
    700: '#3D5247',
    600: '#5C7065',
    500: '#6E8577',
    400: '#8A9C91',
    300: '#A8B8AD',
    200: '#C5D0C9',
  },

  /** Night mode */
  night: {
    900: '#030907',
    800: '#05100B',
    700: '#0A1C14',
    600: '#0F2A1E',
  },

  /** Semantic */
  error: '#B54B4B',
  success: '#5E8B5E',
  warning: '#C5A059',
  info: '#5B7B8A',
} as const;

export const typography = {
  fontFamily: {
    heading: "'Cormorant Garamond', 'Georgia', serif",
    body: "'Manrope', 'Helvetica Neue', sans-serif",
  },

  fontSize: {
    xs: '0.75rem',     // 12px
    sm: '0.875rem',    // 14px
    base: '1rem',      // 16px
    md: '1.125rem',    // 18px
    lg: '1.25rem',     // 20px
    xl: '1.5rem',      // 24px
    '2xl': '1.875rem', // 30px
    '3xl': '2.25rem',  // 36px
    '4xl': '3rem',     // 48px
    '5xl': '3.75rem',  // 60px
  },

  fontWeight: {
    light: 300,
    regular: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
  },

  lineHeight: {
    tight: 1.1,
    snug: 1.3,
    normal: 1.5,
    relaxed: 1.7,
    loose: 2,
  },

  letterSpacing: {
    tight: '-0.02em',
    normal: '0',
    wide: '0.05em',
    wider: '0.1em',
    widest: '0.2em',
  },
} as const;

export const spacing = {
  0: '0',
  1: '0.25rem',
  2: '0.5rem',
  3: '0.75rem',
  4: '1rem',
  5: '1.25rem',
  6: '1.5rem',
  8: '2rem',
  10: '2.5rem',
  12: '3rem',
  16: '4rem',
  20: '5rem',
  24: '6rem',
  32: '8rem',
} as const;

export const borderRadius = {
  sm: '0.375rem',
  md: '0.75rem',
  lg: '1rem',
  xl: '1.5rem',
  '2xl': '2rem',
  full: '9999px',
} as const;

export const shadows = {
  sm: '0 1px 3px rgba(154, 122, 58, 0.08)',
  md: '0 4px 12px rgba(154, 122, 58, 0.12)',
  lg: '0 8px 24px rgba(154, 122, 58, 0.12)',
  xl: '0 12px 40px rgba(154, 122, 58, 0.16)',
  glow: '0 0 20px rgba(197, 160, 89, 0.2)',
  inner: 'inset 0 2px 8px rgba(10, 28, 20, 0.08)',
} as const;

export const glassmorphism = {
  background: {
    light: 'rgba(250, 250, 248, 0.7)',
    dark: 'rgba(10, 28, 20, 0.6)',
  },
  backdropBlur: 'blur(12px)',
  border: {
    light: '1px solid rgba(138, 156, 145, 0.25)',
    dark: '1px solid rgba(138, 156, 145, 0.15)',
  },
} as const;

export const animation = {
  easing: {
    spring: 'cubic-bezier(0.34, 1.56, 0.64, 1)',
    smooth: 'cubic-bezier(0.4, 0, 0.2, 1)',
    decelerate: 'cubic-bezier(0, 0, 0.2, 1)',
    accelerate: 'cubic-bezier(0.4, 0, 1, 1)',
  },
  duration: {
    instant: '100ms',
    fast: '200ms',
    normal: '350ms',
    slow: '500ms',
    glacial: '800ms',
    breathing: '8s',
  },
} as const;

export const breakpoints = {
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
  '2xl': '1536px',
} as const;

export const zIndex = {
  background: -1,
  base: 0,
  elevated: 10,
  sticky: 20,
  overlay: 30,
  modal: 40,
  toast: 50,
  max: 100,
} as const;

const resonanceTheme = {
  colors,
  typography,
  spacing,
  borderRadius,
  shadows,
  glassmorphism,
  animation,
  breakpoints,
  zIndex,
} as const;

export type ResonanceTheme = typeof resonanceTheme;
export default resonanceTheme;
