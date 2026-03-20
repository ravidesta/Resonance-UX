export type Quadrant = 'UL' | 'UR' | 'LL' | 'LR'
export type Domain =
  | 'neurology'
  | 'somatic'
  | 'emotional'
  | 'cognitive'
  | 'relational'
  | 'creative'
  | 'spiritual'
  | 'systemic'

export type CardDifficulty = 'gentle' | 'moderate' | 'challenging' | 'advanced'

export interface ActivityCard {
  id: string
  quadrant: Quadrant
  domain: Domain
  title: string
  description: string
  durationMinutes: number
  difficulty: CardDifficulty
  developmentalTarget: string
  colorScheme: string
  guided: boolean
  hasTimer: boolean
  hasAudio: boolean
  multiplayer: boolean
  shareable: boolean
  userCreated: boolean
}

export const quadrantLabels: Record<Quadrant, { label: string; full: string; color: string }> = {
  UL: { label: 'UL', full: 'Interior-Individual', color: '#C5A059' },
  UR: { label: 'UR', full: 'Exterior-Individual', color: '#5C9C78' },
  LL: { label: 'LL', full: 'Interior-Collective', color: '#9A7A3A' },
  LR: { label: 'LR', full: 'Exterior-Collective', color: '#8EBFA4' },
}

export const domainLabels: Record<Domain, string> = {
  neurology: 'Neurology',
  somatic: 'Somatic',
  emotional: 'Emotional',
  cognitive: 'Cognitive',
  relational: 'Relational',
  creative: 'Creative',
  spiritual: 'Spiritual',
  systemic: 'Systemic',
}
