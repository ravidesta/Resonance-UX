export type ConnectionType =
  | 'feeds'
  | 'requires'
  | 'relates'
  | 'generates'
  | 'involves'
  | 'inspires'

export interface Connection {
  id: string
  source: string
  target: string
  type: ConnectionType
  label?: string
}

export interface ConnectionStyle {
  stroke: string
  strokeWidth: number
  dashArray: string
  animated: boolean
  hasArrow: boolean
  glow: boolean
}

export const connectionStyles: Record<ConnectionType, ConnectionStyle> = {
  feeds: {
    stroke: '#C5A059',
    strokeWidth: 2,
    dashArray: '',
    animated: true,
    hasArrow: true,
    glow: false,
  },
  requires: {
    stroke: '#5C9C78',
    strokeWidth: 1.5,
    dashArray: '4 4',
    animated: false,
    hasArrow: true,
    glow: false,
  },
  relates: {
    stroke: '#D1E0D7',
    strokeWidth: 1,
    dashArray: '',
    animated: false,
    hasArrow: false,
    glow: false,
  },
  generates: {
    stroke: '#C5A059',
    strokeWidth: 2.5,
    dashArray: '',
    animated: true,
    hasArrow: true,
    glow: true,
  },
  involves: {
    stroke: '#8EBFA4',
    strokeWidth: 1,
    dashArray: '2 2',
    animated: false,
    hasArrow: false,
    glow: false,
  },
  inspires: {
    stroke: '#E6D0A1',
    strokeWidth: 0.5,
    dashArray: '8 4',
    animated: false,
    hasArrow: false,
    glow: false,
  },
}
