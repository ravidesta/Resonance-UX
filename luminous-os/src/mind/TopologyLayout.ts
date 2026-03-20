import {
  forceSimulation,
  forceLink,
  forceManyBody,
  forceCenter,
  forceCollide,
  forceX,
  forceY,
  type SimulationNodeDatum,
  type SimulationLinkDatum,
} from 'd3-force'
import type { LuminousNode } from '@/shared/types/node'
import type { Connection } from '@/shared/types/connection'
import { nodeTypeConfig } from '@/shared/types/node'

interface LayoutNode extends SimulationNodeDatum {
  id: string
  type: string
  depth: number
}

interface LayoutLink extends SimulationLinkDatum<LayoutNode> {
  source: string
  target: string
}

export interface LayoutResult {
  positions: Map<string, { x: number; y: number }>
}

export function computeTopologyLayout(
  nodes: LuminousNode[],
  connections: Connection[],
  width: number = 1200,
  height: number = 800,
): LayoutResult {
  const layoutNodes: LayoutNode[] = nodes.map(n => ({
    id: n.id,
    type: n.type,
    depth: n.depth,
    x: Math.random() * width - width / 2,
    y: Math.random() * height - height / 2,
  }))

  const nodeIds = new Set(nodes.map(n => n.id))
  const layoutLinks: LayoutLink[] = connections
    .filter(c => nodeIds.has(c.source) && nodeIds.has(c.target))
    .map(c => ({ source: c.source, target: c.target }))

  // Add parent-child links
  for (const node of nodes) {
    if (node.parent && nodeIds.has(node.parent)) {
      const exists = layoutLinks.some(
        l => (l.source === node.parent && l.target === node.id) ||
             (l.source === node.id && l.target === node.parent)
      )
      if (!exists) {
        layoutLinks.push({ source: node.parent, target: node.id })
      }
    }
  }

  const nodeMap = new Map(layoutNodes.map(n => [n.id, n]))

  const simulation = forceSimulation(layoutNodes)
    .force('link', forceLink<LayoutNode, LayoutLink>(layoutLinks)
      .id(d => d.id)
      .distance((d: SimulationLinkDatum<LayoutNode>) => {
        const sourceId = typeof d.source === 'string' ? d.source : (d.source as LayoutNode).id
        const targetId = typeof d.target === 'string' ? d.target : (d.target as LayoutNode).id
        const source = nodeMap.get(sourceId)
        const target = nodeMap.get(targetId)
        const sourceSize = source ? nodeTypeConfig[source.type as keyof typeof nodeTypeConfig]?.baseSize ?? 80 : 80
        const targetSize = target ? nodeTypeConfig[target.type as keyof typeof nodeTypeConfig]?.baseSize ?? 80 : 80
        return (sourceSize + targetSize) * 1.2
      })
      .strength(0.4)
    )
    .force('charge', forceManyBody().strength(-300))
    .force('center', forceCenter(0, 0).strength(0.05))
    .force('collide', forceCollide<LayoutNode>().radius(d => {
      const config = nodeTypeConfig[d.type as keyof typeof nodeTypeConfig]
      return (config?.baseSize ?? 80) * 0.7
    }).strength(0.8))
    .force('x', forceX<LayoutNode>().strength(0.02))
    .force('y', forceY<LayoutNode>().strength(0.02))
    .stop()

  // Run simulation synchronously
  for (let i = 0; i < 200; i++) {
    simulation.tick()
  }

  const positions = new Map<string, { x: number; y: number }>()
  for (const node of layoutNodes) {
    positions.set(node.id, { x: node.x ?? 0, y: node.y ?? 0 })
  }

  return { positions }
}
