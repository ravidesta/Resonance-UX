/**
 * Resonance UX Design Tokens
 *
 * Shared design token constants used across all platforms.
 * These define the visual language of the Resonance ecosystem:
 * calm, intentional, spacious digital experiences.
 */

// ---------------------------------------------------------------------------
// Colors
// ---------------------------------------------------------------------------

export const ColorPalette = {
  // Greens (primary brand family)
  green50: '#E8F0EC',
  green100: '#C5DDD0',
  green200: '#9FC8B1',
  green300: '#78B392',
  green400: '#5BA37B',
  green500: '#3E9364',
  green600: '#37855A',
  green700: '#2D734D',
  green800: '#122E21',
  green900: '#0A1C14',

  // Gold accent
  gold50: '#FBF5E8',
  gold100: '#F3E4C0',
  gold200: '#EBD297',
  gold300: '#E3C06E',
  gold400: '#D4AD5C',
  gold500: '#C5A059',
  gold600: '#B08D4A',
  gold700: '#96773C',
  gold800: '#7C612F',
  gold900: '#5A4621',

  // Neutrals
  white: '#FFFFFF',
  offWhite: '#FAFAF8',
  warmGray50: '#F5F5F0',
  warmGray100: '#E8E8E3',
  warmGray200: '#D4D4CE',
  warmGray300: '#B8B8B0',
  warmGray400: '#9A9A90',
  warmGray500: '#7C7C72',
  warmGray600: '#5C7065',
  warmGray700: '#4A5A50',
  warmGray800: '#3A4840',
  warmGray900: '#2A3430',
  black: '#000000',

  // Semantic
  error: '#C45D5D',
  errorLight: '#F2DEDE',
  warning: '#D4A84B',
  warningLight: '#FEF3CD',
  success: '#5BA37B',
  successLight: '#D4EDDA',
  info: '#5B8FA3',
  infoLight: '#D1ECF1',
} as const;

export const LightThemeColors = {
  base: '#FAFAF8',
  surface: '#FFFFFF',
  surfaceElevated: '#FFFFFF',
  surfaceOverlay: 'rgba(255, 255, 255, 0.85)',
  border: 'rgba(10, 28, 20, 0.08)',
  borderSubtle: 'rgba(10, 28, 20, 0.04)',
  text: '#0A1C14',
  textSecondary: '#122E21',
  textMuted: '#5C7065',
  textInverse: '#FAFAF8',
  accent: '#C5A059',
  accentHover: '#B08D4A',
  accentSubtle: 'rgba(197, 160, 89, 0.12)',
  primary: '#0A1C14',
  primaryHover: '#122E21',
  shadow: 'rgba(10, 28, 20, 0.06)',
  shadowMedium: 'rgba(10, 28, 20, 0.10)',
  shadowHeavy: 'rgba(10, 28, 20, 0.18)',
  glass: 'rgba(255, 255, 255, 0.65)',
  glassBorder: 'rgba(255, 255, 255, 0.25)',
  glassHighlight: 'rgba(255, 255, 255, 0.5)',
} as const;

export const DarkThemeColors = {
  base: '#05100B',
  surface: '#0A1C14',
  surfaceElevated: '#122E21',
  surfaceOverlay: 'rgba(10, 28, 20, 0.90)',
  border: 'rgba(250, 250, 248, 0.08)',
  borderSubtle: 'rgba(250, 250, 248, 0.04)',
  text: '#FAFAF8',
  textSecondary: '#E8F0EC',
  textMuted: '#9FC8B1',
  textInverse: '#0A1C14',
  accent: '#C5A059',
  accentHover: '#D4AD5C',
  accentSubtle: 'rgba(197, 160, 89, 0.15)',
  primary: '#FAFAF8',
  primaryHover: '#E8F0EC',
  shadow: 'rgba(0, 0, 0, 0.20)',
  shadowMedium: 'rgba(0, 0, 0, 0.35)',
  shadowHeavy: 'rgba(0, 0, 0, 0.50)',
  glass: 'rgba(10, 28, 20, 0.55)',
  glassBorder: 'rgba(250, 250, 248, 0.08)',
  glassHighlight: 'rgba(250, 250, 248, 0.05)',
} as const;

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

export const FontFamilies = {
  serif: "'Cormorant Garamond', 'Georgia', 'Times New Roman', serif",
  sans: "'Manrope', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
  mono: "'JetBrains Mono', 'Fira Code', 'SF Mono', monospace",
} as const;

export const FontWeights = {
  light: 300,
  regular: 400,
  medium: 500,
  semibold: 600,
  bold: 700,
} as const;

/** Font sizes in rem */
export const FontSizes = {
  xs: '0.75rem',
  sm: '0.875rem',
  base: '1rem',
  md: '1.125rem',
  lg: '1.25rem',
  xl: '1.5rem',
  '2xl': '1.875rem',
  '3xl': '2.25rem',
  '4xl': '3rem',
  '5xl': '3.75rem',
  '6xl': '4.5rem',
} as const;

export const LineHeights = {
  tight: 1.15,
  snug: 1.3,
  normal: 1.5,
  relaxed: 1.65,
  loose: 1.8,
} as const;

export const LetterSpacing = {
  tighter: '-0.04em',
  tight: '-0.02em',
  normal: '0em',
  wide: '0.02em',
  wider: '0.04em',
  widest: '0.08em',
} as const;

export const TypeScale = {
  displayLarge: {
    fontFamily: FontFamilies.serif,
    fontSize: FontSizes['6xl'],
    fontWeight: FontWeights.light,
    lineHeight: LineHeights.tight,
    letterSpacing: LetterSpacing.tighter,
  },
  displayMedium: {
    fontFamily: FontFamilies.serif,
    fontSize: FontSizes['5xl'],
    fontWeight: FontWeights.light,
    lineHeight: LineHeights.tight,
    letterSpacing: LetterSpacing.tight,
  },
  displaySmall: {
    fontFamily: FontFamilies.serif,
    fontSize: FontSizes['4xl'],
    fontWeight: FontWeights.regular,
    lineHeight: LineHeights.snug,
    letterSpacing: LetterSpacing.tight,
  },
  headingLarge: {
    fontFamily: FontFamilies.serif,
    fontSize: FontSizes['3xl'],
    fontWeight: FontWeights.regular,
    lineHeight: LineHeights.snug,
    letterSpacing: LetterSpacing.normal,
  },
  headingMedium: {
    fontFamily: FontFamilies.serif,
    fontSize: FontSizes['2xl'],
    fontWeight: FontWeights.medium,
    lineHeight: LineHeights.snug,
    letterSpacing: LetterSpacing.normal,
  },
  headingSmall: {
    fontFamily: FontFamilies.sans,
    fontSize: FontSizes.xl,
    fontWeight: FontWeights.semibold,
    lineHeight: LineHeights.normal,
    letterSpacing: LetterSpacing.normal,
  },
  bodyLarge: {
    fontFamily: FontFamilies.sans,
    fontSize: FontSizes.md,
    fontWeight: FontWeights.regular,
    lineHeight: LineHeights.relaxed,
    letterSpacing: LetterSpacing.normal,
  },
  bodyMedium: {
    fontFamily: FontFamilies.sans,
    fontSize: FontSizes.base,
    fontWeight: FontWeights.regular,
    lineHeight: LineHeights.relaxed,
    letterSpacing: LetterSpacing.normal,
  },
  bodySmall: {
    fontFamily: FontFamilies.sans,
    fontSize: FontSizes.sm,
    fontWeight: FontWeights.regular,
    lineHeight: LineHeights.normal,
    letterSpacing: LetterSpacing.wide,
  },
  caption: {
    fontFamily: FontFamilies.sans,
    fontSize: FontSizes.xs,
    fontWeight: FontWeights.medium,
    lineHeight: LineHeights.normal,
    letterSpacing: LetterSpacing.wider,
  },
  overline: {
    fontFamily: FontFamilies.sans,
    fontSize: FontSizes.xs,
    fontWeight: FontWeights.semibold,
    lineHeight: LineHeights.normal,
    letterSpacing: LetterSpacing.widest,
    textTransform: 'uppercase' as const,
  },
} as const;

// ---------------------------------------------------------------------------
// Spacing
// ---------------------------------------------------------------------------

/** Spacing scale in rem (base 4px / 0.25rem) */
export const Spacing = {
  px: '1px',
  '0': '0',
  '0.5': '0.125rem',
  '1': '0.25rem',
  '1.5': '0.375rem',
  '2': '0.5rem',
  '3': '0.75rem',
  '4': '1rem',
  '5': '1.25rem',
  '6': '1.5rem',
  '8': '2rem',
  '10': '2.5rem',
  '12': '3rem',
  '16': '4rem',
  '20': '5rem',
  '24': '6rem',
  '32': '8rem',
  '40': '10rem',
  '48': '12rem',
  '56': '14rem',
  '64': '16rem',
} as const;

// ---------------------------------------------------------------------------
// Border Radius
// ---------------------------------------------------------------------------

export const BorderRadius = {
  none: '0',
  sm: '0.25rem',
  md: '0.5rem',
  lg: '0.75rem',
  xl: '1rem',
  '2xl': '1.5rem',
  '3xl': '2rem',
  full: '9999px',
} as const;

// ---------------------------------------------------------------------------
// Elevation / Shadows
// ---------------------------------------------------------------------------

export const Elevation = {
  none: 'none',
  xs: '0 1px 2px rgba(10, 28, 20, 0.04)',
  sm: '0 2px 4px rgba(10, 28, 20, 0.06)',
  md: '0 4px 12px rgba(10, 28, 20, 0.08)',
  lg: '0 8px 24px rgba(10, 28, 20, 0.10)',
  xl: '0 16px 48px rgba(10, 28, 20, 0.14)',
  '2xl': '0 24px 64px rgba(10, 28, 20, 0.18)',
  inner: 'inset 0 1px 3px rgba(10, 28, 20, 0.06)',
  glassInset: 'inset 0 1px 1px rgba(255, 255, 255, 0.15)',
  glowGold: '0 0 20px rgba(197, 160, 89, 0.25)',
  glowGreen: '0 0 20px rgba(91, 163, 123, 0.20)',
} as const;

// ---------------------------------------------------------------------------
// Animation
// ---------------------------------------------------------------------------

export const Easing = {
  /** Standard material-like ease for most transitions */
  standard: 'cubic-bezier(0.4, 0.0, 0.2, 1)',
  /** Deceleration curve for elements entering the screen */
  enter: 'cubic-bezier(0.0, 0.0, 0.2, 1)',
  /** Acceleration curve for elements leaving the screen */
  exit: 'cubic-bezier(0.4, 0.0, 1, 1)',
  /** Calm, organic feeling for intentional micro-interactions */
  organic: 'cubic-bezier(0.22, 1, 0.36, 1)',
  /** Gentle spring-like overshoot */
  spring: 'cubic-bezier(0.34, 1.56, 0.64, 1)',
  /** Breathing rhythm for pulsing animations */
  breathe: 'cubic-bezier(0.45, 0.05, 0.55, 0.95)',
  /** Linear for progress bars */
  linear: 'linear',
} as const;

export const Duration = {
  instant: '50ms',
  fast: '150ms',
  normal: '250ms',
  slow: '400ms',
  slower: '600ms',
  deliberate: '800ms',
  calm: '1200ms',
  breathe: '4000ms',
  breatheSlow: '6000ms',
} as const;

// ---------------------------------------------------------------------------
// Breakpoints
// ---------------------------------------------------------------------------

export const Breakpoints = {
  xs: 0,
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  '2xl': 1536,
} as const;

export const MediaQueries = {
  sm: `@media (min-width: ${Breakpoints.sm}px)`,
  md: `@media (min-width: ${Breakpoints.md}px)`,
  lg: `@media (min-width: ${Breakpoints.lg}px)`,
  xl: `@media (min-width: ${Breakpoints.xl}px)`,
  '2xl': `@media (min-width: ${Breakpoints['2xl']}px)`,
  prefersReducedMotion: '@media (prefers-reduced-motion: reduce)',
  prefersDark: '@media (prefers-color-scheme: dark)',
  touch: '@media (hover: none) and (pointer: coarse)',
  hover: '@media (hover: hover) and (pointer: fine)',
} as const;

// ---------------------------------------------------------------------------
// Glass Morphism
// ---------------------------------------------------------------------------

export const GlassMorphism = {
  blur: {
    sm: 'blur(8px)',
    md: 'blur(16px)',
    lg: 'blur(24px)',
    xl: 'blur(40px)',
  },
  saturation: {
    subtle: 'saturate(1.1)',
    moderate: 'saturate(1.3)',
    vivid: 'saturate(1.8)',
  },
  backdrop: {
    light: 'blur(16px) saturate(1.3)',
    dark: 'blur(20px) saturate(1.5)',
    heavy: 'blur(40px) saturate(1.8)',
  },
} as const;

// ---------------------------------------------------------------------------
// Z-Index Scale
// ---------------------------------------------------------------------------

export const ZIndex = {
  behind: -1,
  base: 0,
  raised: 10,
  dropdown: 100,
  sticky: 200,
  overlay: 300,
  modal: 400,
  popover: 500,
  toast: 600,
  tooltip: 700,
  max: 9999,
} as const;

// ---------------------------------------------------------------------------
// Daily Flow Phases (Resonance philosophy)
// ---------------------------------------------------------------------------

export const FlowPhases = {
  dawn: { label: 'Dawn', hours: [5, 8], color: '#EBD297', icon: 'sunrise' },
  morning: { label: 'Morning Focus', hours: [8, 12], color: '#5BA37B', icon: 'sun' },
  midday: { label: 'Midday', hours: [12, 14], color: '#C5A059', icon: 'sun-bright' },
  afternoon: { label: 'Afternoon', hours: [14, 18], color: '#78B392', icon: 'cloud-sun' },
  evening: { label: 'Evening', hours: [18, 21], color: '#37855A', icon: 'moon-rising' },
  night: { label: 'Deep Rest', hours: [21, 5], color: '#0A1C14', icon: 'moon' },
} as const;

// ---------------------------------------------------------------------------
// JSON Export Utility
// ---------------------------------------------------------------------------

export function toJSON() {
  return {
    colors: { palette: ColorPalette, light: LightThemeColors, dark: DarkThemeColors },
    typography: { families: FontFamilies, weights: FontWeights, sizes: FontSizes, lineHeights: LineHeights, letterSpacing: LetterSpacing, scale: TypeScale },
    spacing: Spacing,
    borderRadius: BorderRadius,
    elevation: Elevation,
    animation: { easing: Easing, duration: Duration },
    breakpoints: Breakpoints,
    glassMorphism: GlassMorphism,
    zIndex: ZIndex,
    flowPhases: FlowPhases,
  };
}

export default {
  ColorPalette,
  LightThemeColors,
  DarkThemeColors,
  FontFamilies,
  FontWeights,
  FontSizes,
  LineHeights,
  LetterSpacing,
  TypeScale,
  Spacing,
  BorderRadius,
  Elevation,
  Easing,
  Duration,
  Breakpoints,
  MediaQueries,
  GlassMorphism,
  ZIndex,
  FlowPhases,
  toJSON,
};
