/**
 * Resonance Vault — AppFlowy Integration
 *
 * Generates AppFlowy-compatible database schemas and templates
 * for importing repository portfolios as AppFlowy pages/databases.
 *
 * Each repository → one AppFlowy "slide" (page with database view)
 * with properties, calendar, notes, and file slots.
 */

// AppFlowy Database Field Types
const FIELD_TYPES = {
  TEXT: 0,
  NUMBER: 1,
  DATETIME: 2,
  SINGLE_SELECT: 3,
  MULTI_SELECT: 4,
  CHECKBOX: 5,
  URL: 6,
  CHECKLIST: 7,
};

/**
 * Generate an AppFlowy-compatible database schema for a portfolio.
 * This can be imported into AppFlowy as a CSV or via its API.
 */
function generateAppFlowyDatabaseSchema(portfolio) {
  return {
    name: `${portfolio.callsign || portfolio.name}`,
    fields: [
      { name: 'Name', type: FIELD_TYPES.TEXT, isPrimary: true },
      { name: 'Callsign', type: FIELD_TYPES.TEXT },
      { name: 'Status', type: FIELD_TYPES.SINGLE_SELECT, options: [
        { name: 'Active', color: '#59C9A5' },
        { name: 'Paused', color: '#F4A261' },
        { name: 'Archived', color: '#8A9C91' },
      ]},
      { name: 'Language', type: FIELD_TYPES.SINGLE_SELECT, options: [
        { name: 'JavaScript', color: '#F7DF1E' },
        { name: 'TypeScript', color: '#3178C6' },
        { name: 'Python', color: '#3776AB' },
        { name: 'Go', color: '#00ADD8' },
        { name: 'Rust', color: '#DEA584' },
        { name: 'Dart', color: '#0175C2' },
        { name: 'Markdown', color: '#083FA1' },
      ]},
      { name: 'Original URL', type: FIELD_TYPES.URL },
      { name: 'Upload Date', type: FIELD_TYPES.DATETIME },
      { name: 'Last Sync', type: FIELD_TYPES.DATETIME },
      { name: 'Stars', type: FIELD_TYPES.NUMBER },
      { name: 'Forks', type: FIELD_TYPES.NUMBER },
      { name: 'Issues', type: FIELD_TYPES.NUMBER },
      { name: 'License', type: FIELD_TYPES.TEXT },
      { name: 'Topics', type: FIELD_TYPES.MULTI_SELECT },
      { name: 'Visibility', type: FIELD_TYPES.SINGLE_SELECT, options: [
        { name: 'Public', color: '#59C9A5' },
        { name: 'Private', color: '#EF6461' },
      ]},
      { name: 'Size (MB)', type: FIELD_TYPES.NUMBER },
      { name: 'Project Hash', type: FIELD_TYPES.TEXT },
      { name: 'Kopia Snapshot', type: FIELD_TYPES.TEXT },
      { name: 'Secrets', type: FIELD_TYPES.TEXT },      // Encrypted
      { name: 'Notes', type: FIELD_TYPES.TEXT },
      { name: 'Backed Up', type: FIELD_TYPES.CHECKBOX },
    ],
    views: [
      { name: 'Gallery', type: 'grid' },    // Database grid view
      { name: 'Calendar', type: 'calendar', dateField: 'Last Sync' },
      { name: 'Board', type: 'board', groupField: 'Status' },
    ],
  };
}

/**
 * Generate a CSV-importable row for a portfolio
 */
function portfolioToCSVRow(portfolio) {
  return [
    portfolio.name,
    portfolio.callsign || '',
    portfolio.status || 'active',
    portfolio.language || '',
    portfolio.original_url || '',
    portfolio.uploaded_at || '',
    portfolio.last_sync || '',
    portfolio.stars || 0,
    portfolio.forks || 0,
    portfolio.open_issues || 0,
    portfolio.license || '',
    (portfolio.topics || []).join(';'),
    portfolio.visibility || 'public',
    portfolio.size_kb ? (portfolio.size_kb / 1024).toFixed(1) : 0,
    portfolio.project_hash || '',
    portfolio.kopia_snapshot_id || '',
    '',  // secrets (empty for export)
    portfolio.notes || '',
    portfolio.kopia_snapshot_id ? 'true' : 'false',
  ].map(v => `"${String(v).replace(/"/g, '""')}"`).join(',');
}

/**
 * Generate full CSV export for all portfolios
 */
function generateCSVExport(portfolios) {
  const headers = [
    'Name', 'Callsign', 'Status', 'Language', 'Original URL',
    'Upload Date', 'Last Sync', 'Stars', 'Forks', 'Issues',
    'License', 'Topics', 'Visibility', 'Size (MB)', 'Project Hash',
    'Kopia Snapshot', 'Secrets', 'Notes', 'Backed Up',
  ].join(',');

  const rows = portfolios.map(portfolioToCSVRow);
  return [headers, ...rows].join('\n');
}

/**
 * Generate AppFlowy page template for a single portfolio
 * (Markdown format that AppFlowy can import)
 */
function generateAppFlowyPageTemplate(portfolio) {
  return `# ${portfolio.callsign || 'Operation: ' + portfolio.name}

## ${portfolio.name}

${portfolio.description || ''}

---

### Properties

| Property | Value |
|----------|-------|
| Language | ${portfolio.language || '—'} |
| License | ${portfolio.license || '—'} |
| Branch | ${portfolio.default_branch || '—'} |
| Visibility | ${portfolio.visibility || '—'} |
| Size | ${portfolio.size_kb ? (portfolio.size_kb / 1024).toFixed(1) + ' MB' : '—'} |
| Stars | ${portfolio.stars || 0} |
| Forks | ${portfolio.forks || 0} |
| Open Issues | ${portfolio.open_issues || 0} |

### Origin

- **URL:** ${portfolio.original_url || '—'}
- **Uploaded:** ${portfolio.uploaded_at || '—'}
- **Last Sync:** ${portfolio.last_sync || '—'}

### Topics

${(portfolio.topics || []).map(t => `\`${t}\``).join(' ') || '—'}

### Notes

${portfolio.notes || '_Begin writing notes here..._'}

### File Slots

| Slot | Files |
|------|-------|
| Source Code | ${(portfolio.files || []).filter(f => f.slot === 'source').map(f => f.name).join(', ') || '—'} |
| Design Files | ${(portfolio.files || []).filter(f => f.slot === 'design').map(f => f.name).join(', ') || '_Drop files here_'} |
| Documentation | ${(portfolio.files || []).filter(f => f.slot === 'docs').map(f => f.name).join(', ') || '_Drop files here_'} |
| Configuration | ${(portfolio.files || []).filter(f => f.slot === 'config').map(f => f.name).join(', ') || '_Drop files here_'} |
| Assets | ${(portfolio.files || []).filter(f => f.slot === 'asset').map(f => f.name).join(', ') || '_Drop files here_'} |
| Tests | ${(portfolio.files || []).filter(f => f.slot === 'test').map(f => f.name).join(', ') || '_Drop files here_'} |

### Collaborators

${(portfolio.collaborators || []).map(c => `- **${c.name}** (${c.role}) — ${c.email}`).join('\n') || '_No collaborators yet_'}

### Secrets

> Encrypted fields — enter via Resonance Vault settings

---

_Generated by Resonance Vault · ${new Date().toISOString()}_
`;
}

/**
 * Kopia default settings for AppFlowy integration
 */
const APPFLOWY_KOPIA_DEFAULTS = {
  description: 'Default Kopia settings optimized for AppFlowy + Resonance Vault integration',
  repository: {
    type: 'filesystem',
    path: '{DATA_DIR}/kopia-repo',
    password: '',  // User sets on init
  },
  policy: {
    retention: {
      keepLatest: 10,
      keepDaily: 7,
      keepWeekly: 4,
      keepMonthly: 12,
      keepAnnual: 1,
    },
    compression: {
      algorithm: 'zstd',
      minSize: 1024,       // Don't compress files under 1KB
    },
    scheduling: {
      intervalSeconds: 21600,  // 6 hours
      timesOfDay: [{ hour: 2, minute: 0 }],  // Nightly full backup
    },
    files: {
      ignore: [
        'node_modules/**',
        '.git/objects/**',
        '*.log',
        '.DS_Store',
        'Thumbs.db',
        '__pycache__/**',
        'target/debug/**',
        'build/**',
      ],
      maxFileSize: 104857600,  // 100MB max file size
    },
  },
};

module.exports = {
  generateAppFlowyDatabaseSchema,
  portfolioToCSVRow,
  generateCSVExport,
  generateAppFlowyPageTemplate,
  APPFLOWY_KOPIA_DEFAULTS,
  FIELD_TYPES,
};
