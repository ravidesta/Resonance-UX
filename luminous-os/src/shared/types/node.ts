export type NodeType =
  | 'portfolio'
  | 'campaign'
  | 'project'
  | 'task'
  | 'app'
  | 'person'
  | 'document'
  | 'course'
  | 'book'
  | 'album'

export type NodeStatus =
  | 'dormant'
  | 'germinating'
  | 'growing'
  | 'flowering'
  | 'harvested'
  | 'composting'

export interface CalendarEvent {
  id: string
  title: string
  start: string
  end: string
  type: 'meeting' | 'deadline' | 'timeblock' | 'golden-hour'
}

export interface NodeCalendar {
  events: CalendarEvent[]
  goldenHourMinutes: number
}

export interface NodeLinks {
  urls: { label: string; href: string }[]
  apps: string[]
  contacts: string[]
  documents: string[]
}

export interface AIContext {
  suggestedTools: string[]
  suggestedOrder: number
  estimatedMinutes: number
  relatedNodes: string[]
}

export interface LuminousNode {
  id: string
  type: NodeType
  title: string
  icon: string
  status: NodeStatus
  description?: string
  calendar: NodeCalendar
  links: NodeLinks
  children: string[]
  parent: string | null
  depth: number
  aiContext: AIContext
  coverImage: string | null
  backgroundEnvironment: string
  createdAt: string
  updatedAt: string
}

export const nodeTypeConfig: Record<NodeType, {
  label: string
  defaultIcon: string
  baseSize: number
  color: string
  humorousLabel: string
}> = {
  portfolio: {
    label: 'Portfolio',
    defaultIcon: 'Briefcase',
    baseSize: 140,
    color: '#C5A059',
    humorousLabel: 'The Big Picture',
  },
  campaign: {
    label: 'Campaign',
    defaultIcon: 'Target',
    baseSize: 110,
    color: '#3F7A5A',
    humorousLabel: 'Battle Plan',
  },
  project: {
    label: 'Project',
    defaultIcon: 'FolderKanban',
    baseSize: 90,
    color: '#5C9C78',
    humorousLabel: 'The Thing',
  },
  task: {
    label: 'Task',
    defaultIcon: 'CheckCircle2',
    baseSize: 70,
    color: '#8EBFA4',
    humorousLabel: 'Just Do It',
  },
  app: {
    label: 'App',
    defaultIcon: 'AppWindow',
    baseSize: 80,
    color: '#9A7A3A',
    humorousLabel: 'Shiny Tool',
  },
  person: {
    label: 'Person',
    defaultIcon: 'User',
    baseSize: 70,
    color: '#E6D0A1',
    humorousLabel: 'Fellow Human',
  },
  document: {
    label: 'Document',
    defaultIcon: 'FileText',
    baseSize: 60,
    color: '#D1E0D7',
    humorousLabel: 'Sacred Text',
  },
  course: {
    label: 'Course',
    defaultIcon: 'GraduationCap',
    baseSize: 85,
    color: '#C5A059',
    humorousLabel: 'Brain Food',
  },
  book: {
    label: 'Book',
    defaultIcon: 'BookOpen',
    baseSize: 75,
    color: '#9A7A3A',
    humorousLabel: 'Page Turner',
  },
  album: {
    label: 'Album',
    defaultIcon: 'Image',
    baseSize: 80,
    color: '#E6D0A1',
    humorousLabel: 'Memory Lane',
  },
}
