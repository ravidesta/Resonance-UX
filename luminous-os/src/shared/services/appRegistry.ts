export interface AppRegistration {
  id: string
  name: string
  icon: string
  description: string
  status: 'live' | 'development' | 'planned'
  integrations: {
    journal: boolean
    emailList: boolean
    bookReader: boolean
    courseGenerator: boolean
    mindMap: boolean
  }
  dataFlow: {
    reads: string[]
    writes: string[]
  }
  tier: 'free' | 'flow' | 'matrix'
}

export const appRegistry: AppRegistration[] = [
  {
    id: 'sanctuary-writer',
    name: 'Sanctuary Writer',
    icon: 'Feather',
    description: 'Distraction-free writing with Luminize AI prose enhancement',
    status: 'live',
    integrations: { journal: true, emailList: false, bookReader: false, courseGenerator: false, mindMap: true },
    dataFlow: { reads: ['UserProfile', 'Documents'], writes: ['Documents', 'Journal'] },
    tier: 'free',
  },
  {
    id: 'integral-self',
    name: 'Integral Self',
    icon: 'Compass',
    description: 'Developmental assessment & signature mapping',
    status: 'live',
    integrations: { journal: true, emailList: false, bookReader: false, courseGenerator: true, mindMap: true },
    dataFlow: { reads: ['UserProfile'], writes: ['UserProfile', 'Signature'] },
    tier: 'flow',
  },
  {
    id: 'social-media-generator',
    name: 'Social Media Generator',
    icon: 'Share2',
    description: 'Campaign-aware content generation across platforms',
    status: 'live',
    integrations: { journal: false, emailList: true, bookReader: false, courseGenerator: false, mindMap: true },
    dataFlow: { reads: ['Campaigns', 'UserProfile'], writes: ['SocialContent', 'Campaigns'] },
    tier: 'flow',
  },
  {
    id: 'astrology-report',
    name: 'Astrology Report Generator',
    icon: 'Star',
    description: 'Archetypal data generation for person nodes',
    status: 'live',
    integrations: { journal: true, emailList: false, bookReader: false, courseGenerator: false, mindMap: true },
    dataFlow: { reads: ['PersonNodes'], writes: ['PersonNodes', 'Reports'] },
    tier: 'flow',
  },
  {
    id: 'bespoke-course-store',
    name: 'Bespoke Course Store',
    icon: 'GraduationCap',
    description: 'AI-generated courses from the 577-book corpus',
    status: 'development',
    integrations: { journal: false, emailList: true, bookReader: true, courseGenerator: true, mindMap: true },
    dataFlow: { reads: ['Books', 'Signature', 'Holocron'], writes: ['Courses', 'Progress'] },
    tier: 'matrix',
  },
  {
    id: 'market-intelligence',
    name: 'Market Intelligence Report',
    icon: 'TrendingUp',
    description: 'AI-powered market analysis feeding campaign strategy',
    status: 'development',
    integrations: { journal: false, emailList: false, bookReader: false, courseGenerator: false, mindMap: true },
    dataFlow: { reads: ['Campaigns', 'ExternalData'], writes: ['Reports', 'Campaigns'] },
    tier: 'matrix',
  },
  {
    id: 'magic-phone',
    name: 'Magic Phone',
    icon: 'Phone',
    description: 'Click-to-call from person nodes with VoIP integration',
    status: 'planned',
    integrations: { journal: true, emailList: false, bookReader: false, courseGenerator: false, mindMap: true },
    dataFlow: { reads: ['PersonNodes', 'Contacts'], writes: ['CallLog', 'Journal'] },
    tier: 'matrix',
  },
  {
    id: 'luminous-browser',
    name: 'Luminous Browser',
    icon: 'Globe',
    description: 'Lumina Chromium shell with LDL CSS injection',
    status: 'planned',
    integrations: { journal: false, emailList: false, bookReader: true, courseGenerator: false, mindMap: true },
    dataFlow: { reads: ['Bookmarks', 'UserProfile'], writes: ['Bookmarks', 'BrowsingContext'] },
    tier: 'matrix',
  },
]

export const pricingTiers = [
  { id: 'free', name: 'Luminous Seed', price: 0, description: 'Mind map + 3 apps', features: ['Luminous Mind (basic)', 'Sanctuary Writer', '5 activity cards/month'] },
  { id: 'sprout', name: 'Luminous Sprout', price: 10, description: 'More apps + rooms', features: ['Everything in Seed', '3 Luminous Rooms', '20 activity cards/month', 'Calendar sync'] },
  { id: 'flow', name: 'Luminous Flow', price: 30, description: 'Full creative suite', features: ['Everything in Sprout', 'Unlimited Rooms', 'All live apps', 'Golden Hour Timer', 'Course generation'] },
  { id: 'matrix', name: 'Matrix Room', price: 50, description: 'The whole ecosystem', features: ['Everything in Flow', 'All apps (including planned)', 'Unlimited courses', 'Collaboration rooms', 'API access', 'Priority support'] },
]
