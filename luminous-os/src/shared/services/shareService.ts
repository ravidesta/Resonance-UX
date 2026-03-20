import type { ShareableContent, ShareableType } from '@/shared/types/share'
import type { LuminousNode } from '@/shared/types/node'
import type { TimerPhase, RoomVibe } from '@/shared/types/room'
import type { ActivityCard } from '@/shared/types/card'
import { nodeTypeConfig } from '@/shared/types/node'
import { statusConfig } from '@/shared/design/lexicon'
import { roomVibes } from '@/shared/types/room'
import { quadrantLabels, domainLabels } from '@/shared/types/card'

const APP_URL = 'https://luminous.app'

/** Generate share text with Luminous voice — poetic, inviting, never salesy */
function shareText(content: ShareableContent): string {
  switch (content.type) {
    case 'node':
      return `${content.title}\n\n${content.description}\n\n${content.tags.map(t => `#${t}`).join(' ')}`
    case 'golden-hour':
      return `${content.title}\n\n${content.description}\n\nThe last 20% wasn't panic — it was the most beautiful part.\n\n${content.tags.map(t => `#${t}`).join(' ')}`
    case 'room-vibe':
      return `${content.title}\n\n${content.description}\n\n${content.tags.map(t => `#${t}`).join(' ')}`
    case 'activity-card':
      return `${content.title}\n\n${content.description}\n\n${content.tags.map(t => `#${t}`).join(' ')}`
    case 'portfolio-item':
      return `${content.title}\n\n${content.description}\n\n${content.tags.map(t => `#${t}`).join(' ')}`
    case 'milestone':
      return `${content.title}\n\n${content.description}\n\n${content.tags.map(t => `#${t}`).join(' ')}`
    case 'mind-map':
      return `${content.title}\n\n${content.description}\n\n${content.tags.map(t => `#${t}`).join(' ')}`
    default:
      return `${content.title} — ${content.description}`
  }
}

/** Create shareable content from a mind map node */
export function shareableFromNode(node: LuminousNode): ShareableContent {
  const config = nodeTypeConfig[node.type]
  const status = statusConfig[node.status]

  const poeticDescriptions: Record<string, string> = {
    portfolio: `A constellation of work, alive and connected. ${node.children.length} projects breathing inside it.`,
    campaign: `A strategic arc — ${node.description || 'moving toward its horizon.'}`,
    project: `${node.description || 'A body of work finding its shape.'}`,
    task: `${node.description || 'One focused act of creation.'}`,
    app: `${node.description || 'A tool in the living archipelago.'}`,
    person: `${node.description || 'A collaborator in the creative field.'}`,
    document: `${node.description || 'A sacred text in the topology.'}`,
    book: `${node.description || 'Knowledge waiting to transmute.'}`,
    course: `${node.description || 'A learning journey generated from living intelligence.'}`,
    album: `${node.description || 'Captured moments from the creative process.'}`,
  }

  return {
    type: 'node',
    title: `${node.title} — ${status.label}`,
    description: poeticDescriptions[node.type] || node.description || '',
    tags: ['Luminous', 'CreativeOS', config.label, status.label],
    accentColor: config.color,
    appUrl: `${APP_URL}/mind/${node.id}`,
    meta: {
      nodeType: node.type,
      status: node.status,
      childCount: String(node.children.length),
    },
  }
}

/** Create shareable content from a Golden Hour completion */
export function shareableFromGoldenHour(
  taskTitle: string,
  durationMinutes: number,
  phase: TimerPhase,
): ShareableContent {
  const completionMessages: Record<TimerPhase, string> = {
    morning: `Starting a focused session on "${taskTitle}." The morning is fresh.`,
    'full-day': `Deep in flow on "${taskTitle}." Steady, sustained, alive.`,
    'golden-hour': `Golden Hour on "${taskTitle}." The last 20% — when the light shifts and finishing becomes sacred.`,
    complete: `Completed a ${durationMinutes}-minute session on "${taskTitle}." The bell rang. The work is harvested.`,
  }

  return {
    type: 'golden-hour',
    title: phase === 'complete'
      ? `Session Complete: ${taskTitle}`
      : `Golden Hour: ${taskTitle}`,
    description: completionMessages[phase],
    tags: ['GoldenHour', 'Luminous', 'DeepWork', 'RadicalCalmness', 'FocusSession'],
    accentColor: '#C5A059',
    appUrl: `${APP_URL}/rooms`,
    meta: {
      duration: `${durationMinutes}m`,
      phase,
    },
  }
}

/** Create shareable content from a room vibe */
export function shareableFromRoomVibe(vibe: RoomVibe, taskTitle: string): ShareableContent {
  const config = roomVibes[vibe]

  return {
    type: 'room-vibe',
    title: `${config.label} — Working on "${taskTitle}"`,
    description: `${config.description}. Every task has a room. Every room has a vibe. This one felt right.`,
    tags: ['LuminousRooms', 'Luminous', config.label.replace(/\s/g, ''), 'FocusSpace'],
    accentColor: config.accentColor,
    appUrl: `${APP_URL}/rooms`,
    meta: { vibe },
  }
}

/** Create shareable content from an activity card */
export function shareableFromCard(card: ActivityCard): ShareableContent {
  const quadrant = quadrantLabels[card.quadrant]
  const domain = domainLabels[card.domain]

  return {
    type: 'activity-card',
    title: card.title,
    description: `${card.description}\n\n${quadrant.full} × ${domain} · ${card.durationMinutes}min · ${card.difficulty}`,
    tags: ['Luminous', 'DevelopmentalPractice', domain, quadrant.label, card.difficulty],
    accentColor: quadrant.color,
    appUrl: `${APP_URL}/engine/cards/${card.id}`,
    meta: {
      quadrant: card.quadrant,
      domain: card.domain,
      difficulty: card.difficulty,
    },
  }
}

/** Create shareable content from a milestone (node reaching "Harvested") */
export function shareableFromMilestone(node: LuminousNode): ShareableContent {
  const config = nodeTypeConfig[node.type]

  const celebrations: Record<string, string> = {
    portfolio: `An entire portfolio — harvested. Every project, every campaign, every late night and golden hour — complete.`,
    campaign: `Campaign complete. From germination to harvest. The work is gathered.`,
    project: `Project "${node.title}" — harvested. What was compressed potential is now living artifact.`,
    task: `Done. Not just "checked off" — harvested. The difference matters.`,
  }

  return {
    type: 'milestone',
    title: `Harvested: ${node.title}`,
    description: celebrations[node.type] || `${node.title} — the fruit has been gathered.`,
    tags: ['Luminous', 'Harvested', 'Milestone', config.label, 'CreativeCompletion'],
    accentColor: '#8EBFA4',
    appUrl: `${APP_URL}/mind/${node.id}`,
    meta: {
      nodeType: node.type,
      status: 'harvested',
    },
  }
}

/** Create shareable content from the whole mind map */
export function shareableFromMindMap(
  nodeCount: number,
  connectionCount: number,
): ShareableContent {
  return {
    type: 'mind-map',
    title: `My Creative Topology`,
    description: `${nodeCount} nodes. ${connectionCount} connections. A living map of everything I'm building, growing, and dreaming — all in one view.\n\nNot a to-do list. Not a folder hierarchy. A constellation.`,
    tags: ['Luminous', 'LuminousMind', 'CreativeOS', 'SpatialThinking', 'MindMap'],
    accentColor: '#C5A059',
    appUrl: APP_URL,
    meta: {
      nodeCount: String(nodeCount),
      connectionCount: String(connectionCount),
    },
  }
}

/** Generate the share text for a platform post */
export function generateShareText(content: ShareableContent): string {
  return shareText(content)
}

/** Open a share URL in a new window */
export function openShareUrl(url: string): void {
  window.open(url, '_blank', 'width=600,height=400,noopener,noreferrer')
}

/** Copy text to clipboard */
export async function copyToClipboard(text: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(text)
    return true
  } catch {
    // Fallback for older browsers
    const ta = document.createElement('textarea')
    ta.value = text
    ta.style.position = 'fixed'
    ta.style.opacity = '0'
    document.body.appendChild(ta)
    ta.select()
    const ok = document.execCommand('copy')
    document.body.removeChild(ta)
    return ok
  }
}

/** Use Web Share API if available (mobile) */
export async function nativeShare(content: ShareableContent): Promise<boolean> {
  if (!navigator.share) return false
  try {
    await navigator.share({
      title: content.title,
      text: shareText(content),
      url: content.appUrl,
    })
    return true
  } catch {
    return false
  }
}
