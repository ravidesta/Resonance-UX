/**
 * Resonance UX Design Tokens
 * The Luminous Lifewheel Design System
 *
 * Calm technology. Organic motion. Sacred spaciousness.
 */

export const Colors = {
  // ─── Light Mode (Porous Cream Base) ───
  light: {
    bgBase: '#FAFAF8',
    bgSurface: '#FFFFFF',
    bgGlass: 'rgba(255, 255, 255, 0.7)',
    bgGlassRaised: 'rgba(245, 244, 238, 0.65)',
    bgGlassCard: 'rgba(250, 249, 245, 0.55)',

    green900: '#0A1C14',
    green800: '#122E21',
    green700: '#1B402E',
    green600: '#2A5E42',
    green500: '#3A7D5A',
    green400: '#6BA88A',
    green300: '#9DC4AF',
    green200: '#D1E0D7',
    green100: '#E8F0EA',
    green50:  '#F3F8F5',

    gold:     '#C5A059',
    goldLight:'#E6D0A1',
    goldDark: '#9A7A3A',
    goldGlow: 'rgba(197, 160, 89, 0.15)',

    textMain:  '#122E21',
    textMuted: '#5C7065',
    textLight: '#8A9C91',

    borderLight: '#E5EBE7',
    borderFocus: 'rgba(197, 160, 89, 0.6)',

    shadow: 'rgba(154, 122, 58, 0.08)',
    shadowDeep: 'rgba(154, 122, 58, 0.18)',

    // Lifewheel Dimension Colors
    dimensionPhysical:   '#4CAF7D',
    dimensionEmotional:  '#5B9BD5',
    dimensionMental:     '#9B7FD4',
    dimensionSpiritual:  '#D4AF37',
    dimensionRelations:  '#E88A6E',
    dimensionPurpose:    '#E06B50',
    dimensionCreative:   '#D48ABF',
    dimensionEnvironment:'#6BB5A0',
  },

  // ─── Deep Rest / Night Mode (Forest Canopy) ───
  dark: {
    bgBase: '#05100B',
    bgSurface: '#0A1C14',
    bgGlass: 'rgba(10, 28, 20, 0.75)',
    bgGlassRaised: 'rgba(10, 28, 20, 0.55)',
    bgGlassCard: 'rgba(15, 35, 25, 0.45)',

    green900: '#E8F0EA',
    green800: '#D1E0D7',
    green700: '#9DC4AF',
    green600: '#6BA88A',
    green500: '#3A7D5A',
    green400: '#2A5E42',
    green300: '#1B402E',
    green200: 'rgba(27, 64, 46, 0.6)',
    green100: 'rgba(10, 28, 20, 0.8)',
    green50:  'rgba(5, 16, 11, 0.9)',

    gold:     '#D4B96A',
    goldLight:'#E6D0A1',
    goldDark: '#C5A059',
    goldGlow: 'rgba(197, 160, 89, 0.08)',

    textMain:  '#FAFAF8',
    textMuted: '#8A9C91',
    textLight: '#5C7065',

    borderLight: 'rgba(27, 64, 46, 0.7)',
    borderFocus: 'rgba(197, 160, 89, 0.5)',

    shadow: 'rgba(0, 0, 0, 0.5)',
    shadowDeep: 'rgba(0, 0, 0, 0.9)',

    dimensionPhysical:   '#5DC48E',
    dimensionEmotional:  '#6BADE7',
    dimensionMental:     '#B090E6',
    dimensionSpiritual:  '#E6C44A',
    dimensionRelations:  '#F09B7F',
    dimensionPurpose:    '#F07C62',
    dimensionCreative:   '#E69BD0',
    dimensionEnvironment:'#7CC6B1',
  },
};

export const Typography = {
  serif: 'Cormorant Garamond',
  serifFallback: 'Georgia',
  sans: 'Manrope',
  sansFallback: 'System',

  sizes: {
    xs:    11,
    sm:    13,
    base:  15,
    md:    17,
    lg:    20,
    xl:    24,
    '2xl': 30,
    '3xl': 36,
    '4xl': 48,
    '5xl': 60,
    hero:  72,
  },

  weights: {
    light:    '300',
    regular:  '400',
    medium:   '500',
    semibold: '600',
    bold:     '700',
  },

  lineHeights: {
    tight:  1.2,
    normal: 1.5,
    relaxed:1.7,
    loose:  2.0,
  },
};

export const Spacing = {
  xs:  4,
  sm:  8,
  md:  12,
  base:16,
  lg:  20,
  xl:  24,
  '2xl':32,
  '3xl':40,
  '4xl':48,
  '5xl':64,
  '6xl':80,
};

export const Radii = {
  sm:   8,
  md:   12,
  lg:   16,
  xl:   20,
  '2xl':24,
  '3xl':32,
  full: 9999,
  pill: 40,
};

export const Shadows = {
  sm: {
    shadowColor: '#9A7A3A',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 2,
  },
  md: {
    shadowColor: '#9A7A3A',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.08,
    shadowRadius: 24,
    elevation: 4,
  },
  lg: {
    shadowColor: '#9A7A3A',
    shadowOffset: { width: 0, height: 16 },
    shadowOpacity: 0.12,
    shadowRadius: 40,
    elevation: 8,
  },
  glass: {
    shadowColor: '#9A7A3A',
    shadowOffset: { width: 0, height: 16 },
    shadowOpacity: 0.12,
    shadowRadius: 40,
    elevation: 8,
  },
};

export const Animation = {
  spring: { damping: 15, stiffness: 150, mass: 0.8 },
  springGentle: { damping: 20, stiffness: 120, mass: 1 },
  springBouncy: { damping: 12, stiffness: 180, mass: 0.6 },
  breatheDuration: 15000,
  transitionFast: 200,
  transitionBase: 350,
  transitionSlow: 600,
  transitionTheme: 800,
};

// The 8 Luminous Lifewheel Dimensions
export const LifewheelDimensions = [
  {
    key: 'physical',
    label: 'Physical Vitality',
    emoji: '🌿',
    description: 'Honoring the sacred vessel we inhabit',
    colorKey: 'dimensionPhysical',
  },
  {
    key: 'emotional',
    label: 'Emotional Well-Being',
    emoji: '🌊',
    description: 'Embracing the full symphony of feeling',
    colorKey: 'dimensionEmotional',
  },
  {
    key: 'mental',
    label: 'Mental Clarity',
    emoji: '🧠',
    description: 'Spacious awareness and curious growth',
    colorKey: 'dimensionMental',
  },
  {
    key: 'spiritual',
    label: 'Spiritual Connection',
    emoji: '✨',
    description: 'Meaning, purpose, and the sacred',
    colorKey: 'dimensionSpiritual',
  },
  {
    key: 'relationships',
    label: 'Relationships',
    emoji: '💛',
    description: 'The mirror of genuine connection',
    colorKey: 'dimensionRelations',
  },
  {
    key: 'purpose',
    label: 'Purpose & Contribution',
    emoji: '🔥',
    description: 'Expressing your gifts in service',
    colorKey: 'dimensionPurpose',
  },
  {
    key: 'creative',
    label: 'Creative Expression',
    emoji: '🎨',
    description: 'Play, creation, and joyful exploration',
    colorKey: 'dimensionCreative',
  },
  {
    key: 'environment',
    label: 'Environment & Resources',
    emoji: '🏡',
    description: 'The supportive conditions for flourishing',
    colorKey: 'dimensionEnvironment',
  },
];
