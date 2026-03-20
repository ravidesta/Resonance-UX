/**
 * Resonance Theme System
 *
 * Provides a typed theme object, React context, CSS custom properties generation,
 * and utility hooks for the Resonance web application.
 */

import {
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
  GlassMorphism,
  ZIndex,
  FlowPhases,
} from '../../shared/constants/designTokens';

// Re-export for convenience
export {
  ColorPalette,
  FontFamilies,
  FontWeights,
  FontSizes,
  Spacing,
  BorderRadius,
  Elevation,
  Easing,
  Duration,
  Breakpoints,
  GlassMorphism,
  ZIndex,
  FlowPhases,
};

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type ThemeMode = 'light' | 'deep-rest';

export interface ThemeColorTokens {
  base: string;
  surface: string;
  surfaceElevated: string;
  surfaceOverlay: string;
  border: string;
  borderSubtle: string;
  text: string;
  textSecondary: string;
  textMuted: string;
  textInverse: string;
  accent: string;
  accentHover: string;
  accentSubtle: string;
  primary: string;
  primaryHover: string;
  shadow: string;
  shadowMedium: string;
  shadowHeavy: string;
  glass: string;
  glassBorder: string;
  glassHighlight: string;
}

export interface ResonanceTheme {
  mode: ThemeMode;
  colors: ThemeColorTokens & { palette: typeof ColorPalette };
  typography: {
    families: typeof FontFamilies;
    weights: typeof FontWeights;
    sizes: typeof FontSizes;
    lineHeights: typeof LineHeights;
    letterSpacing: typeof LetterSpacing;
    scale: typeof TypeScale;
  };
  spacing: typeof Spacing;
  borderRadius: typeof BorderRadius;
  elevation: typeof Elevation;
  animation: {
    easing: typeof Easing;
    duration: typeof Duration;
    reducedMotion: boolean;
  };
  breakpoints: typeof Breakpoints;
  glass: typeof GlassMorphism;
  zIndex: typeof ZIndex;
  flow: typeof FlowPhases;
}

// ---------------------------------------------------------------------------
// Theme Factory
// ---------------------------------------------------------------------------

export function createTheme(
  mode: ThemeMode,
  options: { reducedMotion?: boolean } = {},
): ResonanceTheme {
  const colorTokens: ThemeColorTokens =
    mode === 'deep-rest'
      ? { ...DarkThemeColors }
      : { ...LightThemeColors };

  return {
    mode,
    colors: {
      ...colorTokens,
      palette: ColorPalette,
    },
    typography: {
      families: FontFamilies,
      weights: FontWeights,
      sizes: FontSizes,
      lineHeights: LineHeights,
      letterSpacing: LetterSpacing,
      scale: TypeScale,
    },
    spacing: Spacing,
    borderRadius: BorderRadius,
    elevation: Elevation,
    animation: {
      easing: Easing,
      duration: Duration,
      reducedMotion: options.reducedMotion ?? false,
    },
    breakpoints: Breakpoints,
    glass: GlassMorphism,
    zIndex: ZIndex,
    flow: FlowPhases,
  };
}

// ---------------------------------------------------------------------------
// CSS Custom Properties Generator
// ---------------------------------------------------------------------------

function kebab(str: string): string {
  return str.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
}

function flattenTokens(
  obj: Record<string, unknown>,
  prefix: string,
): Record<string, string> {
  const result: Record<string, string> = {};

  for (const [key, value] of Object.entries(obj)) {
    const prop = `--${prefix}-${kebab(key)}`;
    if (typeof value === 'string') {
      result[prop] = value;
    } else if (typeof value === 'number') {
      result[prop] = String(value);
    } else if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      Object.assign(result, flattenTokens(value as Record<string, unknown>, `${prefix}-${kebab(key)}`));
    }
  }

  return result;
}

export function generateCSSCustomProperties(theme: ResonanceTheme): string {
  const tokens: Record<string, string> = {};

  // Colors
  Object.assign(tokens, flattenTokens(
    { ...theme.colors, palette: undefined } as unknown as Record<string, unknown>,
    'color',
  ));
  Object.assign(tokens, flattenTokens(theme.colors.palette as unknown as Record<string, unknown>, 'palette'));

  // Typography families
  tokens['--font-serif'] = theme.typography.families.serif;
  tokens['--font-sans'] = theme.typography.families.sans;
  tokens['--font-mono'] = theme.typography.families.mono;

  // Typography sizes
  Object.assign(tokens, flattenTokens(theme.typography.sizes as unknown as Record<string, unknown>, 'text'));

  // Spacing
  Object.assign(tokens, flattenTokens(theme.spacing as unknown as Record<string, unknown>, 'space'));

  // Border radius
  Object.assign(tokens, flattenTokens(theme.borderRadius as unknown as Record<string, unknown>, 'radius'));

  // Elevation
  Object.assign(tokens, flattenTokens(theme.elevation as unknown as Record<string, unknown>, 'shadow'));

  // Animation
  Object.assign(tokens, flattenTokens(theme.animation.easing as unknown as Record<string, unknown>, 'ease'));
  Object.assign(tokens, flattenTokens(theme.animation.duration as unknown as Record<string, unknown>, 'duration'));

  // Glass
  Object.assign(tokens, flattenTokens(theme.glass.blur as unknown as Record<string, unknown>, 'glass-blur'));
  Object.assign(tokens, flattenTokens(theme.glass.backdrop as unknown as Record<string, unknown>, 'glass-backdrop'));

  // Z-index
  Object.assign(tokens, flattenTokens(theme.zIndex as unknown as Record<string, unknown>, 'z'));

  const lines = Object.entries(tokens)
    .filter(([, v]) => v !== undefined && v !== 'undefined')
    .map(([prop, value]) => `  ${prop}: ${value};`);

  return `:root {\n${lines.join('\n')}\n}`;
}

// ---------------------------------------------------------------------------
// CSS-in-JS Helpers
// ---------------------------------------------------------------------------

export function themeVar(name: string): string {
  return `var(--${name})`;
}

export function colorVar(name: keyof ThemeColorTokens): string {
  return `var(--color-${kebab(name)})`;
}

export function spaceVar(size: keyof typeof Spacing): string {
  return `var(--space-${size})`;
}

// ---------------------------------------------------------------------------
// Responsive Utilities
// ---------------------------------------------------------------------------

export function mediaUp(breakpoint: keyof typeof Breakpoints): string {
  return `@media (min-width: ${Breakpoints[breakpoint]}px)`;
}

export function mediaDown(breakpoint: keyof typeof Breakpoints): string {
  return `@media (max-width: ${Breakpoints[breakpoint] - 1}px)`;
}

export function mediaBetween(
  min: keyof typeof Breakpoints,
  max: keyof typeof Breakpoints,
): string {
  return `@media (min-width: ${Breakpoints[min]}px) and (max-width: ${Breakpoints[max] - 1}px)`;
}

// ---------------------------------------------------------------------------
// Glass Morphism Style Builder
// ---------------------------------------------------------------------------

export interface GlassStyleOptions {
  blur?: 'sm' | 'md' | 'lg' | 'xl';
  opacity?: number;
  border?: boolean;
  insetHighlight?: boolean;
  saturation?: 'subtle' | 'moderate' | 'vivid';
}

export function buildGlassStyle(
  theme: ResonanceTheme,
  options: GlassStyleOptions = {},
): React.CSSProperties {
  const {
    blur = 'md',
    border = true,
    insetHighlight = true,
    saturation = 'moderate',
  } = options;

  const backdropParts = [
    theme.glass.blur[blur],
    theme.glass.saturation[saturation],
  ].join(' ');

  const shadows: string[] = [];
  if (insetHighlight) {
    shadows.push(theme.elevation.glassInset);
  }
  if (border) {
    shadows.push(`0 0 0 1px ${theme.colors.glassBorder}`);
  }

  return {
    background: theme.colors.glass,
    WebkitBackdropFilter: backdropParts,
    backdropFilter: backdropParts,
    boxShadow: shadows.length > 0 ? shadows.join(', ') : undefined,
    borderRadius: theme.borderRadius['2xl'],
  };
}

// ---------------------------------------------------------------------------
// Flow Phase Utilities
// ---------------------------------------------------------------------------

export function getCurrentFlowPhase(): keyof typeof FlowPhases {
  const hour = new Date().getHours();

  for (const [key, phase] of Object.entries(FlowPhases)) {
    const [start, end] = phase.hours;
    if (start < end) {
      if (hour >= start && hour < end) return key as keyof typeof FlowPhases;
    } else {
      // Wraps midnight (night: 21-5)
      if (hour >= start || hour < end) return key as keyof typeof FlowPhases;
    }
  }

  return 'night';
}

export function shouldEnableDeepRest(): boolean {
  const phase = getCurrentFlowPhase();
  return phase === 'night';
}

export function getPhaseColor(phase: keyof typeof FlowPhases): string {
  return FlowPhases[phase].color;
}

// ---------------------------------------------------------------------------
// Animation helpers
// ---------------------------------------------------------------------------

export function transition(
  properties: string[],
  duration: keyof typeof Duration = 'normal',
  easing: keyof typeof Easing = 'standard',
): string {
  return properties
    .map((prop) => `${prop} ${Duration[duration]} ${Easing[easing]}`)
    .join(', ');
}

export function breatheKeyframes(scale = 1.02): string {
  return `
    @keyframes breathe {
      0%, 100% { transform: scale(1); opacity: 0.8; }
      50% { transform: scale(${scale}); opacity: 1; }
    }
  `;
}

export function pulseKeyframes(color: string): string {
  return `
    @keyframes pulse {
      0%, 100% { box-shadow: 0 0 0 0 ${color}; }
      50% { box-shadow: 0 0 0 8px transparent; }
    }
  `;
}

// ---------------------------------------------------------------------------
// Tailwind CSS Integration Helpers
// ---------------------------------------------------------------------------

export function toTailwindConfig() {
  return {
    colors: {
      resonance: {
        base: 'var(--color-base)',
        surface: 'var(--color-surface)',
        'surface-elevated': 'var(--color-surface-elevated)',
        border: 'var(--color-border)',
        text: 'var(--color-text)',
        'text-secondary': 'var(--color-text-secondary)',
        'text-muted': 'var(--color-text-muted)',
        accent: 'var(--color-accent)',
        'accent-hover': 'var(--color-accent-hover)',
        'accent-subtle': 'var(--color-accent-subtle)',
        primary: 'var(--color-primary)',
        glass: 'var(--color-glass)',
      },
      gold: {
        50: ColorPalette.gold50,
        100: ColorPalette.gold100,
        200: ColorPalette.gold200,
        300: ColorPalette.gold300,
        400: ColorPalette.gold400,
        500: ColorPalette.gold500,
        600: ColorPalette.gold600,
        700: ColorPalette.gold700,
        800: ColorPalette.gold800,
        900: ColorPalette.gold900,
      },
      green: {
        50: ColorPalette.green50,
        100: ColorPalette.green100,
        200: ColorPalette.green200,
        300: ColorPalette.green300,
        400: ColorPalette.green400,
        500: ColorPalette.green500,
        600: ColorPalette.green600,
        700: ColorPalette.green700,
        800: ColorPalette.green800,
        900: ColorPalette.green900,
      },
    },
    fontFamily: {
      serif: [FontFamilies.serif],
      sans: [FontFamilies.sans],
      mono: [FontFamilies.mono],
    },
    borderRadius: {
      ...BorderRadius,
    },
    boxShadow: {
      ...Elevation,
    },
    transitionTimingFunction: {
      ...Easing,
    },
    transitionDuration: {
      ...Duration,
    },
  };
}

// ---------------------------------------------------------------------------
// Default Themes
// ---------------------------------------------------------------------------

export const lightTheme = createTheme('light');
export const deepRestTheme = createTheme('deep-rest');

export default { createTheme, lightTheme, deepRestTheme };
