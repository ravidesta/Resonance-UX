import { useState, useCallback } from 'react'
import type { LuminousNode, NodeType, NodeStatus } from '@/shared/types/node'
import type { Connection, ConnectionType } from '@/shared/types/connection'
import { v4 as uuid } from 'uuid'

function makeNode(partial: Partial<LuminousNode> & { type: NodeType; title: string }): LuminousNode {
  return {
    id: uuid(),
    icon: '',
    status: 'dormant' as NodeStatus,
    description: '',
    calendar: { events: [], goldenHourMinutes: 60 },
    links: { urls: [], apps: [], contacts: [], documents: [] },
    children: [],
    parent: null,
    depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 60, relatedNodes: [] },
    coverImage: null,
    backgroundEnvironment: 'smooth-vellum',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    ...partial,
  }
}

export function useNodes(initialNodes: LuminousNode[], initialConnections: Connection[]) {
  const [nodes, setNodes] = useState<LuminousNode[]>(initialNodes)
  const [connections, setConnections] = useState<Connection[]>(initialConnections)
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null)

  const selectedNode = nodes.find(n => n.id === selectedNodeId) ?? null

  const addNode = useCallback((type: NodeType, title: string, parentId?: string) => {
    const parent = parentId ? nodes.find(n => n.id === parentId) : null
    const node = makeNode({
      type,
      title,
      parent: parentId ?? null,
      depth: parent ? parent.depth + 1 : 0,
    })
    setNodes(prev => {
      const updated = [...prev, node]
      if (parentId) {
        return updated.map(n => n.id === parentId ? { ...n, children: [...n.children, node.id] } : n)
      }
      return updated
    })
    return node
  }, [nodes])

  const updateNode = useCallback((id: string, updates: Partial<LuminousNode>) => {
    setNodes(prev => prev.map(n => n.id === id ? { ...n, ...updates, updatedAt: new Date().toISOString() } : n))
  }, [])

  const deleteNode = useCallback((id: string) => {
    setNodes(prev => prev.filter(n => n.id !== id).map(n => ({
      ...n,
      children: n.children.filter(c => c !== id),
    })))
    setConnections(prev => prev.filter(c => c.source !== id && c.target !== id))
    if (selectedNodeId === id) setSelectedNodeId(null)
  }, [selectedNodeId])

  const addConnection = useCallback((source: string, target: string, type: ConnectionType) => {
    const conn: Connection = { id: uuid(), source, target, type }
    setConnections(prev => [...prev, conn])
    return conn
  }, [])

  const removeConnection = useCallback((id: string) => {
    setConnections(prev => prev.filter(c => c.id !== id))
  }, [])

  const updateNodeStatus = useCallback((id: string, status: NodeStatus) => {
    updateNode(id, { status })
  }, [updateNode])

  return {
    nodes,
    connections,
    selectedNode,
    selectedNodeId,
    setSelectedNodeId,
    addNode,
    updateNode,
    deleteNode,
    addConnection,
    removeConnection,
    updateNodeStatus,
    setNodes,
    setConnections,
  }
}
