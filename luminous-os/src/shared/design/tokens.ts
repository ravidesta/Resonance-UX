export const colors = {
  green: {
    900: '#0A1C14',
    800: '#122E21',
    700: '#1B402E',
    600: '#2D5E44',
    500: '#3F7A5A',
    400: '#5C9C78',
    300: '#8EBFA4',
    200: '#D1E0D7',
    100: '#E8F0EA',
  },
  gold: {
    primary: '#C5A059',
    light: '#E6D0A1',
    dark: '#9A7A3A',
    glow: 'rgba(197, 160, 89, 0.4)',
  },
  bg: {
    base: '#FAFAF8',
    surface: '#FFFFFF',
    glass: 'rgba(255, 255, 255, 0.4)',
    glassHeavy: 'rgba(255, 255, 255, 0.85)',
  },
  text: {
    main: '#122E21',
    muted: '#5C7065',
    light: '#8A9C91',
  },
} as const

export const shadows = {
  glass: '0 16px 40px rgba(154, 122, 58, 0.12)',
  card: '0 8px 24px rgba(154, 122, 58, 0.08)',
  cardHover: '0 24px 48px rgba(154, 122, 58, 0.18)',
  node: '0 4px 20px rgba(10, 28, 20, 0.12)',
  nodeHover: '0 8px 32px rgba(197, 160, 89, 0.2)',
} as const

export const easings = {
  spring: 'cubic-bezier(0.34, 1.56, 0.64, 1)',
  smooth: 'cubic-bezier(0.165, 0.84, 0.44, 1)',
} as const

export const fonts = {
  serif: "'Cormorant Garamond', serif",
  sans: "'Manrope', sans-serif",
} as const
