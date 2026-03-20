export type RoomVibe =
  | 'smooth-vellum'
  | 'digital-glass'
  | 'rain-swept-window'
  | 'ancient-forest'
  | 'bioluminescent-deep'

export type TimerPhase = 'morning' | 'full-day' | 'golden-hour' | 'complete'

export interface RoomConfig {
  taskId: string
  vibe: RoomVibe
  apps: string[]
  links: { label: string; href: string }[]
  contacts: string[]
  timerMinutes: number
}

export interface TimerState {
  phase: TimerPhase
  elapsed: number
  total: number
  isRunning: boolean
  progress: number
}

export interface RoomVibeConfig {
  label: string
  description: string
  bgGradient: string
  goldenHourGradient: string
  accentColor: string
  completionChime: string
}

export const roomVibes: Record<RoomVibe, RoomVibeConfig> = {
  'smooth-vellum': {
    label: 'Smooth Vellum',
    description: 'Warm cream, paper texture',
    bgGradient: 'linear-gradient(135deg, #FAFAF8 0%, #F0EDE3 50%, #E8E2D5 100%)',
    goldenHourGradient: 'linear-gradient(135deg, #F5EDD8 0%, #E8D5A8 50%, #D4BC7C 100%)',
    accentColor: '#C5A059',
    completionChime: 'meditation-bowl',
  },
  'digital-glass': {
    label: 'Digital Glass',
    description: 'Cool blue-green, glass panels',
    bgGradient: 'linear-gradient(135deg, #E8F0EA 0%, #D1E0D7 50%, #B8D4C8 100%)',
    goldenHourGradient: 'linear-gradient(135deg, #D8E8D0 0%, #C5D8B8 50%, #B8C8A0 100%)',
    accentColor: '#5C9C78',
    completionChime: 'glass-chime',
  },
  'rain-swept-window': {
    label: 'Rain-swept Window',
    description: 'Animated rain, warm interior',
    bgGradient: 'linear-gradient(135deg, #2D3E36 0%, #1B2E24 50%, #0F1F18 100%)',
    goldenHourGradient: 'linear-gradient(135deg, #3D4E36 0%, #4A5A38 50%, #5A6A40 100%)',
    accentColor: '#8EBFA4',
    completionChime: 'church-bells',
  },
  'ancient-forest': {
    label: 'Ancient Forest',
    description: 'Deep greens, canopy light',
    bgGradient: 'linear-gradient(135deg, #0A1C14 0%, #122E21 50%, #1B402E 100%)',
    goldenHourGradient: 'linear-gradient(135deg, #1A3020 0%, #2A4030 50%, #3A5040 100%)',
    accentColor: '#3F7A5A',
    completionChime: 'temple-bell',
  },
  'bioluminescent-deep': {
    label: 'Bioluminescent Deep',
    description: 'Deep ocean blues, soft bioluminescence',
    bgGradient: 'linear-gradient(135deg, #0A1020 0%, #0F1A2E 50%, #14243C 100%)',
    goldenHourGradient: 'linear-gradient(135deg, #142030 0%, #1A3040 50%, #204050 100%)',
    accentColor: '#4A8BA8',
    completionChime: 'deep-gong',
  },
}
