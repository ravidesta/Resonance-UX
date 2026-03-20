import type { NodeStatus } from '@/shared/types/node'

export interface StatusConfig {
  label: string
  description: string
  glowColor: string
  borderColor: string
  bgTint: string
  animate: boolean
}

export const statusConfig: Record<NodeStatus, StatusConfig> = {
  dormant: {
    label: 'Dormant',
    description: 'Resting. Not yet stirring.',
    glowColor: 'transparent',
    borderColor: 'var(--color-border-light)',
    bgTint: 'transparent',
    animate: false,
  },
  germinating: {
    label: 'Germinating',
    description: 'Seeds planted. Something is forming.',
    glowColor: 'rgba(92, 156, 120, 0.3)',
    borderColor: 'var(--color-green-400)',
    bgTint: 'rgba(92, 156, 120, 0.08)',
    animate: true,
  },
  growing: {
    label: 'Growing',
    description: 'Active growth. Energy moving through.',
    glowColor: 'rgba(197, 160, 89, 0.35)',
    borderColor: 'var(--color-gold-primary)',
    bgTint: 'rgba(197, 160, 89, 0.08)',
    animate: true,
  },
  flowering: {
    label: 'Flowering',
    description: 'Peak expression. The work is alive.',
    glowColor: 'rgba(197, 160, 89, 0.5)',
    borderColor: 'var(--color-gold-light)',
    bgTint: 'rgba(230, 208, 161, 0.12)',
    animate: true,
  },
  harvested: {
    label: 'Harvested',
    description: 'Complete. The fruit has been gathered.',
    glowColor: 'rgba(142, 191, 164, 0.4)',
    borderColor: 'var(--color-green-300)',
    bgTint: 'rgba(142, 191, 164, 0.1)',
    animate: false,
  },
  composting: {
    label: 'Composting',
    description: 'Returning to earth. Feeding the next cycle.',
    glowColor: 'transparent',
    borderColor: 'var(--color-text-light)',
    bgTint: 'transparent',
    animate: false,
  },
}

export const connectionLabels: Record<string, string> = {
  feeds: 'feeds into',
  requires: 'depends on',
  relates: 'relates to',
  generates: 'generates',
  involves: 'involves',
  inspires: 'is inspired by',
}
