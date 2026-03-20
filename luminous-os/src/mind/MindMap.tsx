import { useState, useCallback, useMemo, useEffect } from 'react'
import {
  ReactFlow,
  MiniMap,
  useNodesState,
  useEdgesState,
  useReactFlow,
  ReactFlowProvider,
  type Node,
  type Edge,
  type NodeMouseHandler,
  type OnSelectionChangeFunc,
} from '@xyflow/react'
import '@xyflow/react/dist/style.css'

import type { LuminousNode, NodeType, NodeStatus } from '@/shared/types/node'
import type { Connection } from '@/shared/types/connection'
import { MindNodeRenderer, type MindNodeData } from './nodes/MindNode'
import { ConnectionLineRenderer } from './connections/ConnectionLine'
import { NodeContextMenu } from './NodeContextMenu'
import { NodeCalendar } from './NodeCalendar'
import { ZoomController } from './ZoomController'
import { CreationModeSelector, type CreationMode } from './CreationModeSelector'
import { computeTopologyLayout } from './TopologyLayout'
import { useNodes as useNodeStore } from '@/shared/hooks/useNode'
import { OrganicBlobs, PaperNoise } from '@/shared/design/GlobalStyles'

// Node type registry for React Flow
const nodeTypes = { mindNode: MindNodeRenderer }
const edgeTypes = { connectionEdge: ConnectionLineRenderer }

function zoomToAltitude(zoom: number): number {
  if (zoom <= 0.15) return 5
  if (zoom <= 0.3) return 4
  if (zoom <= 0.5) return 3
  if (zoom <= 0.8) return 2
  if (zoom <= 1.5) return 1
  return 0
}

interface MindMapInnerProps {
  initialNodes: LuminousNode[]
  initialConnections: Connection[]
  onEnterRoom: (taskId: string) => void
}

function MindMapInner({ initialNodes, initialConnections, onEnterRoom }: MindMapInnerProps) {
  const store = useNodeStore(initialNodes, initialConnections)
  const { getViewport } = useReactFlow()

  const [altitude, setAltitude] = useState(3)
  const [creationMode, setCreationMode] = useState<CreationMode>('together')
  const [contextMenu, setContextMenu] = useState<{ node: LuminousNode; position: { x: number; y: number } } | null>(null)
  const [calendarNode, setCalendarNode] = useState<LuminousNode | null>(null)

  // Compute force-directed layout
  const layout = useMemo(
    () => computeTopologyLayout(store.nodes, store.connections),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [store.nodes.length, store.connections.length]
  )

  // Convert to React Flow nodes
  const rfNodes: Node<MindNodeData>[] = useMemo(() =>
    store.nodes.map(node => {
      const pos = layout.positions.get(node.id) || { x: 0, y: 0 }
      return {
        id: node.id,
        type: 'mindNode',
        position: pos,
        data: { node, altitude, onEnterRoom } as MindNodeData,
        draggable: true,
      }
    }),
    [store.nodes, layout, altitude, onEnterRoom]
  )

  // Convert to React Flow edges
  const rfEdges: Edge[] = useMemo(() =>
    store.connections.map(conn => ({
      id: conn.id,
      source: conn.source,
      target: conn.target,
      type: 'connectionEdge',
      data: { connectionType: conn.type },
      animated: false,
    })),
    [store.connections]
  )

  const [flowNodes, setFlowNodes, onNodesChange] = useNodesState(rfNodes)
  const [flowEdges, setFlowEdges, onEdgesChange] = useEdgesState(rfEdges)

  // Sync when rfNodes/rfEdges change
  useEffect(() => { setFlowNodes(rfNodes) }, [rfNodes, setFlowNodes])
  useEffect(() => { setFlowEdges(rfEdges) }, [rfEdges, setFlowEdges])

  // Track zoom → altitude
  const onMoveEnd = useCallback(() => {
    const viewport = getViewport()
    setAltitude(zoomToAltitude(viewport.zoom))
  }, [getViewport])

  // Right-click handler
  const onNodeContextMenu: NodeMouseHandler = useCallback((event, node) => {
    event.preventDefault()
    const luminousNode = store.nodes.find(n => n.id === node.id)
    if (luminousNode) {
      setContextMenu({
        node: luminousNode,
        position: { x: (event as unknown as MouseEvent).clientX, y: (event as unknown as MouseEvent).clientY },
      })
    }
  }, [store.nodes])

  // Node click handler
  const onNodeClick: NodeMouseHandler = useCallback((_event, node) => {
    store.setSelectedNodeId(node.id)
  }, [store])

  // Selection change
  const onSelectionChange: OnSelectionChangeFunc = useCallback(({ nodes: selectedNodes }) => {
    if (selectedNodes.length === 0) store.setSelectedNodeId(null)
  }, [store])

  // Create node handler
  const handleCreateNode = useCallback((type: NodeType, title: string) => {
    store.addNode(type, title)
  }, [store])

  // Status change handler
  const handleStatusChange = useCallback((id: string, status: NodeStatus) => {
    store.updateNodeStatus(id, status)
  }, [store])

  return (
    <div className="w-full h-full relative" style={{ background: 'var(--color-bg-base)' }}>
      {/* Living background */}
      <OrganicBlobs />
      <PaperNoise />

      {/* React Flow canvas */}
      <div className="absolute inset-0 z-10">
        <ReactFlow
          nodes={flowNodes}
          edges={flowEdges}
          onNodesChange={onNodesChange}
          onEdgesChange={onEdgesChange}
          onMoveEnd={onMoveEnd}
          onNodeContextMenu={onNodeContextMenu}
          onNodeClick={onNodeClick}
          onSelectionChange={onSelectionChange}
          nodeTypes={nodeTypes}
          edgeTypes={edgeTypes}
          fitView
          fitViewOptions={{ padding: 0.3 }}
          minZoom={0.05}
          maxZoom={3}
          defaultEdgeOptions={{ type: 'connectionEdge' }}
          proOptions={{ hideAttribution: true }}
          style={{ background: 'transparent' }}
        >
          <MiniMap
            nodeColor={(node) => {
              const data = node.data as MindNodeData
              return data?.node?.type === 'portfolio' ? '#C5A059' :
                     data?.node?.type === 'campaign' ? '#3F7A5A' :
                     data?.node?.type === 'project' ? '#5C9C78' :
                     data?.node?.type === 'task' ? '#8EBFA4' :
                     '#D1E0D7'
            }}
            style={{
              background: 'var(--color-bg-glass-heavy)',
              borderRadius: 12,
            }}
            maskColor="rgba(0,0,0,0.08)"
          />
        </ReactFlow>
      </div>

      {/* Zoom controller */}
      <ZoomController altitude={altitude} />

      {/* Creation mode selector */}
      <CreationModeSelector
        mode={creationMode}
        onModeChange={setCreationMode}
        onCreateNode={handleCreateNode}
      />

      {/* Header */}
      <div className="fixed top-6 left-6 z-30">
        <h1
          className="font-serif text-2xl font-bold"
          style={{ color: 'var(--color-text-main)', textShadow: '0 2px 12px rgba(0,0,0,0.05)' }}
        >
          Luminous Mind
        </h1>
        <p className="font-sans text-xs" style={{ color: 'var(--color-text-muted)' }}>
          {store.nodes.length} nodes · {store.connections.length} connections
        </p>
      </div>

      {/* Context menu */}
      {contextMenu && (
        <NodeContextMenu
          node={contextMenu.node}
          position={contextMenu.position}
          onClose={() => setContextMenu(null)}
          onStatusChange={handleStatusChange}
          onEnterRoom={onEnterRoom}
          onDelete={store.deleteNode}
          onShowCalendar={setCalendarNode}
        />
      )}

      {/* Calendar overlay */}
      {calendarNode && (
        <NodeCalendar
          node={calendarNode}
          onClose={() => setCalendarNode(null)}
        />
      )}
    </div>
  )
}

// Wrapped with ReactFlowProvider
interface MindMapProps {
  initialNodes: LuminousNode[]
  initialConnections: Connection[]
  onEnterRoom: (taskId: string) => void
}

export function MindMap(props: MindMapProps) {
  return (
    <ReactFlowProvider>
      <MindMapInner {...props} />
    </ReactFlowProvider>
  )
}
