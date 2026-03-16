/**
 * Resonance Vault — Database Layer
 * SQLite-backed portfolio & repository database with full schema
 */

const DB_NAME = 'resonance_vault';

// Schema for the in-browser IndexedDB (mirrors the server-side SQLite)
const SCHEMA = {
  portfolios: {
    id: 'TEXT PRIMARY KEY',
    name: 'TEXT NOT NULL',
    callsign: 'TEXT',           // "Operation: <repo-name>"
    original_url: 'TEXT',
    description: 'TEXT',
    language: 'TEXT',
    color: 'TEXT DEFAULT "#59C9A5"',
    icon: 'TEXT',
    logo_svg: 'TEXT',
    status: 'TEXT DEFAULT "active"', // active | paused | archived
    created_at: 'TEXT',
    uploaded_at: 'TEXT',
    last_sync: 'TEXT',
    kopia_snapshot_id: 'TEXT',
    kopia_policy: 'TEXT',
    stars: 'INTEGER DEFAULT 0',
    forks: 'INTEGER DEFAULT 0',
    open_issues: 'INTEGER DEFAULT 0',
    license: 'TEXT',
    topics: 'TEXT',             // JSON array
    default_branch: 'TEXT',
    visibility: 'TEXT',
    size_kb: 'INTEGER DEFAULT 0',
    notes: 'TEXT',
    landing_page_html: 'TEXT',
    secrets_encrypted: 'TEXT',  // encrypted JSON
    collaborators: 'TEXT',      // JSON array of {name, email, role, invited_at}
  },

  files: {
    id: 'TEXT PRIMARY KEY',
    portfolio_id: 'TEXT REFERENCES portfolios(id)',
    filename: 'TEXT NOT NULL',
    filepath: 'TEXT',
    slot_type: 'TEXT',          // source | design | docs | config | asset | build | test
    mime_type: 'TEXT',
    size_bytes: 'INTEGER',
    hash_sha256: 'TEXT',
    uploaded_at: 'TEXT',
    kopia_object_id: 'TEXT',
  },

  calendar_entries: {
    id: 'TEXT PRIMARY KEY',
    portfolio_id: 'TEXT REFERENCES portfolios(id)',
    event_type: 'TEXT',         // upload | sync | change | backup | restore | bitstamp
    title: 'TEXT',
    notes: 'TEXT',
    timestamp: 'TEXT',
    bitstamp_hash: 'TEXT',      // hash anchored to openbitstamp.org or similar
    bitstamp_source: 'TEXT',    // which timestamping service
    bitstamp_tx: 'TEXT',        // transaction reference
    project_hash: 'TEXT',       // SHA-256 of the project at that point
    metadata: 'TEXT',           // JSON for extra info
  },

  server_commands: {
    id: 'TEXT PRIMARY KEY',
    label: 'TEXT',
    command: 'TEXT',
    category: 'TEXT',           // file | edit | view | tools | backup | server
    description: 'TEXT',
    keybinding: 'TEXT',
    enabled: 'INTEGER DEFAULT 1',
  },

  settings: {
    key: 'TEXT PRIMARY KEY',
    value: 'TEXT',
    category: 'TEXT',           // kopia | server | ui | backup | notifications
    description: 'TEXT',
  },
};

// Default settings for Kopia integration
const DEFAULT_SETTINGS = [
  { key: 'kopia_repo_path', value: '/var/resonance-vault/kopia-repo', category: 'kopia', description: 'Local Kopia repository path' },
  { key: 'kopia_password', value: '', category: 'kopia', description: 'Kopia repository password (encrypted)' },
  { key: 'kopia_compression', value: 'zstd', category: 'kopia', description: 'Compression algorithm (zstd|gzip|none)' },
  { key: 'kopia_snapshot_interval', value: '6h', category: 'kopia', description: 'Auto-snapshot interval' },
  { key: 'kopia_retention_daily', value: '7', category: 'kopia', description: 'Keep daily snapshots for N days' },
  { key: 'kopia_retention_weekly', value: '4', category: 'kopia', description: 'Keep weekly snapshots for N weeks' },
  { key: 'kopia_retention_monthly', value: '12', category: 'kopia', description: 'Keep monthly snapshots for N months' },
  { key: 'server_port', value: '7700', category: 'server', description: 'Resonance Vault server port' },
  { key: 'server_host', value: '0.0.0.0', category: 'server', description: 'Bind address' },
  { key: 'github_token', value: '', category: 'backup', description: 'GitHub personal access token' },
  { key: 'backup_path', value: '/var/resonance-vault/backups', category: 'backup', description: 'Local backup storage path' },
  { key: 'bitstamp_enabled', value: 'true', category: 'backup', description: 'Enable bitstamp hash logging' },
  { key: 'bitstamp_sources', value: 'openbitstamp,opentimestamps', category: 'backup', description: 'Timestamping services' },
  { key: 'theme', value: 'light', category: 'ui', description: 'UI theme (light|night)' },
  { key: 'gallery_columns', value: '3', category: 'ui', description: 'Gallery mode columns' },
  { key: 'auto_analyze', value: 'true', category: 'backup', description: 'Auto-analyze projects on upload' },
  { key: 'notification_on_sync', value: 'true', category: 'notifications', description: 'Notify on successful sync' },
];

// Default server commands (file menu integration)
const DEFAULT_COMMANDS = [
  { id: 'cmd-new-portfolio', label: 'New Portfolio', command: 'portfolio:create', category: 'file', description: 'Create a new repository portfolio', keybinding: 'Ctrl+N' },
  { id: 'cmd-import-repo', label: 'Import Repository', command: 'repo:import', category: 'file', description: 'Import a GitHub repository', keybinding: 'Ctrl+I' },
  { id: 'cmd-import-bulk', label: 'Bulk Import...', command: 'repo:import-bulk', category: 'file', description: 'Import all repos from a GitHub account', keybinding: 'Ctrl+Shift+I' },
  { id: 'cmd-export-briefing', label: 'Export Portfolio Briefing', command: 'briefing:export', category: 'file', description: 'Generate printable portfolio briefing PDF', keybinding: 'Ctrl+P' },
  { id: 'cmd-save-snapshot', label: 'Save Snapshot', command: 'kopia:snapshot', category: 'file', description: 'Create Kopia snapshot now', keybinding: 'Ctrl+S' },
  { id: 'cmd-restore', label: 'Restore from Snapshot...', command: 'kopia:restore', category: 'file', description: 'Restore portfolio from Kopia backup', keybinding: 'Ctrl+Shift+R' },
  { id: 'cmd-kopia-status', label: 'Backup Status', command: 'kopia:status', category: 'tools', description: 'View Kopia repository status', keybinding: '' },
  { id: 'cmd-kopia-settings', label: 'Backup Settings...', command: 'kopia:settings', category: 'tools', description: 'Configure Kopia backup policies', keybinding: '' },
  { id: 'cmd-server-start', label: 'Start Server', command: 'server:start', category: 'server', description: 'Start the Resonance Vault server', keybinding: '' },
  { id: 'cmd-server-stop', label: 'Stop Server', command: 'server:stop', category: 'server', description: 'Stop the server gracefully', keybinding: '' },
  { id: 'cmd-server-logs', label: 'View Server Logs', command: 'server:logs', category: 'server', description: 'Open server log viewer', keybinding: '' },
  { id: 'cmd-sync-all', label: 'Sync All Repositories', command: 'sync:all', category: 'tools', description: 'Pull latest from all GitHub repos', keybinding: 'Ctrl+Shift+S' },
  { id: 'cmd-verify', label: 'Verify Integrity', command: 'kopia:verify', category: 'tools', description: 'Verify all backup integrity', keybinding: '' },
  { id: 'cmd-calendar', label: 'Open Calendar Ledger', command: 'view:calendar', category: 'view', description: 'View system calendar with all events', keybinding: 'Ctrl+K' },
  { id: 'cmd-gallery', label: 'Gallery View', command: 'view:gallery', category: 'view', description: 'Switch to portfolio gallery mode', keybinding: 'Ctrl+G' },
  { id: 'cmd-list', label: 'List View', command: 'view:list', category: 'view', description: 'Switch to list/table mode', keybinding: 'Ctrl+L' },
  { id: 'cmd-toggle-theme', label: 'Toggle Day/Night', command: 'ui:toggle-theme', category: 'view', description: 'Switch between day and night mode', keybinding: 'Ctrl+D' },
  { id: 'cmd-bitstamp', label: 'Bitstamp Anchor', command: 'bitstamp:anchor', category: 'tools', description: 'Anchor current project hash to timestamp service', keybinding: '' },
];

export { SCHEMA, DEFAULT_SETTINGS, DEFAULT_COMMANDS, DB_NAME };
