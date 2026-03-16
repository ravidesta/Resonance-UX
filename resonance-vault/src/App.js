import React, { useState, useCallback, useEffect } from 'react';
import './styles/resonance-tokens.css';
import { DEFAULT_SETTINGS, DEFAULT_COMMANDS } from './utils/database';
import { hashString, formatBitstampEntry, TIMESTAMP_SERVICES } from './utils/bitstamp';
import { generatePortfolioLogo, generateCallsign, LANGUAGE_ICONS } from './utils/logo-generator';

/* ═══════════════════════════════════════════════════════════════
   RESONANCE VAULT — GitHub Backup & Portfolio System
   A Luminous OS experience for repository management
   ═══════════════════════════════════════════════════════════════ */

// ── Sample Data ──
const SAMPLE_PORTFOLIOS = [
  {
    id: 'p1', name: 'Resonance-UX', callsign: 'Operation: Resonance UX',
    original_url: 'https://github.com/ravidesta/Resonance-UX',
    description: 'Calm, intentional UI/UX design system with bioluminescent aesthetics',
    language: 'JavaScript', color: '#59C9A5', status: 'active',
    created_at: '2025-11-15T10:00:00Z', uploaded_at: '2026-03-16T08:00:00Z',
    last_sync: '2026-03-16T14:30:00Z', stars: 12, forks: 3, open_issues: 2,
    license: 'MIT', topics: ['design-system', 'react', 'ux', 'calm-tech'],
    default_branch: 'main', visibility: 'public', size_kb: 2048,
    notes: 'Core design system for the Luminous ecosystem. Implements bioluminescent glow, living surfaces, and chromatic intelligence.',
    collaborators: [
      { name: 'Ravi Desta', role: 'owner', email: 'ravi@resonance.dev' },
      { name: 'Luna Chen', role: 'contributor', email: 'luna@dev.io' },
    ],
    files: [
      { name: 'Resonance 1', slot: 'source', size: 14400 },
      { name: 'Resonance 3', slot: 'source', size: 20400 },
      { name: 'Daily Flow with Night Mode', slot: 'source', size: 28100 },
      { name: 'To Do', slot: 'source', size: 14400 },
    ],
  },
  {
    id: 'p2', name: 'kopia', callsign: 'Operation: Kopia',
    original_url: 'https://github.com/ravidesta/kopia',
    description: 'Fast and secure open-source backup tool with end-to-end encryption',
    language: 'Go', color: '#00ADD8', status: 'active',
    created_at: '2024-06-01T00:00:00Z', uploaded_at: '2026-03-16T08:05:00Z',
    last_sync: '2026-03-16T14:25:00Z', stars: 6800, forks: 520, open_issues: 145,
    license: 'Apache-2.0', topics: ['backup', 'encryption', 'dedup', 'golang'],
    default_branch: 'master', visibility: 'public', size_kb: 45000,
    notes: 'Core backup engine powering Resonance Vault. Provides deduplication, compression, and end-to-end encryption.',
    collaborators: [
      { name: 'Ravi Desta', role: 'maintainer', email: 'ravi@resonance.dev' },
    ],
    files: [
      { name: 'main.go', slot: 'source', size: 1200 },
      { name: 'cli/', slot: 'source', size: 185000 },
      { name: 'snapshot/', slot: 'source', size: 95000 },
      { name: 'htmlui/', slot: 'source', size: 32000 },
    ],
  },
  {
    id: 'p3', name: 'AppFlowy', callsign: 'Operation: AppFlowy',
    original_url: 'https://github.com/ravidesta/AppFlowy',
    description: 'Open-source alternative to Notion — AI-powered collaborative workspace',
    language: 'Dart', color: '#7B8CDE', status: 'active',
    created_at: '2024-01-10T00:00:00Z', uploaded_at: '2026-03-16T08:10:00Z',
    last_sync: '2026-03-16T14:20:00Z', stars: 52000, forks: 3400, open_issues: 890,
    license: 'AGPL-3.0', topics: ['productivity', 'notion-alternative', 'flutter', 'rust'],
    default_branch: 'main', visibility: 'public', size_kb: 128000,
    notes: 'Workspace backbone. Provides database views, calendar integration, and document editing.',
    collaborators: [
      { name: 'Ravi Desta', role: 'contributor', email: 'ravi@resonance.dev' },
    ],
    files: [
      { name: 'frontend/', slot: 'source', size: 78000 },
      { name: 'rust-lib/', slot: 'source', size: 42000 },
      { name: 'doc/', slot: 'docs', size: 5600 },
    ],
  },
  {
    id: 'p4', name: 'design', callsign: 'Operation: Design',
    original_url: 'https://github.com/ravidesta/design',
    description: 'Luminous OS design specification — bioluminescent visual language & architecture',
    language: 'Markdown', color: '#E040FB', status: 'active',
    created_at: '2025-09-01T00:00:00Z', uploaded_at: '2026-03-16T08:15:00Z',
    last_sync: '2026-03-16T14:15:00Z', stars: 5, forks: 1, open_issues: 0,
    license: 'CC-BY-4.0', topics: ['design', 'luminous-os', 'bioluminescence', 'ux-spec'],
    default_branch: 'main', visibility: 'public', size_kb: 48,
    notes: 'The design bible. Five pillars: Bioluminescence, Living Surfaces, Chromatic Intelligence, Holonic Ecology, Responsive Field.',
    collaborators: [
      { name: 'Ravi Desta', role: 'owner', email: 'ravi@resonance.dev' },
    ],
    files: [
      { name: 'book', slot: 'docs', size: 8400 },
    ],
  },
];

const SAMPLE_CALENDAR = [
  { id: 'c1', portfolio_id: 'p1', event_type: 'upload', title: 'Initial upload: Resonance-UX', timestamp: '2026-03-16T08:00:00Z', project_hash: 'a3f2c8d1e4...', notes: 'All 4 prototype files uploaded' },
  { id: 'c2', portfolio_id: 'p2', event_type: 'upload', title: 'Initial upload: kopia', timestamp: '2026-03-16T08:05:00Z', project_hash: 'b7e9f4a2c1...', notes: 'Full Go codebase snapshot' },
  { id: 'c3', portfolio_id: 'p3', event_type: 'upload', title: 'Initial upload: AppFlowy', timestamp: '2026-03-16T08:10:00Z', project_hash: 'c1d5e8f3b2...', notes: 'Flutter + Rust workspace' },
  { id: 'c4', portfolio_id: 'p4', event_type: 'upload', title: 'Initial upload: design', timestamp: '2026-03-16T08:15:00Z', project_hash: 'd4f7a1b6c3...', notes: 'Luminous OS design spec' },
  { id: 'c5', portfolio_id: 'p1', event_type: 'bitstamp', title: 'Hash anchored: a3f2c8d1e4...', timestamp: '2026-03-16T08:01:00Z', bitstamp_hash: 'a3f2c8d1e4b7f9a2c1d5e8f3b2a4c6d8e1f3a5b7c9d2e4f6a8b1c3d5e7f9a2b4', bitstamp_source: 'openbitstamp', notes: 'Proof-of-existence anchored' },
  { id: 'c6', portfolio_id: 'p2', event_type: 'sync', title: 'Sync: kopia updated', timestamp: '2026-03-16T14:25:00Z', project_hash: 'e8f3b2a4c6...', notes: 'Pulled latest dependency updates from upstream' },
  { id: 'c7', portfolio_id: 'p1', event_type: 'change', title: 'New component: Vault Gallery', timestamp: '2026-03-16T14:30:00Z', project_hash: 'f1a3c5d7e9...', notes: 'Added resonance-vault gallery mode component' },
  { id: 'c8', portfolio_id: 'p1', event_type: 'backup', title: 'Kopia snapshot created', timestamp: '2026-03-16T14:31:00Z', project_hash: 'f1a3c5d7e9...', notes: 'Snapshot ID: s-2026031614310001, compression: zstd' },
];

// ── Slot types for file categorization ──
const FILE_SLOTS = [
  { id: 'source', label: 'Source Code', icon: '◈' },
  { id: 'design', label: 'Design Files', icon: '◇' },
  { id: 'docs', label: 'Documentation', icon: '▱' },
  { id: 'config', label: 'Configuration', icon: '⚙' },
  { id: 'asset', label: 'Assets', icon: '◎' },
  { id: 'build', label: 'Build Artifacts', icon: '▸' },
  { id: 'test', label: 'Tests', icon: '✧' },
];

// ══════════════════════════════════════════════════════
// COMPONENTS
// ══════════════════════════════════════════════════════

// ── Paper Noise Texture ──
function PaperNoise() {
  return (
    <div style={{
      position: 'fixed', inset: 0, pointerEvents: 'none', zIndex: 0,
      opacity: 'var(--paper-noise-opacity)',
    }}>
      <svg width="100%" height="100%">
        <filter id="paperNoise">
          <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="4" stitchTiles="stitch" />
        </filter>
        <rect width="100%" height="100%" filter="url(#paperNoise)" />
      </svg>
    </div>
  );
}

// ── Organic Blobs (Bioluminescent) ──
function OrganicBlobs() {
  return (
    <div style={{ position: 'fixed', inset: 0, pointerEvents: 'none', zIndex: 0, overflow: 'hidden' }}>
      <div style={{
        position: 'absolute', top: '-20%', right: '-10%', width: '500px', height: '500px',
        borderRadius: '50%', filter: 'blur(80px)',
        background: 'radial-gradient(circle, var(--green-400) 0%, transparent 70%)',
        animation: 'breathe var(--bio-breathe-speed) ease-in-out infinite alternate',
        opacity: 'var(--blob-opacity)',
      }} />
      <div style={{
        position: 'absolute', bottom: '-15%', left: '-5%', width: '400px', height: '400px',
        borderRadius: '50%', filter: 'blur(80px)',
        background: 'radial-gradient(circle, var(--gold-primary) 0%, transparent 70%)',
        animation: 'breathe var(--bio-breathe-speed) ease-in-out infinite alternate-reverse',
        opacity: 'var(--blob-opacity)',
      }} />
    </div>
  );
}

// ── Bioluminescent Indicator Light ──
function BioLight({ color = 'var(--status-active)', size = 8, pulse = true, style = {} }) {
  return (
    <span style={{
      display: 'inline-block', width: size, height: size, borderRadius: '50%',
      backgroundColor: color,
      boxShadow: `0 0 ${size}px ${color}, 0 0 ${size * 2}px ${color}`,
      animation: pulse ? `pulseOrb var(--bio-pulse-speed) ease-in-out infinite` : 'none',
      ...style,
    }} />
  );
}

// ── Glass Panel ──
function GlassPanel({ children, style = {}, className = '', onClick }) {
  return (
    <div onClick={onClick} className={className} style={{
      background: 'var(--bg-glass)', backdropFilter: 'blur(12px)',
      WebkitBackdropFilter: 'blur(12px)',
      borderRadius: 'var(--radius-lg)', border: '1px solid var(--border-light)',
      boxShadow: 'var(--shadow-surface)', transition: 'var(--transition-normal)',
      ...style,
    }}>
      {children}
    </div>
  );
}

// ══════════════════════════════════════════════════════
// TOP BAR / FILE MENU
// ══════════════════════════════════════════════════════
function TopBar({ theme, setTheme, currentView, setView, onCommand, serverStatus }) {
  const [openMenu, setOpenMenu] = useState(null);
  const menus = {
    file: DEFAULT_COMMANDS.filter(c => c.category === 'file'),
    view: DEFAULT_COMMANDS.filter(c => c.category === 'view'),
    tools: DEFAULT_COMMANDS.filter(c => c.category === 'tools'),
    server: DEFAULT_COMMANDS.filter(c => c.category === 'server'),
  };

  return (
    <div className="no-print" style={{
      display: 'flex', alignItems: 'center', gap: 'var(--space-md)',
      padding: '8px 20px', background: 'var(--bg-surface)',
      borderBottom: '1px solid var(--border-light)', position: 'relative', zIndex: 100,
      fontFamily: 'var(--font-sans)', fontSize: '13px',
    }}>
      {/* Logo */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginRight: 12 }}>
        <BioLight color="var(--green-400)" size={10} />
        <span style={{ fontFamily: 'var(--font-serif)', fontWeight: 600, fontSize: 16, color: 'var(--text-main)' }}>
          Resonance Vault
        </span>
      </div>

      {/* Menus */}
      {Object.entries(menus).map(([key, items]) => (
        <div key={key} style={{ position: 'relative' }}>
          <button onClick={() => setOpenMenu(openMenu === key ? null : key)} style={{
            background: openMenu === key ? 'var(--green-100)' : 'transparent',
            border: 'none', padding: '4px 10px', borderRadius: 'var(--radius-sm)',
            cursor: 'pointer', color: 'var(--text-main)', fontSize: 13,
            fontFamily: 'var(--font-sans)', textTransform: 'capitalize',
          }}>
            {key}
          </button>
          {openMenu === key && (
            <GlassPanel style={{
              position: 'absolute', top: '100%', left: 0, minWidth: 260,
              padding: '4px 0', zIndex: 200, marginTop: 2,
              boxShadow: 'var(--shadow-elevated)',
            }}>
              {items.map(cmd => (
                <button key={cmd.id} onClick={() => { onCommand(cmd.command); setOpenMenu(null); }}
                  style={{
                    display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                    width: '100%', padding: '8px 16px', border: 'none', background: 'transparent',
                    cursor: 'pointer', color: 'var(--text-main)', fontSize: 13,
                    fontFamily: 'var(--font-sans)', textAlign: 'left',
                  }}
                  onMouseEnter={e => e.target.style.background = 'var(--green-100)'}
                  onMouseLeave={e => e.target.style.background = 'transparent'}
                >
                  <span>{cmd.label}</span>
                  {cmd.keybinding && (
                    <span style={{ color: 'var(--text-light)', fontSize: 11, marginLeft: 16 }}>{cmd.keybinding}</span>
                  )}
                </button>
              ))}
            </GlassPanel>
          )}
        </div>
      ))}

      <div style={{ flex: 1 }} />

      {/* Server Status */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--text-muted)', fontSize: 12 }}>
        <BioLight color={serverStatus === 'online' ? 'var(--status-active)' : 'var(--status-idle)'} size={6} pulse={serverStatus === 'online'} />
        <span>Server: {serverStatus}</span>
      </div>

      {/* Theme Toggle */}
      <button onClick={() => setTheme(theme === 'light' ? 'night' : 'light')} style={{
        background: 'transparent', border: '1px solid var(--border-light)',
        borderRadius: 'var(--radius-sm)', padding: '4px 12px', cursor: 'pointer',
        color: 'var(--text-muted)', fontSize: 12, fontFamily: 'var(--font-sans)',
      }}>
        {theme === 'light' ? '☾ Night' : '☀ Day'}
      </button>
    </div>
  );
}

// ══════════════════════════════════════════════════════
// SIDEBAR
// ══════════════════════════════════════════════════════
function Sidebar({ portfolios, selectedId, onSelect, onViewChange, currentView }) {
  const views = [
    { id: 'gallery', label: 'Gallery', icon: '▦' },
    { id: 'list', label: 'List', icon: '☰' },
    { id: 'calendar', label: 'Calendar', icon: '◫' },
    { id: 'settings', label: 'Settings', icon: '⚙' },
  ];

  return (
    <div className="no-print" style={{
      width: 240, minHeight: '100%', background: 'var(--bg-surface)',
      borderRight: '1px solid var(--border-light)', padding: '16px 0',
      fontFamily: 'var(--font-sans)', fontSize: 13, display: 'flex', flexDirection: 'column',
    }}>
      {/* View Switcher */}
      <div style={{ padding: '0 12px', marginBottom: 16 }}>
        <div style={{ color: 'var(--text-light)', fontSize: 10, textTransform: 'uppercase', letterSpacing: 1.5, marginBottom: 8, padding: '0 8px' }}>
          Views
        </div>
        {views.map(v => (
          <button key={v.id} onClick={() => onViewChange(v.id)} style={{
            display: 'flex', alignItems: 'center', gap: 8, width: '100%',
            padding: '7px 10px', border: 'none', borderRadius: 'var(--radius-sm)',
            background: currentView === v.id ? 'var(--green-100)' : 'transparent',
            color: currentView === v.id ? 'var(--green-700)' : 'var(--text-muted)',
            cursor: 'pointer', fontSize: 13, fontFamily: 'var(--font-sans)',
            fontWeight: currentView === v.id ? 500 : 400,
          }}>
            <span style={{ fontSize: 14, width: 20, textAlign: 'center' }}>{v.icon}</span>
            {v.label}
          </button>
        ))}
      </div>

      <div style={{ height: 1, background: 'var(--border-light)', margin: '0 20px 16px' }} />

      {/* Portfolios */}
      <div style={{ padding: '0 12px', flex: 1 }}>
        <div style={{ color: 'var(--text-light)', fontSize: 10, textTransform: 'uppercase', letterSpacing: 1.5, marginBottom: 8, padding: '0 8px' }}>
          Portfolios
        </div>
        {portfolios.map(p => (
          <button key={p.id} onClick={() => { onSelect(p.id); onViewChange('detail'); }}
            style={{
              display: 'flex', alignItems: 'center', gap: 8, width: '100%',
              padding: '8px 10px', border: 'none', borderRadius: 'var(--radius-sm)',
              background: selectedId === p.id ? 'var(--green-100)' : 'transparent',
              cursor: 'pointer', fontSize: 13, fontFamily: 'var(--font-sans)',
              color: 'var(--text-main)', textAlign: 'left',
            }}
          >
            <BioLight color={p.color} size={8} pulse={p.status === 'active'} />
            <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {p.name}
            </span>
            <span style={{ fontSize: 10, color: 'var(--text-light)' }}>
              {p.files?.length || 0}
            </span>
          </button>
        ))}
      </div>

      {/* Field Coherence Arc */}
      <div style={{ padding: '16px 20px', borderTop: '1px solid var(--border-light)' }}>
        <div style={{ fontSize: 10, color: 'var(--text-light)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 8 }}>
          Field Coherence
        </div>
        <div style={{ height: 4, borderRadius: 2, background: 'var(--border-light)', overflow: 'hidden' }}>
          <div style={{
            height: '100%', width: '100%', borderRadius: 2,
            background: 'linear-gradient(90deg, var(--green-400), var(--gold-primary))',
            animation: 'bioGlowGold 4s ease-in-out infinite',
          }} />
        </div>
        <div style={{ fontSize: 10, color: 'var(--text-light)', marginTop: 4 }}>
          {portfolios.length} portfolios · All synced
        </div>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════
// GALLERY VIEW — Portfolio Cards in Grid
// ══════════════════════════════════════════════════════
function GalleryView({ portfolios, onSelect }) {
  return (
    <div style={{ padding: 'var(--space-xl)' }}>
      <h2 style={{ fontFamily: 'var(--font-serif)', fontWeight: 500, fontSize: 28, color: 'var(--text-main)', marginBottom: 8 }}>
        Portfolio Gallery
      </h2>
      <p style={{ fontFamily: 'var(--font-sans)', color: 'var(--text-muted)', fontSize: 13, marginBottom: 'var(--space-xl)' }}>
        Each repository, a living cell in your constellation
      </p>

      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320, 1fr))',
        gap: 'var(--space-lg)', maxWidth: 1200,
      }}>
        {portfolios.map((p, i) => (
          <GlassPanel key={p.id} onClick={() => onSelect(p.id)} style={{
            padding: 0, cursor: 'pointer', overflow: 'hidden',
            animation: `fadeSlideUp 0.5s ease ${i * 0.08}s both`,
            transition: 'transform 0.2s ease, box-shadow 0.2s ease',
          }}>
            {/* Header with Logo */}
            <div style={{
              padding: '20px 20px 16px', display: 'flex', gap: 16, alignItems: 'flex-start',
              borderBottom: '1px solid var(--border-light)',
              background: `linear-gradient(135deg, ${p.color}08 0%, transparent 60%)`,
            }}>
              {/* Logo */}
              <div style={{ width: 56, height: 56, borderRadius: 'var(--radius-md)', overflow: 'hidden', flexShrink: 0 }}
                dangerouslySetInnerHTML={{ __html: generatePortfolioLogo(p.name, p.language, p.color) }}
              />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{
                  fontFamily: 'var(--font-serif)', fontSize: 11, color: p.color,
                  textTransform: 'uppercase', letterSpacing: 2, marginBottom: 2,
                  fontWeight: 500,
                }}>
                  {p.callsign}
                </div>
                <div style={{ fontFamily: 'var(--font-serif)', fontSize: 20, fontWeight: 600, color: 'var(--text-main)' }}>
                  {p.name}
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 4 }}>
                  <BioLight color={p.color} size={6} pulse={false} />
                  <span style={{ fontSize: 11, color: 'var(--text-muted)' }}>{p.language}</span>
                  <span style={{ fontSize: 11, color: 'var(--text-light)' }}>·</span>
                  <span style={{ fontSize: 11, color: 'var(--text-light)' }}>{p.visibility}</span>
                </div>
              </div>
            </div>

            {/* Description */}
            <div style={{ padding: '12px 20px' }}>
              <p style={{ fontFamily: 'var(--font-sans)', fontSize: 12, color: 'var(--text-muted)', lineHeight: 1.5, margin: 0 }}>
                {p.description}
              </p>
            </div>

            {/* File Slots */}
            <div style={{ padding: '0 20px 12px', display: 'flex', gap: 6, flexWrap: 'wrap' }}>
              {(p.files || []).slice(0, 4).map((f, fi) => (
                <span key={fi} style={{
                  fontSize: 10, padding: '3px 8px', borderRadius: 'var(--radius-sm)',
                  background: 'var(--green-50)', color: 'var(--text-muted)',
                  border: '1px solid var(--border-light)',
                }}>
                  {FILE_SLOTS.find(s => s.id === f.slot)?.icon || '◈'} {f.name}
                </span>
              ))}
            </div>

            {/* Stats Bar */}
            <div style={{
              padding: '10px 20px', borderTop: '1px solid var(--border-light)',
              display: 'flex', gap: 16, fontSize: 11, color: 'var(--text-light)',
              fontFamily: 'var(--font-sans)',
            }}>
              <span>★ {p.stars}</span>
              <span>⑂ {p.forks}</span>
              <span>◉ {p.open_issues}</span>
              <span style={{ marginLeft: 'auto', color: 'var(--text-muted)' }}>
                {p.last_sync ? `Synced ${new Date(p.last_sync).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}` : 'Not synced'}
              </span>
            </div>

            {/* Topics */}
            {p.topics && (
              <div style={{ padding: '0 20px 14px', display: 'flex', gap: 4, flexWrap: 'wrap' }}>
                {p.topics.map(t => (
                  <span key={t} style={{
                    fontSize: 9, padding: '2px 7px', borderRadius: 'var(--radius-pill)',
                    background: `${p.color}15`, color: p.color, fontWeight: 500,
                  }}>
                    {t}
                  </span>
                ))}
              </div>
            )}
          </GlassPanel>
        ))}
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════
// LIST VIEW — Table/Database Style
// ══════════════════════════════════════════════════════
function ListView({ portfolios, onSelect, calendarEntries }) {
  const columns = ['Status', 'Portfolio', 'Callsign', 'Language', 'Stars', 'Size', 'Last Sync', 'License'];

  return (
    <div style={{ padding: 'var(--space-xl)' }}>
      <h2 style={{ fontFamily: 'var(--font-serif)', fontWeight: 500, fontSize: 28, color: 'var(--text-main)', marginBottom: 'var(--space-lg)' }}>
        Repository Database
      </h2>

      <GlassPanel style={{ overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontFamily: 'var(--font-sans)', fontSize: 13 }}>
          <thead>
            <tr style={{ borderBottom: '2px solid var(--border-light)' }}>
              {columns.map(col => (
                <th key={col} style={{
                  padding: '12px 16px', textAlign: 'left', fontWeight: 500,
                  color: 'var(--text-light)', fontSize: 11, textTransform: 'uppercase',
                  letterSpacing: 1,
                }}>
                  {col}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {portfolios.map(p => (
              <tr key={p.id} onClick={() => onSelect(p.id)}
                style={{ borderBottom: '1px solid var(--border-light)', cursor: 'pointer' }}
                onMouseEnter={e => e.currentTarget.style.background = 'var(--green-50)'}
                onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
              >
                <td style={{ padding: '12px 16px' }}>
                  <BioLight color={p.status === 'active' ? 'var(--status-active)' : 'var(--status-idle)'} size={8} />
                </td>
                <td style={{ padding: '12px 16px', fontWeight: 500, color: 'var(--text-main)' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <div style={{ width: 28, height: 28, borderRadius: 8, overflow: 'hidden', flexShrink: 0 }}
                      dangerouslySetInnerHTML={{ __html: generatePortfolioLogo(p.name, p.language, p.color) }}
                    />
                    {p.name}
                  </div>
                </td>
                <td style={{ padding: '12px 16px', color: p.color, fontFamily: 'var(--font-serif)', fontStyle: 'italic', fontSize: 12 }}>
                  {p.callsign}
                </td>
                <td style={{ padding: '12px 16px', color: 'var(--text-muted)' }}>
                  <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                    <BioLight color={(LANGUAGE_ICONS[p.language] || LANGUAGE_ICONS.default).color} size={6} pulse={false} />
                    {p.language}
                  </span>
                </td>
                <td style={{ padding: '12px 16px', color: 'var(--text-muted)' }}>★ {p.stars}</td>
                <td style={{ padding: '12px 16px', color: 'var(--text-muted)' }}>{(p.size_kb / 1024).toFixed(1)} MB</td>
                <td style={{ padding: '12px 16px', color: 'var(--text-muted)', fontSize: 12 }}>
                  {p.last_sync ? new Date(p.last_sync).toLocaleString() : '—'}
                </td>
                <td style={{ padding: '12px 16px', color: 'var(--text-light)', fontSize: 12 }}>{p.license}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </GlassPanel>
    </div>
  );
}

// ══════════════════════════════════════════════════════
// CALENDAR / LEDGER VIEW
// ══════════════════════════════════════════════════════
function CalendarView({ entries, portfolios }) {
  const eventColors = {
    upload: 'var(--chroma-green)',
    sync: 'var(--chroma-blue)',
    change: 'var(--chroma-amber)',
    backup: 'var(--chroma-teal)',
    restore: 'var(--chroma-coral)',
    bitstamp: 'var(--gold-primary)',
  };

  const today = new Date();
  const daysInMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate();
  const firstDay = new Date(today.getFullYear(), today.getMonth(), 1).getDay();
  const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const monthName = today.toLocaleString('default', { month: 'long', year: 'numeric' });

  return (
    <div style={{ padding: 'var(--space-xl)' }}>
      <div style={{ display: 'flex', gap: 'var(--space-xl)', flexWrap: 'wrap' }}>
        {/* Calendar Grid */}
        <div style={{ flex: '1 1 500px' }}>
          <h2 style={{ fontFamily: 'var(--font-serif)', fontWeight: 500, fontSize: 28, color: 'var(--text-main)', marginBottom: 4 }}>
            System Calendar
          </h2>
          <p style={{ fontFamily: 'var(--font-serif)', fontStyle: 'italic', color: 'var(--text-muted)', fontSize: 14, marginBottom: 'var(--space-lg)' }}>
            Every change, logged. Every upload, timestamped.
          </p>

          <GlassPanel style={{ padding: 'var(--space-lg)' }}>
            <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 18, color: 'var(--text-main)', marginBottom: 16, textAlign: 'center' }}>
              {monthName}
            </h3>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 2 }}>
              {dayNames.map(d => (
                <div key={d} style={{ textAlign: 'center', fontSize: 10, color: 'var(--text-light)', padding: '4px 0', textTransform: 'uppercase', letterSpacing: 1 }}>
                  {d}
                </div>
              ))}
              {Array.from({ length: firstDay }).map((_, i) => <div key={`e${i}`} />)}
              {Array.from({ length: daysInMonth }).map((_, i) => {
                const day = i + 1;
                const isToday = day === today.getDate();
                const dayEntries = entries.filter(e => new Date(e.timestamp).getDate() === day);
                return (
                  <div key={day} style={{
                    textAlign: 'center', padding: '8px 4px', borderRadius: 'var(--radius-sm)',
                    background: isToday ? 'var(--green-100)' : 'transparent',
                    border: isToday ? '1px solid var(--green-400)' : '1px solid transparent',
                    cursor: dayEntries.length ? 'pointer' : 'default',
                    position: 'relative',
                  }}>
                    <span style={{ fontSize: 13, color: isToday ? 'var(--green-700)' : 'var(--text-main)', fontWeight: isToday ? 600 : 400 }}>
                      {day}
                    </span>
                    {dayEntries.length > 0 && (
                      <div style={{ display: 'flex', justifyContent: 'center', gap: 2, marginTop: 3 }}>
                        {dayEntries.slice(0, 3).map((e, ei) => (
                          <BioLight key={ei} color={eventColors[e.event_type] || 'var(--text-light)'} size={4} pulse={false} />
                        ))}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </GlassPanel>
        </div>

        {/* Ledger / Event Log */}
        <div style={{ flex: '1 1 360px' }}>
          <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 18, color: 'var(--text-main)', marginBottom: 'var(--space-md)' }}>
            Ledger
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {entries.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)).map(entry => {
              const portfolio = portfolios.find(p => p.id === entry.portfolio_id);
              return (
                <GlassPanel key={entry.id} style={{ padding: '12px 16px', animation: 'fadeSlideUp 0.3s ease both' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
                    <BioLight color={eventColors[entry.event_type]} size={6} pulse={false} />
                    <span style={{
                      fontSize: 9, textTransform: 'uppercase', letterSpacing: 1.5,
                      color: eventColors[entry.event_type], fontWeight: 600,
                    }}>
                      {entry.event_type}
                    </span>
                    <span style={{ fontSize: 10, color: 'var(--text-light)', marginLeft: 'auto' }}>
                      {new Date(entry.timestamp).toLocaleString()}
                    </span>
                  </div>
                  <div style={{ fontFamily: 'var(--font-sans)', fontSize: 13, color: 'var(--text-main)', fontWeight: 500, marginBottom: 4 }}>
                    {entry.title}
                  </div>
                  {entry.notes && (
                    <div style={{ fontSize: 11, color: 'var(--text-muted)', lineHeight: 1.4 }}>
                      {entry.notes}
                    </div>
                  )}
                  {entry.project_hash && (
                    <div style={{
                      fontSize: 10, color: 'var(--text-light)', marginTop: 6,
                      fontFamily: 'monospace', padding: '4px 8px',
                      background: 'var(--green-50)', borderRadius: 'var(--radius-sm)',
                    }}>
                      Hash: {entry.project_hash}
                      {entry.bitstamp_source && ` · ${entry.bitstamp_source}`}
                    </div>
                  )}
                  {portfolio && (
                    <div style={{ fontSize: 10, color: portfolio.color, marginTop: 4, fontStyle: 'italic' }}>
                      {portfolio.callsign}
                    </div>
                  )}
                </GlassPanel>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════
// PORTFOLIO DETAIL VIEW
// ══════════════════════════════════════════════════════
function PortfolioDetail({ portfolio, calendarEntries, onBack }) {
  const [activeTab, setActiveTab] = useState('overview');
  if (!portfolio) return null;

  const tabs = [
    { id: 'overview', label: 'Overview' },
    { id: 'files', label: 'Files' },
    { id: 'calendar', label: 'Calendar' },
    { id: 'notes', label: 'Notes' },
    { id: 'secrets', label: 'Secrets' },
    { id: 'collaborators', label: 'Collaborators' },
    { id: 'briefing', label: 'Briefing' },
  ];

  const portfolioEvents = calendarEntries.filter(e => e.portfolio_id === portfolio.id);

  return (
    <div style={{ padding: 'var(--space-xl)' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 'var(--space-lg)', marginBottom: 'var(--space-xl)' }}>
        <button onClick={onBack} style={{
          background: 'transparent', border: '1px solid var(--border-light)',
          borderRadius: 'var(--radius-sm)', padding: '6px 12px', cursor: 'pointer',
          color: 'var(--text-muted)', fontSize: 13,
        }}>← Back</button>

        <div style={{ width: 72, height: 72, borderRadius: 'var(--radius-lg)', overflow: 'hidden', flexShrink: 0 }}
          dangerouslySetInnerHTML={{ __html: generatePortfolioLogo(portfolio.name, portfolio.language, portfolio.color) }}
        />
        <div style={{ flex: 1 }}>
          <div style={{
            fontFamily: 'var(--font-serif)', fontSize: 12, color: portfolio.color,
            textTransform: 'uppercase', letterSpacing: 2, marginBottom: 2, fontWeight: 500,
          }}>
            {portfolio.callsign}
          </div>
          <h1 style={{ fontFamily: 'var(--font-serif)', fontSize: 32, fontWeight: 600, color: 'var(--text-main)', margin: '0 0 4px' }}>
            {portfolio.name}
          </h1>
          <p style={{ fontFamily: 'var(--font-sans)', color: 'var(--text-muted)', fontSize: 14, margin: 0 }}>
            {portfolio.description}
          </p>
          <div style={{ display: 'flex', gap: 16, marginTop: 12, fontSize: 12, color: 'var(--text-muted)' }}>
            <span>★ {portfolio.stars} stars</span>
            <span>⑂ {portfolio.forks} forks</span>
            <span>◉ {portfolio.open_issues} issues</span>
            <span>⚖ {portfolio.license}</span>
            <span>{(portfolio.size_kb / 1024).toFixed(1)} MB</span>
          </div>
          {portfolio.original_url && (
            <div style={{ fontSize: 12, color: 'var(--text-light)', marginTop: 6 }}>
              Origin: <span style={{ fontFamily: 'monospace' }}>{portfolio.original_url}</span>
            </div>
          )}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <BioLight color={portfolio.status === 'active' ? 'var(--status-active)' : 'var(--status-idle)'} size={10} />
          <span style={{ fontSize: 12, color: 'var(--text-muted)', textTransform: 'capitalize' }}>{portfolio.status}</span>
        </div>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: 4, marginBottom: 'var(--space-lg)', borderBottom: '1px solid var(--border-light)', paddingBottom: 0 }}>
        {tabs.map(t => (
          <button key={t.id} onClick={() => setActiveTab(t.id)} style={{
            padding: '8px 16px', border: 'none', borderBottom: activeTab === t.id ? `2px solid ${portfolio.color}` : '2px solid transparent',
            background: 'transparent', cursor: 'pointer', fontSize: 13,
            color: activeTab === t.id ? 'var(--text-main)' : 'var(--text-muted)',
            fontFamily: 'var(--font-sans)', fontWeight: activeTab === t.id ? 500 : 400,
            transition: 'var(--transition-fast)',
          }}>
            {t.label}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      {activeTab === 'overview' && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: 'var(--space-lg)' }}>
          {/* Properties */}
          <GlassPanel style={{ padding: 'var(--space-lg)' }}>
            <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 16, color: 'var(--text-main)', marginBottom: 16 }}>Properties</h3>
            {[
              ['Language', portfolio.language],
              ['Default Branch', portfolio.default_branch],
              ['Visibility', portfolio.visibility],
              ['License', portfolio.license],
              ['Created', new Date(portfolio.created_at).toLocaleDateString()],
              ['Uploaded', new Date(portfolio.uploaded_at).toLocaleDateString()],
              ['Last Sync', portfolio.last_sync ? new Date(portfolio.last_sync).toLocaleString() : '—'],
            ].map(([k, v]) => (
              <div key={k} style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', borderBottom: '1px solid var(--border-light)', fontSize: 13 }}>
                <span style={{ color: 'var(--text-muted)' }}>{k}</span>
                <span style={{ color: 'var(--text-main)', fontWeight: 500 }}>{v}</span>
              </div>
            ))}
          </GlassPanel>

          {/* Topics */}
          <GlassPanel style={{ padding: 'var(--space-lg)' }}>
            <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 16, color: 'var(--text-main)', marginBottom: 16 }}>Topics</h3>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
              {(portfolio.topics || []).map(t => (
                <span key={t} style={{
                  padding: '4px 12px', borderRadius: 'var(--radius-pill)', fontSize: 12,
                  background: `${portfolio.color}15`, color: portfolio.color, fontWeight: 500,
                }}>
                  {t}
                </span>
              ))}
            </div>
          </GlassPanel>

          {/* Landing Page / Notes Preview */}
          <GlassPanel style={{ padding: 'var(--space-lg)', gridColumn: 'span 2' }}>
            <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 16, color: 'var(--text-main)', marginBottom: 16 }}>Landing Page</h3>
            <div style={{
              padding: 'var(--space-lg)', background: 'var(--bg-base)', borderRadius: 'var(--radius-md)',
              border: '1px dashed var(--border-light)', minHeight: 120,
            }}>
              <div style={{ fontFamily: 'var(--font-serif)', fontSize: 22, color: 'var(--text-main)', marginBottom: 8 }}>
                {portfolio.name}
              </div>
              <p style={{ fontFamily: 'var(--font-sans)', fontSize: 13, color: 'var(--text-muted)', lineHeight: 1.6 }}>
                {portfolio.notes || portfolio.description}
              </p>
              <div style={{ marginTop: 16, display: 'flex', gap: 8 }}>
                {(portfolio.topics || []).slice(0, 3).map(t => (
                  <span key={t} style={{ fontSize: 10, padding: '2px 8px', borderRadius: 'var(--radius-pill)', border: `1px solid ${portfolio.color}40`, color: portfolio.color }}>
                    {t}
                  </span>
                ))}
              </div>
            </div>
          </GlassPanel>

          {/* Recent Activity */}
          <GlassPanel style={{ padding: 'var(--space-lg)', gridColumn: 'span 2' }}>
            <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 16, color: 'var(--text-main)', marginBottom: 16 }}>Recent Activity</h3>
            {portfolioEvents.length === 0 ? (
              <p style={{ color: 'var(--text-light)', fontSize: 13, fontStyle: 'italic' }}>No events logged yet</p>
            ) : (
              portfolioEvents.slice(0, 5).map(e => (
                <div key={e.id} style={{
                  display: 'flex', alignItems: 'center', gap: 12, padding: '8px 0',
                  borderBottom: '1px solid var(--border-light)',
                }}>
                  <BioLight color={e.event_type === 'bitstamp' ? 'var(--gold-primary)' : 'var(--status-active)'} size={6} pulse={false} />
                  <span style={{ fontSize: 13, color: 'var(--text-main)', flex: 1 }}>{e.title}</span>
                  <span style={{ fontSize: 11, color: 'var(--text-light)' }}>{new Date(e.timestamp).toLocaleString()}</span>
                </div>
              ))
            )}
          </GlassPanel>
        </div>
      )}

      {activeTab === 'files' && (
        <div>
          <div style={{ display: 'flex', gap: 'var(--space-md)', marginBottom: 'var(--space-lg)', flexWrap: 'wrap' }}>
            {FILE_SLOTS.map(slot => {
              const slotFiles = (portfolio.files || []).filter(f => f.slot === slot.id);
              return (
                <GlassPanel key={slot.id} style={{ padding: 'var(--space-md)', minWidth: 180, flex: '1 1 180px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
                    <span style={{ fontSize: 16 }}>{slot.icon}</span>
                    <span style={{ fontSize: 13, fontWeight: 500, color: 'var(--text-main)' }}>{slot.label}</span>
                    <span style={{ fontSize: 10, color: 'var(--text-light)', marginLeft: 'auto' }}>{slotFiles.length}</span>
                  </div>
                  {slotFiles.length === 0 ? (
                    <div style={{
                      padding: '16px', borderRadius: 'var(--radius-sm)',
                      border: '1px dashed var(--border-light)', textAlign: 'center',
                      fontSize: 11, color: 'var(--text-light)',
                    }}>
                      Drop files here
                    </div>
                  ) : (
                    slotFiles.map((f, i) => (
                      <div key={i} style={{
                        padding: '6px 10px', borderRadius: 'var(--radius-sm)',
                        background: 'var(--green-50)', marginBottom: 4,
                        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                        fontSize: 12, color: 'var(--text-main)',
                      }}>
                        <span>{f.name}</span>
                        <span style={{ fontSize: 10, color: 'var(--text-light)' }}>
                          {f.size > 1024 ? `${(f.size / 1024).toFixed(0)} KB` : `${f.size} B`}
                        </span>
                      </div>
                    ))
                  )}
                </GlassPanel>
              );
            })}
          </div>
        </div>
      )}

      {activeTab === 'calendar' && (
        <CalendarView entries={portfolioEvents} portfolios={[portfolio]} />
      )}

      {activeTab === 'notes' && (
        <GlassPanel style={{ padding: 'var(--space-xl)', minHeight: 400 }}>
          <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 18, color: 'var(--text-main)', marginBottom: 16 }}>Notes</h3>
          <div style={{
            fontFamily: 'var(--font-sans)', fontSize: 14, color: 'var(--text-main)',
            lineHeight: 1.8, whiteSpace: 'pre-wrap', minHeight: 300,
            padding: 'var(--space-md)', background: 'var(--bg-base)',
            borderRadius: 'var(--radius-md)', border: '1px solid var(--border-light)',
          }}>
            {portfolio.notes || 'Begin writing notes here...'}
          </div>
          <div style={{ marginTop: 12, fontSize: 11, color: 'var(--text-light)', fontStyle: 'italic' }}>
            Saving gently...
          </div>
        </GlassPanel>
      )}

      {activeTab === 'secrets' && (
        <GlassPanel style={{ padding: 'var(--space-xl)' }}>
          <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 18, color: 'var(--text-main)', marginBottom: 8 }}>Secrets & Environment</h3>
          <p style={{ fontSize: 12, color: 'var(--text-muted)', marginBottom: 'var(--space-lg)' }}>
            Encrypted at rest. Never exposed in logs or briefings.
          </p>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {['API_KEY', 'DATABASE_URL', 'SECRET_TOKEN', 'DEPLOY_KEY'].map(key => (
              <div key={key} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '10px 16px',
                background: 'var(--bg-base)', borderRadius: 'var(--radius-sm)',
                border: '1px solid var(--border-light)',
              }}>
                <BioLight color="var(--gold-primary)" size={6} pulse={false} />
                <span style={{ fontSize: 13, fontFamily: 'monospace', color: 'var(--text-main)', fontWeight: 500, width: 160 }}>{key}</span>
                <input type="password" placeholder="Enter secret value..." style={{
                  flex: 1, border: '1px solid var(--border-light)', borderRadius: 'var(--radius-sm)',
                  padding: '6px 12px', fontSize: 13, fontFamily: 'monospace',
                  background: 'var(--bg-surface)', color: 'var(--text-main)',
                  outline: 'none',
                }} />
              </div>
            ))}
            <button style={{
              alignSelf: 'flex-start', marginTop: 8, padding: '8px 16px',
              border: '1px dashed var(--border-light)', borderRadius: 'var(--radius-sm)',
              background: 'transparent', cursor: 'pointer', color: 'var(--text-muted)',
              fontSize: 12,
            }}>
              + Add Secret Field
            </button>
          </div>
        </GlassPanel>
      )}

      {activeTab === 'collaborators' && (
        <GlassPanel style={{ padding: 'var(--space-xl)' }}>
          <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 18, color: 'var(--text-main)', marginBottom: 'var(--space-lg)' }}>Collaborators</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {(portfolio.collaborators || []).map((c, i) => (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px',
                background: 'var(--bg-base)', borderRadius: 'var(--radius-md)',
                border: '1px solid var(--border-light)',
              }}>
                <div style={{
                  width: 36, height: 36, borderRadius: '50%', display: 'flex',
                  alignItems: 'center', justifyContent: 'center',
                  background: `${portfolio.color}20`, color: portfolio.color,
                  fontFamily: 'var(--font-serif)', fontWeight: 600, fontSize: 16,
                }}>
                  {c.name.charAt(0)}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 500, color: 'var(--text-main)' }}>{c.name}</div>
                  <div style={{ fontSize: 11, color: 'var(--text-light)' }}>{c.email}</div>
                </div>
                <span style={{
                  fontSize: 10, padding: '3px 10px', borderRadius: 'var(--radius-pill)',
                  background: `${portfolio.color}15`, color: portfolio.color,
                  textTransform: 'uppercase', letterSpacing: 1, fontWeight: 600,
                }}>
                  {c.role}
                </span>
              </div>
            ))}
          </div>
          <div style={{ marginTop: 'var(--space-lg)' }}>
            <h4 style={{ fontFamily: 'var(--font-serif)', fontSize: 14, color: 'var(--text-muted)', marginBottom: 12 }}>
              Invite Collaborator
            </h4>
            <div style={{ display: 'flex', gap: 8 }}>
              <input placeholder="Email address" style={{
                flex: 1, padding: '8px 14px', border: '1px solid var(--border-light)',
                borderRadius: 'var(--radius-sm)', fontSize: 13,
                background: 'var(--bg-surface)', color: 'var(--text-main)', outline: 'none',
              }} />
              <select style={{
                padding: '8px 14px', border: '1px solid var(--border-light)',
                borderRadius: 'var(--radius-sm)', fontSize: 13,
                background: 'var(--bg-surface)', color: 'var(--text-main)',
              }}>
                <option>Viewer</option>
                <option>Contributor</option>
                <option>Maintainer</option>
              </select>
              <button style={{
                padding: '8px 20px', background: portfolio.color, color: '#fff',
                border: 'none', borderRadius: 'var(--radius-sm)', cursor: 'pointer',
                fontSize: 13, fontWeight: 500,
              }}>
                Send Invitation
              </button>
            </div>
          </div>
        </GlassPanel>
      )}

      {activeTab === 'briefing' && (
        <GlassPanel className="portfolio-card" style={{ padding: 'var(--space-xl)', maxWidth: 800 }}>
          <div style={{ textAlign: 'center', marginBottom: 'var(--space-xl)', paddingBottom: 'var(--space-lg)', borderBottom: '2px solid var(--border-light)' }}>
            <div style={{
              fontFamily: 'var(--font-serif)', fontSize: 12, color: portfolio.color,
              textTransform: 'uppercase', letterSpacing: 3, marginBottom: 8,
            }}>
              Resonance Vault · Portfolio Briefing
            </div>
            <div style={{ width: 80, height: 80, margin: '0 auto 12px', borderRadius: 'var(--radius-lg)', overflow: 'hidden' }}
              dangerouslySetInnerHTML={{ __html: generatePortfolioLogo(portfolio.name, portfolio.language, portfolio.color) }}
            />
            <h1 style={{ fontFamily: 'var(--font-serif)', fontSize: 28, fontWeight: 600, color: 'var(--text-main)', margin: '0 0 4px' }}>
              {portfolio.callsign}
            </h1>
            <p style={{ fontSize: 14, color: 'var(--text-muted)' }}>
              {portfolio.description}
            </p>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--space-lg)', marginBottom: 'var(--space-xl)' }}>
            <div>
              <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 14, color: 'var(--text-main)', marginBottom: 12 }}>Technical Profile</h3>
              {[
                ['Language', portfolio.language],
                ['License', portfolio.license],
                ['Branch', portfolio.default_branch],
                ['Visibility', portfolio.visibility],
                ['Size', `${(portfolio.size_kb / 1024).toFixed(1)} MB`],
              ].map(([k, v]) => (
                <div key={k} style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, padding: '4px 0', borderBottom: '1px solid var(--border-light)' }}>
                  <span style={{ color: 'var(--text-muted)' }}>{k}</span>
                  <span style={{ color: 'var(--text-main)' }}>{v}</span>
                </div>
              ))}
            </div>
            <div>
              <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 14, color: 'var(--text-main)', marginBottom: 12 }}>Community</h3>
              {[
                ['Stars', portfolio.stars],
                ['Forks', portfolio.forks],
                ['Open Issues', portfolio.open_issues],
                ['Collaborators', (portfolio.collaborators || []).length],
                ['File Slots', (portfolio.files || []).length],
              ].map(([k, v]) => (
                <div key={k} style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, padding: '4px 0', borderBottom: '1px solid var(--border-light)' }}>
                  <span style={{ color: 'var(--text-muted)' }}>{k}</span>
                  <span style={{ color: 'var(--text-main)' }}>{v}</span>
                </div>
              ))}
            </div>
          </div>

          <div style={{ marginBottom: 'var(--space-lg)' }}>
            <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 14, color: 'var(--text-main)', marginBottom: 8 }}>Notes</h3>
            <p style={{ fontSize: 12, color: 'var(--text-muted)', lineHeight: 1.6 }}>{portfolio.notes}</p>
          </div>

          <div style={{ marginBottom: 'var(--space-lg)' }}>
            <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 14, color: 'var(--text-main)', marginBottom: 8 }}>Origin</h3>
            <p style={{ fontSize: 12, color: 'var(--text-muted)', fontFamily: 'monospace' }}>{portfolio.original_url}</p>
            <p style={{ fontSize: 11, color: 'var(--text-light)' }}>Uploaded: {new Date(portfolio.uploaded_at).toLocaleString()}</p>
          </div>

          <div style={{ textAlign: 'center', paddingTop: 'var(--space-lg)', borderTop: '1px solid var(--border-light)', fontSize: 10, color: 'var(--text-light)' }}>
            Generated {new Date().toLocaleString()} · Resonance Vault v1.0
          </div>

          <button className="no-print" onClick={() => window.print()} style={{
            display: 'block', margin: '20px auto 0', padding: '10px 24px',
            background: portfolio.color, color: '#fff', border: 'none',
            borderRadius: 'var(--radius-sm)', cursor: 'pointer', fontSize: 13,
          }}>
            Print / Export PDF
          </button>
        </GlassPanel>
      )}
    </div>
  );
}

// ══════════════════════════════════════════════════════
// SETTINGS VIEW — Kopia & Server Configuration
// ══════════════════════════════════════════════════════
function SettingsView() {
  const categories = {
    kopia: { label: 'Backup (Kopia)', icon: '◈' },
    backup: { label: 'GitHub & Sync', icon: '⟳' },
    server: { label: 'Server', icon: '▸' },
    ui: { label: 'Interface', icon: '◇' },
    notifications: { label: 'Notifications', icon: '◎' },
  };

  return (
    <div style={{ padding: 'var(--space-xl)', maxWidth: 800 }}>
      <h2 style={{ fontFamily: 'var(--font-serif)', fontWeight: 500, fontSize: 28, color: 'var(--text-main)', marginBottom: 8 }}>
        Settings
      </h2>
      <p style={{ fontFamily: 'var(--font-serif)', fontStyle: 'italic', color: 'var(--text-muted)', fontSize: 14, marginBottom: 'var(--space-xl)' }}>
        Intuitive defaults. Change only what you need.
      </p>

      {Object.entries(categories).map(([catKey, cat]) => {
        const settings = DEFAULT_SETTINGS.filter(s => s.category === catKey);
        return (
          <GlassPanel key={catKey} style={{ padding: 'var(--space-lg)', marginBottom: 'var(--space-md)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 'var(--space-md)' }}>
              <span style={{ fontSize: 16 }}>{cat.icon}</span>
              <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 16, color: 'var(--text-main)', margin: 0 }}>{cat.label}</h3>
            </div>
            {settings.map(s => (
              <div key={s.key} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '10px 0',
                borderBottom: '1px solid var(--border-light)',
              }}>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, color: 'var(--text-main)', fontWeight: 500 }}>
                    {s.description}
                  </div>
                  <div style={{ fontSize: 10, color: 'var(--text-light)', fontFamily: 'monospace', marginTop: 2 }}>
                    {s.key}
                  </div>
                </div>
                {s.key.includes('password') || s.key.includes('token') ? (
                  <input type="password" defaultValue={s.value} placeholder="••••••" style={{
                    width: 200, padding: '6px 12px', border: '1px solid var(--border-light)',
                    borderRadius: 'var(--radius-sm)', fontSize: 13, fontFamily: 'monospace',
                    background: 'var(--bg-surface)', color: 'var(--text-main)', outline: 'none',
                  }} />
                ) : s.value === 'true' || s.value === 'false' ? (
                  <label style={{ display: 'flex', alignItems: 'center', gap: 6, cursor: 'pointer' }}>
                    <input type="checkbox" defaultChecked={s.value === 'true'} style={{ accentColor: 'var(--green-400)' }} />
                    <span style={{ fontSize: 12, color: 'var(--text-muted)' }}>{s.value === 'true' ? 'Enabled' : 'Disabled'}</span>
                  </label>
                ) : (
                  <input type="text" defaultValue={s.value} style={{
                    width: 200, padding: '6px 12px', border: '1px solid var(--border-light)',
                    borderRadius: 'var(--radius-sm)', fontSize: 13,
                    background: 'var(--bg-surface)', color: 'var(--text-main)', outline: 'none',
                  }} />
                )}
              </div>
            ))}
          </GlassPanel>
        );
      })}

      {/* Bitstamp Services */}
      <GlassPanel style={{ padding: 'var(--space-lg)', marginBottom: 'var(--space-md)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 'var(--space-md)' }}>
          <BioLight color="var(--gold-primary)" size={8} pulse={false} />
          <h3 style={{ fontFamily: 'var(--font-serif)', fontSize: 16, color: 'var(--text-main)', margin: 0 }}>Timestamp Anchoring</h3>
        </div>
        {TIMESTAMP_SERVICES.map(svc => (
          <div key={svc.id} style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: '10px 0',
            borderBottom: '1px solid var(--border-light)',
          }}>
            <input type="checkbox" defaultChecked={svc.id !== 'originstamp'} style={{ accentColor: 'var(--gold-primary)' }} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, color: 'var(--text-main)', fontWeight: 500 }}>{svc.name}</div>
              <div style={{ fontSize: 11, color: 'var(--text-muted)' }}>{svc.description}</div>
            </div>
            <span style={{
              fontSize: 9, padding: '2px 8px', borderRadius: 'var(--radius-pill)',
              background: svc.type === 'blockchain' ? 'var(--gold-light)' : 'var(--green-100)',
              color: svc.type === 'blockchain' ? 'var(--gold-dark)' : 'var(--green-700)',
              textTransform: 'uppercase', letterSpacing: 1,
            }}>
              {svc.type}
            </span>
          </div>
        ))}
      </GlassPanel>
    </div>
  );
}

// ══════════════════════════════════════════════════════
// MAIN APP
// ══════════════════════════════════════════════════════
export default function App() {
  const [theme, setTheme] = useState('light');
  const [currentView, setCurrentView] = useState('gallery');
  const [selectedPortfolioId, setSelectedPortfolioId] = useState(null);
  const [serverStatus, setServerStatus] = useState('online');

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme]);

  const handleCommand = useCallback((command) => {
    switch (command) {
      case 'view:gallery': setCurrentView('gallery'); break;
      case 'view:list': setCurrentView('list'); break;
      case 'view:calendar': setCurrentView('calendar'); break;
      case 'ui:toggle-theme': setTheme(t => t === 'light' ? 'night' : 'light'); break;
      case 'kopia:settings': setCurrentView('settings'); break;
      default:
        console.log(`Command: ${command}`);
    }
  }, []);

  const handleSelectPortfolio = (id) => {
    setSelectedPortfolioId(id);
    setCurrentView('detail');
  };

  const selectedPortfolio = SAMPLE_PORTFOLIOS.find(p => p.id === selectedPortfolioId);

  const renderView = () => {
    switch (currentView) {
      case 'gallery':
        return <GalleryView portfolios={SAMPLE_PORTFOLIOS} onSelect={handleSelectPortfolio} />;
      case 'list':
        return <ListView portfolios={SAMPLE_PORTFOLIOS} onSelect={handleSelectPortfolio} calendarEntries={SAMPLE_CALENDAR} />;
      case 'calendar':
        return <CalendarView entries={SAMPLE_CALENDAR} portfolios={SAMPLE_PORTFOLIOS} />;
      case 'settings':
        return <SettingsView />;
      case 'detail':
        return <PortfolioDetail portfolio={selectedPortfolio} calendarEntries={SAMPLE_CALENDAR} onBack={() => setCurrentView('gallery')} />;
      default:
        return <GalleryView portfolios={SAMPLE_PORTFOLIOS} onSelect={handleSelectPortfolio} />;
    }
  };

  return (
    <div style={{
      minHeight: '100vh', background: 'var(--bg-base)', color: 'var(--text-main)',
      fontFamily: 'var(--font-sans)', transition: 'background var(--transition-slow), color var(--transition-slow)',
      margin: 0,
    }}>
      <PaperNoise />
      <OrganicBlobs />

      <div style={{ position: 'relative', zIndex: 1, display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
        <TopBar theme={theme} setTheme={setTheme} currentView={currentView} setView={setCurrentView} onCommand={handleCommand} serverStatus={serverStatus} />
        <div style={{ display: 'flex', flex: 1 }}>
          <Sidebar
            portfolios={SAMPLE_PORTFOLIOS}
            selectedId={selectedPortfolioId}
            onSelect={setSelectedPortfolioId}
            onViewChange={setCurrentView}
            currentView={currentView}
          />
          <div style={{ flex: 1, overflow: 'auto', maxHeight: 'calc(100vh - 42px)' }}>
            {renderView()}
          </div>
        </div>
      </div>
    </div>
  );
}
