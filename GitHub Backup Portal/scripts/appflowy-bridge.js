#!/usr/bin/env node
// ═══════════════════════════════════════════════════════════════════
// APPFLOWY BRIDGE — RESONANCE GITHUB BACKUP PORTAL
// Creates and manages AppFlowy databases, calendars, and slides
// for each GitHub repository portfolio
// ═══════════════════════════════════════════════════════════════════

const fs = require('fs');
const path = require('path');
const os = require('os');

// ── AppFlowy Data Paths (Windows + iPad) ────────────────────────
const APPFLOWY_PATHS = {
  win32: path.join(os.homedir(), 'AppFlowy', 'data'),
  darwin: path.join(os.homedir(), 'Library', 'Application Support', 'AppFlowy', 'data'),
  linux: path.join(os.homedir(), '.appflowy', 'data'),
};

const DATA_PATH = APPFLOWY_PATHS[process.platform] || APPFLOWY_PATHS.linux;

// ── Schema: Portfolio Database ──────────────────────────────────
const PORTFOLIO_DB_SCHEMA = {
  name: 'GitHub Backup Portfolios',
  view_type: 'grid', // grid | board | calendar | gallery
  fields: [
    { id: 'name', name: 'Portfolio', type: 'RichText', is_primary: true },
    { id: 'callsign', name: 'Callsign', type: 'RichText' },
    { id: 'url', name: 'Repository URL', type: 'URL' },
    { id: 'status', name: 'Status', type: 'SingleSelect',
      options: [
        { name: 'Synced', color: '#59C9A5' },
        { name: 'Pending', color: '#F4A261' },
        { name: 'Error', color: '#EF6461' },
        { name: 'Backing Up', color: '#7B8CDE' },
      ]},
    { id: 'languages', name: 'Languages', type: 'MultiSelect',
      options: [
        { name: 'JavaScript', color: '#F7DF1E' },
        { name: 'TypeScript', color: '#3178C6' },
        { name: 'Python', color: '#3776AB' },
        { name: 'Go', color: '#00ADD8' },
        { name: 'Rust', color: '#CE422B' },
        { name: 'Dart', color: '#0175C2' },
        { name: 'Java', color: '#ED8B00' },
        { name: 'Swift', color: '#FA7343' },
        { name: 'C#', color: '#239120' },
        { name: 'Ruby', color: '#CC342D' },
      ]},
    { id: 'upload_date', name: 'Upload Date', type: 'DateTime' },
    { id: 'last_sync', name: 'Last Sync', type: 'DateTime' },
    { id: 'file_count', name: 'Files', type: 'Number' },
    { id: 'stars', name: 'Stars', type: 'Number' },
    { id: 'forks', name: 'Forks', type: 'Number' },
    { id: 'bitstamp', name: 'Bitstamp Hash', type: 'RichText' },
    { id: 'collaborators', name: 'Collaborators', type: 'MultiSelect' },
    { id: 'notes', name: 'Notes', type: 'RichText' },
    { id: 'secrets', name: 'Secrets', type: 'RichText' }, // Encrypted in practice
    { id: 'design_files', name: 'Design Files', type: 'RichText' },
  ],
};

// ── Schema: Calendar Ledger ─────────────────────────────────────
const CALENDAR_SCHEMA = {
  name: 'Backup Calendar Ledger',
  view_type: 'calendar',
  date_field: 'event_date',
  fields: [
    { id: 'title', name: 'Event', type: 'RichText', is_primary: true },
    { id: 'event_date', name: 'Date', type: 'DateTime' },
    { id: 'portfolio', name: 'Portfolio', type: 'SingleSelect' },
    { id: 'event_type', name: 'Type', type: 'SingleSelect',
      options: [
        { name: 'Snapshot', color: '#59C9A5' },
        { name: 'Upload', color: '#7B8CDE' },
        { name: 'Policy Check', color: '#F4A261' },
        { name: 'Bitstamp Verify', color: '#C5A059' },
        { name: 'Error', color: '#EF6461' },
        { name: 'Collaborator Added', color: '#E040FB' },
      ]},
    { id: 'bitstamp', name: 'Bitstamp Hash', type: 'RichText' },
    { id: 'notes', name: 'Notes', type: 'RichText' },
  ],
};

// ── Schema: Portfolio Slide (one per repo) ──────────────────────
function createSlideSchema(repoName, callsign) {
  return {
    name: `${callsign}`,
    type: 'document',
    children: [
      {
        type: 'heading',
        level: 1,
        text: callsign,
      },
      {
        type: 'heading',
        level: 2,
        text: repoName,
      },
      {
        type: 'divider',
      },
      {
        type: 'heading',
        level: 3,
        text: 'Portfolio Information',
      },
      {
        type: 'database_reference',
        database_id: 'portfolio_db',
        filter: { field: 'name', value: repoName },
        view: 'grid',
      },
      {
        type: 'divider',
      },
      {
        type: 'heading',
        level: 3,
        text: 'Calendar Ledger',
      },
      {
        type: 'database_reference',
        database_id: 'calendar_ledger',
        filter: { field: 'portfolio', value: repoName },
        view: 'calendar',
      },
      {
        type: 'divider',
      },
      {
        type: 'heading',
        level: 3,
        text: 'Notes & Landing Page',
      },
      {
        type: 'paragraph',
        text: '', // User fills this in
      },
      {
        type: 'divider',
      },
      {
        type: 'heading',
        level: 3,
        text: 'File Slots',
      },
      {
        type: 'grid',
        columns: 3,
        children: [
          { type: 'card', title: 'Design Files', icon: '\u25B3' },
          { type: 'card', title: 'Documentation', icon: '\u2630' },
          { type: 'card', title: 'Assets', icon: '\u25C7' },
          { type: 'card', title: 'Configuration', icon: '\u2699' },
          { type: 'card', title: 'Tests', icon: '\u2713' },
          { type: 'card', title: 'CI/CD', icon: '\u21BB' },
        ],
      },
      {
        type: 'divider',
      },
      {
        type: 'heading',
        level: 3,
        text: 'Secrets Vault',
      },
      {
        type: 'callout',
        icon: '\u26BF',
        text: 'Secrets are encrypted locally. Add key-value pairs in the database.',
      },
      {
        type: 'divider',
      },
      {
        type: 'heading',
        level: 3,
        text: 'Collaborators',
      },
      {
        type: 'paragraph',
        text: 'Invite collaborators by adding their email to the database.',
      },
    ],
  };
}

// ── Create AppFlowy Workspace Structure ─────────────────────────
function createWorkspace(portfolios) {
  const { generateCallsign, generateBitstampHash, detectLanguages } = require('./generate-pdf-report');

  const workspace = {
    name: 'Resonance GitHub Backup Portal',
    created: new Date().toISOString(),
    children: [
      // 1. Portfolio Database
      {
        ...PORTFOLIO_DB_SCHEMA,
        rows: portfolios.map(p => ({
          name: p.name,
          callsign: generateCallsign(p.name),
          url: p.url,
          status: p.status === 'synced' ? 'Synced' : p.status === 'pending' ? 'Pending' : 'Error',
          languages: detectLanguages(p.files),
          upload_date: p.uploadDate,
          last_sync: p.lastSync,
          file_count: p.files.length,
          stars: p.stars,
          forks: p.forks,
          bitstamp: generateBitstampHash(p.name + p.lastSync),
          collaborators: p.collaborators,
          notes: p.notes,
          secrets: '', // Encrypted separately
          design_files: p.designFiles.join(', '),
        })),
      },
      // 2. Calendar Ledger
      {
        ...CALENDAR_SCHEMA,
        rows: portfolios.flatMap(p => [
          {
            title: `Kopia snapshot: ${p.name}`,
            event_date: p.lastSync,
            portfolio: p.name,
            event_type: 'Snapshot',
            bitstamp: generateBitstampHash(p.name + p.lastSync),
            notes: `Automated snapshot for ${p.name}`,
          },
          {
            title: `Initial upload: ${p.name}`,
            event_date: p.uploadDate,
            portfolio: p.name,
            event_type: 'Upload',
            bitstamp: generateBitstampHash(p.name + p.uploadDate),
            notes: `First backup of ${p.name}`,
          },
        ]),
      },
      // 3. Individual Slides (one per portfolio)
      ...portfolios.map(p =>
        createSlideSchema(p.name, generateCallsign(p.name))
      ),
    ],
  };

  return workspace;
}

// ── Export Workspace to JSON ────────────────────────────────────
function exportWorkspace(portfolios, outputPath) {
  const workspace = createWorkspace(portfolios);
  fs.writeFileSync(outputPath, JSON.stringify(workspace, null, 2));
  console.log(`AppFlowy workspace exported: ${outputPath}`);
  return workspace;
}

// ── CLI Entry Point ─────────────────────────────────────────────
if (require.main === module) {
  const args = process.argv.slice(2);

  console.log('╔══════════════════════════════════════════════════════╗');
  console.log('║  Resonance — AppFlowy Bridge                        ║');
  console.log('╚══════════════════════════════════════════════════════╝\n');

  // Default portfolios
  const portfolios = [
    {
      id: 1, name: 'Resonance-UX', url: 'https://github.com/ravidesta/Resonance-UX',
      description: 'Calm productivity UX', files: ['App.js', 'index.js', 'package.json'],
      uploadDate: '2026-03-14T10:30:00Z', lastSync: '2026-03-16T08:15:00Z',
      stars: 12, forks: 3, status: 'synced', notes: 'Core UX framework.',
      collaborators: ['elena@resonance.dev'], designFiles: ['mockups.fig'],
    },
    {
      id: 2, name: 'kopia', url: 'https://github.com/ravidesta/kopia',
      description: 'Backup tool', files: ['main.go', 'go.mod'],
      uploadDate: '2026-03-10T14:00:00Z', lastSync: '2026-03-16T07:00:00Z',
      stars: 5200, forks: 380, status: 'synced', notes: 'Backup engine.',
      collaborators: [], designFiles: [],
    },
    {
      id: 3, name: 'AppFlowy', url: 'https://github.com/ravidesta/AppFlowy',
      description: 'Notion alternative', files: ['pubspec.yaml', 'lib/main.dart'],
      uploadDate: '2026-03-12T09:00:00Z', lastSync: '2026-03-15T22:30:00Z',
      stars: 48000, forks: 3100, status: 'pending', notes: 'Database engine.',
      collaborators: ['dev@appflowy.io'], designFiles: ['ui-components.fig'],
    },
    {
      id: 4, name: 'design', url: 'https://github.com/ravidesta/design',
      description: 'Luminous design system', files: ['book'],
      uploadDate: '2026-03-13T16:45:00Z', lastSync: '2026-03-16T06:00:00Z',
      stars: 8, forks: 1, status: 'synced', notes: 'Living design system.',
      collaborators: [], designFiles: ['book', 'chromatic-orb.svg'],
    },
  ];

  const outputPath = args[0] || path.join(process.cwd(), 'appflowy-workspace.json');
  exportWorkspace(portfolios, outputPath);

  console.log('\nSchemas created:');
  console.log('  - Portfolio Database (grid view with all properties)');
  console.log('  - Calendar Ledger (calendar view with bitstamp events)');
  portfolios.forEach(p => {
    const { generateCallsign } = require('./generate-pdf-report');
    console.log(`  - Slide: ${generateCallsign(p.name)}`);
  });
}

module.exports = {
  PORTFOLIO_DB_SCHEMA,
  CALENDAR_SCHEMA,
  createSlideSchema,
  createWorkspace,
  exportWorkspace,
};
