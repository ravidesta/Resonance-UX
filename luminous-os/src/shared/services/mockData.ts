import type { LuminousNode } from '@/shared/types/node'
import type { Connection } from '@/shared/types/connection'

export const mockNodes: LuminousNode[] = [
  // === PORTFOLIOS (depth 0) ===
  {
    id: 'p1', type: 'portfolio', title: 'Luminous Leadership', icon: 'Sparkles',
    status: 'flowering', description: 'The entire Luminous ecosystem',
    calendar: { events: [], goldenHourMinutes: 240 },
    links: { urls: [], apps: ['sanctuary-writer', 'integral-self'], contacts: [], documents: [] },
    children: ['c1', 'c2'], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: ['p2'] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-01-15T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },
  {
    id: 'p2', type: 'portfolio', title: 'App Cultivation', icon: 'Sprout',
    status: 'growing', description: 'The 17-app archipelago',
    calendar: { events: [], goldenHourMinutes: 180 },
    links: { urls: [], apps: [], contacts: [], documents: [] },
    children: ['c3'], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: ['p1'] },
    coverImage: null, backgroundEnvironment: 'digital-glass',
    createdAt: '2026-02-01T00:00:00Z', updatedAt: '2026-03-18T00:00:00Z',
  },
  {
    id: 'p3', type: 'portfolio', title: 'RSD Book Series', icon: 'BookOpen',
    status: 'germinating', description: 'The 577-book corpus and course generation pipeline',
    calendar: { events: [], goldenHourMinutes: 120 },
    links: { urls: [], apps: ['book-reader', 'course-generator'], contacts: [], documents: [] },
    children: ['b1', 'b2'], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'ancient-forest',
    createdAt: '2026-01-20T00:00:00Z', updatedAt: '2026-03-15T00:00:00Z',
  },

  // === CAMPAIGNS (depth 1) ===
  {
    id: 'c1', type: 'campaign', title: 'Q2 Product Launch', icon: 'Rocket',
    status: 'growing', description: 'Launch Luminous Mind + Rooms to early adopters',
    calendar: { events: [
      { id: 'e1', title: 'Launch Day', start: '2026-04-15', end: '2026-04-15', type: 'deadline' },
    ], goldenHourMinutes: 120 },
    links: { urls: [{ label: 'Launch Plan', href: '#' }], apps: [], contacts: ['person1'], documents: [] },
    children: ['proj1', 'proj2'], parent: 'p1', depth: 1,
    aiContext: { suggestedTools: ['Notion', 'Figma'], suggestedOrder: 1, estimatedMinutes: 480, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-02-10T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },
  {
    id: 'c2', type: 'campaign', title: 'Ocean Tomo Pitch', icon: 'Anchor',
    status: 'germinating', description: 'IP valuation and investor pitch',
    calendar: { events: [
      { id: 'e2', title: 'Pitch Meeting', start: '2026-04-22', end: '2026-04-22', type: 'meeting' },
    ], goldenHourMinutes: 90 },
    links: { urls: [], apps: [], contacts: ['person2'], documents: [] },
    children: ['proj3'], parent: 'p1', depth: 1,
    aiContext: { suggestedTools: ['Keynote', 'Numbers'], suggestedOrder: 2, estimatedMinutes: 360, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'digital-glass',
    createdAt: '2026-03-01T00:00:00Z', updatedAt: '2026-03-18T00:00:00Z',
  },
  {
    id: 'c3', type: 'campaign', title: 'Phase 0 Pipeline', icon: 'Workflow',
    status: 'growing', description: 'Deep content intelligence infrastructure',
    calendar: { events: [], goldenHourMinutes: 180 },
    links: { urls: [], apps: ['transmutation-engine'], contacts: [], documents: [] },
    children: ['proj4'], parent: 'p2', depth: 1,
    aiContext: { suggestedTools: ['Azure', 'Claude'], suggestedOrder: 1, estimatedMinutes: 600, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'bioluminescent-deep',
    createdAt: '2026-02-15T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },

  // === PROJECTS (depth 2) ===
  {
    id: 'proj1', type: 'project', title: 'Luminous Mind Build', icon: 'Brain',
    status: 'growing', description: 'Build the spatial mind map OS',
    calendar: { events: [
      { id: 'e3', title: 'Sprint 1 End', start: '2026-03-28', end: '2026-03-28', type: 'deadline' },
    ], goldenHourMinutes: 120 },
    links: { urls: [{ label: 'GitHub', href: '#' }, { label: 'Figma', href: '#' }], apps: ['claude', 'github'], contacts: [], documents: [] },
    children: ['t1', 't2', 't3'], parent: 'c1', depth: 2,
    aiContext: { suggestedTools: ['VS Code', 'Claude', 'React'], suggestedOrder: 1, estimatedMinutes: 2400, relatedNodes: ['proj2'] },
    coverImage: null, backgroundEnvironment: 'digital-glass',
    createdAt: '2026-03-01T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },
  {
    id: 'proj2', type: 'project', title: 'Golden Hour Timer', icon: 'Sun',
    status: 'flowering', description: 'The sacred timer — time as liturgy, not deficit',
    calendar: { events: [], goldenHourMinutes: 90 },
    links: { urls: [], apps: [], contacts: [], documents: [] },
    children: ['t4', 't5'], parent: 'c1', depth: 2,
    aiContext: { suggestedTools: ['Framer Motion', 'Web Audio API'], suggestedOrder: 2, estimatedMinutes: 480, relatedNodes: ['proj1'] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-03-05T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },
  {
    id: 'proj3', type: 'project', title: 'IP Valuation Deck', icon: 'PresentationChart',
    status: 'germinating', description: 'Prepare IP portfolio presentation for Ocean Tomo',
    calendar: { events: [], goldenHourMinutes: 60 },
    links: { urls: [], apps: ['keynote'], contacts: ['person2'], documents: [] },
    children: ['t6'], parent: 'c2', depth: 2,
    aiContext: { suggestedTools: ['Keynote', 'Numbers', 'Claude'], suggestedOrder: 1, estimatedMinutes: 720, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-03-10T00:00:00Z', updatedAt: '2026-03-15T00:00:00Z',
  },
  {
    id: 'proj4', type: 'project', title: 'Holocron Corpus Feeding', icon: 'Database',
    status: 'growing', description: 'Vectorize and index the 577-book corpus',
    calendar: { events: [], goldenHourMinutes: 180 },
    links: { urls: [], apps: ['azure-ai-search'], contacts: [], documents: [] },
    children: ['t7'], parent: 'c3', depth: 2,
    aiContext: { suggestedTools: ['Azure AI Search', 'Python', 'Claude'], suggestedOrder: 1, estimatedMinutes: 1200, relatedNodes: ['b1'] },
    coverImage: null, backgroundEnvironment: 'bioluminescent-deep',
    createdAt: '2026-02-20T00:00:00Z', updatedAt: '2026-03-18T00:00:00Z',
  },

  // === TASKS (depth 3) ===
  {
    id: 't1', type: 'task', title: 'Force-directed graph layout', icon: 'GitBranch',
    status: 'harvested', description: 'Implement D3 force simulation for organic node positioning',
    calendar: { events: [
      { id: 'e4', title: 'Deep Work', start: '2026-03-19T09:00:00', end: '2026-03-19T12:00:00', type: 'timeblock' },
    ], goldenHourMinutes: 180 },
    links: { urls: [{ label: 'D3 Force docs', href: '#' }], apps: ['vs-code'], contacts: [], documents: [] },
    children: [], parent: 'proj1', depth: 3,
    aiContext: { suggestedTools: ['D3.js', 'React Flow'], suggestedOrder: 1, estimatedMinutes: 180, relatedNodes: ['t2'] },
    coverImage: null, backgroundEnvironment: 'digital-glass',
    createdAt: '2026-03-15T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },
  {
    id: 't2', type: 'task', title: 'Custom node renderers', icon: 'Palette',
    status: 'growing', description: 'Build glassmorphism node components for all 10 types',
    calendar: { events: [], goldenHourMinutes: 240 },
    links: { urls: [], apps: ['vs-code', 'figma'], contacts: [], documents: [] },
    children: [], parent: 'proj1', depth: 3,
    aiContext: { suggestedTools: ['React', 'Tailwind', 'Lucide'], suggestedOrder: 2, estimatedMinutes: 240, relatedNodes: ['t1'] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-03-16T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },
  {
    id: 't3', type: 'task', title: 'Semantic zoom controller', icon: 'ZoomIn',
    status: 'dormant', description: 'Map zoom level to altitude 0-5 with progressive detail',
    calendar: { events: [], goldenHourMinutes: 120 },
    links: { urls: [], apps: ['vs-code'], contacts: [], documents: [] },
    children: [], parent: 'proj1', depth: 3,
    aiContext: { suggestedTools: ['React Flow', 'Framer Motion'], suggestedOrder: 3, estimatedMinutes: 120, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'digital-glass',
    createdAt: '2026-03-17T00:00:00Z', updatedAt: '2026-03-17T00:00:00Z',
  },
  {
    id: 't4', type: 'task', title: 'Timer phase transitions', icon: 'Clock',
    status: 'flowering', description: 'Implement Morning → Full Day → Golden Hour → Complete with CSS shifts',
    calendar: { events: [], goldenHourMinutes: 120 },
    links: { urls: [], apps: ['vs-code'], contacts: [], documents: [] },
    children: [], parent: 'proj2', depth: 3,
    aiContext: { suggestedTools: ['Framer Motion', 'CSS Variables'], suggestedOrder: 1, estimatedMinutes: 180, relatedNodes: ['t5'] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-03-14T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },
  {
    id: 't5', type: 'task', title: 'Completion chime & bell', icon: 'Bell',
    status: 'growing', description: 'Meditation bowl sound at completion, not an alarm',
    calendar: { events: [], goldenHourMinutes: 60 },
    links: { urls: [], apps: ['audacity'], contacts: [], documents: [] },
    children: [], parent: 'proj2', depth: 3,
    aiContext: { suggestedTools: ['Web Audio API'], suggestedOrder: 2, estimatedMinutes: 60, relatedNodes: ['t4'] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-03-15T00:00:00Z', updatedAt: '2026-03-18T00:00:00Z',
  },
  {
    id: 't6', type: 'task', title: 'Draft pitch narrative', icon: 'PenTool',
    status: 'dormant', description: 'Write the story that makes Ocean Tomo see the vision',
    calendar: { events: [], goldenHourMinutes: 120 },
    links: { urls: [], apps: ['sanctuary-writer'], contacts: ['person2'], documents: [] },
    children: [], parent: 'proj3', depth: 3,
    aiContext: { suggestedTools: ['Sanctuary Writer', 'Claude'], suggestedOrder: 1, estimatedMinutes: 240, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-03-12T00:00:00Z', updatedAt: '2026-03-12T00:00:00Z',
  },
  {
    id: 't7', type: 'task', title: 'Vectorize first 50 books', icon: 'Cpu',
    status: 'growing', description: 'Run embedding pipeline on the first batch of the corpus',
    calendar: { events: [], goldenHourMinutes: 180 },
    links: { urls: [], apps: ['azure-ai-search', 'python'], contacts: [], documents: [] },
    children: [], parent: 'proj4', depth: 3,
    aiContext: { suggestedTools: ['Python', 'Azure AI Search', 'OpenAI Embeddings'], suggestedOrder: 1, estimatedMinutes: 360, relatedNodes: ['b1'] },
    coverImage: null, backgroundEnvironment: 'bioluminescent-deep',
    createdAt: '2026-03-10T00:00:00Z', updatedAt: '2026-03-18T00:00:00Z',
  },

  // === APP NODES ===
  {
    id: 'app1', type: 'app', title: 'Sanctuary Writer', icon: 'Feather',
    status: 'harvested', description: 'Distraction-free writing with Luminize AI',
    calendar: { events: [], goldenHourMinutes: 0 },
    links: { urls: [{ label: 'Live App', href: '#' }], apps: [], contacts: [], documents: [] },
    children: [], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2025-12-01T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },
  {
    id: 'app2', type: 'app', title: 'Integral Self', icon: 'Compass',
    status: 'growing', description: 'Developmental assessment & signature mapping',
    calendar: { events: [], goldenHourMinutes: 0 },
    links: { urls: [], apps: [], contacts: [], documents: [] },
    children: [], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'ancient-forest',
    createdAt: '2026-01-15T00:00:00Z', updatedAt: '2026-03-15T00:00:00Z',
  },
  {
    id: 'app3', type: 'app', title: 'Social Media Generator', icon: 'Share2',
    status: 'growing', description: 'Campaign-aware content generation',
    calendar: { events: [], goldenHourMinutes: 0 },
    links: { urls: [], apps: [], contacts: [], documents: [] },
    children: [], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'digital-glass',
    createdAt: '2026-02-01T00:00:00Z', updatedAt: '2026-03-10T00:00:00Z',
  },

  // === PERSON NODES ===
  {
    id: 'person1', type: 'person', title: 'The Dev Team', icon: 'Users',
    status: 'growing', description: 'Core engineering collaborators',
    calendar: { events: [
      { id: 'e5', title: 'Weekly Sync', start: '2026-03-20T10:00:00', end: '2026-03-20T11:00:00', type: 'meeting' },
    ], goldenHourMinutes: 0 },
    links: { urls: [], apps: [], contacts: [], documents: [] },
    children: [], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-01-01T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },
  {
    id: 'person2', type: 'person', title: 'Ocean Tomo Contact', icon: 'User',
    status: 'germinating', description: 'IP valuation partner',
    calendar: { events: [], goldenHourMinutes: 0 },
    links: { urls: [], apps: [], contacts: [], documents: [] },
    children: [], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-03-01T00:00:00Z', updatedAt: '2026-03-10T00:00:00Z',
  },

  // === BOOK NODES ===
  {
    id: 'b1', type: 'book', title: 'Integral Psychology', icon: 'BookOpen',
    status: 'harvested', description: 'Ken Wilber — Consciousness, Spirit, Psychology, Therapy',
    calendar: { events: [], goldenHourMinutes: 0 },
    links: { urls: [], apps: ['book-reader'], contacts: [], documents: [] },
    children: [], parent: 'p3', depth: 1,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: ['b2'] },
    coverImage: null, backgroundEnvironment: 'ancient-forest',
    createdAt: '2026-01-20T00:00:00Z', updatedAt: '2026-02-15T00:00:00Z',
  },
  {
    id: 'b2', type: 'book', title: 'Dabrowski\'s Theory of Positive Disintegration', icon: 'BookOpen',
    status: 'growing', description: 'The foundational text for developmental theory in the Luminous system',
    calendar: { events: [], goldenHourMinutes: 0 },
    links: { urls: [], apps: ['book-reader'], contacts: [], documents: [] },
    children: [], parent: 'p3', depth: 1,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: ['b1'] },
    coverImage: null, backgroundEnvironment: 'ancient-forest',
    createdAt: '2026-01-25T00:00:00Z', updatedAt: '2026-03-10T00:00:00Z',
  },

  // === DOCUMENT NODE ===
  {
    id: 'doc1', type: 'document', title: 'Claude Code Brief: Three Environments', icon: 'FileText',
    status: 'flowering', description: 'Architecture spec for Mind, Rooms, and Engine',
    calendar: { events: [], goldenHourMinutes: 0 },
    links: { urls: [], apps: ['sanctuary-writer'], contacts: [], documents: [] },
    children: [], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: ['proj1'] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-03-19T00:00:00Z', updatedAt: '2026-03-19T00:00:00Z',
  },

  // === COURSE NODE ===
  {
    id: 'course1', type: 'course', title: 'Integral Psychology: Embodied', icon: 'GraduationCap',
    status: 'germinating', description: 'AI-generated course from Integral Psychology book',
    calendar: { events: [], goldenHourMinutes: 0 },
    links: { urls: [], apps: ['course-player'], contacts: [], documents: [] },
    children: [], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: ['b1'] },
    coverImage: null, backgroundEnvironment: 'ancient-forest',
    createdAt: '2026-03-15T00:00:00Z', updatedAt: '2026-03-18T00:00:00Z',
  },

  // === ALBUM NODE ===
  {
    id: 'album1', type: 'album', title: 'Design Explorations', icon: 'Image',
    status: 'growing', description: 'Mood boards, wireframes, and visual references',
    calendar: { events: [], goldenHourMinutes: 0 },
    links: { urls: [], apps: [], contacts: [], documents: [] },
    children: [], parent: null, depth: 0,
    aiContext: { suggestedTools: [], suggestedOrder: 0, estimatedMinutes: 0, relatedNodes: [] },
    coverImage: null, backgroundEnvironment: 'smooth-vellum',
    createdAt: '2026-02-01T00:00:00Z', updatedAt: '2026-03-15T00:00:00Z',
  },
]

export const mockConnections: Connection[] = [
  // Portfolio relationships
  { id: 'conn1', source: 'p1', target: 'p2', type: 'relates' },
  { id: 'conn2', source: 'p3', target: 'p2', type: 'feeds' },

  // App → Project feeds
  { id: 'conn3', source: 'app1', target: 'proj1', type: 'feeds' },
  { id: 'conn4', source: 'app2', target: 'p1', type: 'feeds' },
  { id: 'conn5', source: 'app3', target: 'c1', type: 'feeds' },

  // Person involvement
  { id: 'conn6', source: 'person1', target: 'proj1', type: 'involves' },
  { id: 'conn7', source: 'person1', target: 'proj2', type: 'involves' },
  { id: 'conn8', source: 'person2', target: 'c2', type: 'involves' },

  // Book generates course
  { id: 'conn9', source: 'b1', target: 'course1', type: 'generates' },

  // Document relates to project
  { id: 'conn10', source: 'doc1', target: 'proj1', type: 'relates' },

  // Cross-project inspiration
  { id: 'conn11', source: 'proj2', target: 'proj1', type: 'inspires' },

  // Task dependencies
  { id: 'conn12', source: 't1', target: 't2', type: 'requires' },

  // Book feeds into vectorization
  { id: 'conn13', source: 'b1', target: 't7', type: 'feeds' },
  { id: 'conn14', source: 'b2', target: 't7', type: 'feeds' },

  // Album relates to projects
  { id: 'conn15', source: 'album1', target: 'proj1', type: 'relates' },
]
