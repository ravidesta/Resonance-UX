import React, { useState, useEffect, useCallback, useRef } from 'react';

// ═══════════════════════════════════════════════════════════════════
// RESONANCE GITHUB BACKUP PORTAL
// Bioluminescent Repository Management System
// Windows Desktop + iPad (PDFKit Reports)
// ═══════════════════════════════════════════════════════════════════

// ── Design Tokens (Resonance UX + Luminous Design) ──────────────
const COLORS = {
  green900: '#0A1C14', green800: '#122E21', green700: '#1B402E',
  green600: '#2D5A44', green500: '#3D7A5C', green400: '#5C9A78',
  green300: '#8ABFA0', green200: '#D1E0D7', green100: '#E8F0EA',
  gold: '#C5A059', goldLight: '#E6D0A1', goldDark: '#9A7A3A',
  bgBase: '#FAFAF8', bgSurface: '#FFFFFF',
  textMain: '#122E21', textMuted: '#5C7065', textLight: '#8A9C91',
  borderLight: '#E5EBE7',
  terraCotta: '#D87050',
  // Luminous chromatic palette
  growthGreen: '#59C9A5', strategicBlue: '#7B8CDE',
  creativeMagenta: '#E040FB', warmthAmber: '#F4A261',
  signalTeal: '#4ECDC4', rhythmCoral: '#EF6461',
  // Bioluminescent
  bioGlow: 'rgba(89, 201, 165, 0.15)',
  bioGlowGold: 'rgba(197, 160, 89, 0.12)',
};

const CHROMATIC_PALETTE = [
  COLORS.growthGreen, COLORS.strategicBlue, COLORS.creativeMagenta,
  COLORS.warmthAmber, COLORS.signalTeal, COLORS.rhythmCoral,
  '#A78BFA', '#F472B6', '#34D399', '#FBBF24',
];

// ── Language Detection Heuristics ───────────────────────────────
const LANG_SIGNATURES = {
  JavaScript: ['.js', '.jsx', '.mjs', 'package.json'],
  TypeScript: ['.ts', '.tsx', 'tsconfig.json'],
  Python: ['.py', 'requirements.txt', 'setup.py', 'Pipfile'],
  Rust: ['.rs', 'Cargo.toml'], Go: ['.go', 'go.mod'],
  Java: ['.java', 'pom.xml', 'build.gradle'],
  'C#': ['.cs', '.csproj', '.sln'], 'C++': ['.cpp', '.hpp', '.cc'],
  Ruby: ['.rb', 'Gemfile'], PHP: ['.php', 'composer.json'],
  Swift: ['.swift', 'Package.swift'], Kotlin: ['.kt', '.kts'],
  Dart: ['.dart', 'pubspec.yaml'], HTML: ['.html', '.htm'],
  CSS: ['.css', '.scss', '.sass'], Shell: ['.sh', '.bash'],
  Markdown: ['.md'], YAML: ['.yml', '.yaml'],
};

function detectLanguages(files) {
  const langs = {};
  (files || []).forEach(f => {
    Object.entries(LANG_SIGNATURES).forEach(([lang, sigs]) => {
      if (sigs.some(s => f.toLowerCase().endsWith(s.toLowerCase()))) {
        langs[lang] = (langs[lang] || 0) + 1;
      }
    });
  });
  return Object.entries(langs).sort((a, b) => b[1] - a[1]).map(([l]) => l);
}

// ── Codename Generator ──────────────────────────────────────────
const ADJECTIVES = [
  'Silent', 'Crimson', 'Phantom', 'Velvet', 'Cobalt', 'Ember',
  'Obsidian', 'Ivory', 'Sapphire', 'Radiant', 'Verdant', 'Azure',
  'Ethereal', 'Stellar', 'Quantum', 'Prismatic', 'Orbital', 'Nexus',
];
function generateCallsign(name) {
  const hash = name.split('').reduce((a, c) => a + c.charCodeAt(0), 0);
  const adj = ADJECTIVES[hash % ADJECTIVES.length];
  return `Operation: ${adj} ${name.replace(/[-_]/g, ' ').replace(/\b\w/g, c => c.toUpperCase())}`;
}

// ── Bitstamp Hash (simulated deterministic hash) ────────────────
function generateBitstampHash(data) {
  let h = 0x811c9dc5;
  for (let i = 0; i < data.length; i++) {
    h ^= data.charCodeAt(i);
    h = Math.imul(h, 0x01000193);
  }
  const hex = (h >>> 0).toString(16).padStart(8, '0');
  return `0x${hex}${hex.split('').reverse().join('')}`;
}

// ── Sample Data ─────────────────────────────────────────────────
const INITIAL_REPOS = [
  {
    id: 1, name: 'Resonance-UX', url: 'https://github.com/ravidesta/Resonance-UX',
    description: 'Calm productivity UX with breathing animations and intentional design',
    files: ['Resonance 1', 'Resonance 3', 'Daily Flow with Night Mode', 'To Do',
            'package.json', 'index.js', 'App.js', 'style.css'],
    uploadDate: '2026-03-14T10:30:00Z', lastSync: '2026-03-16T08:15:00Z',
    stars: 12, forks: 3, status: 'synced',
    secrets: [], notes: 'Core UX framework for all Resonance products.',
    collaborators: ['elena@resonance.dev'],
    designFiles: ['mockups.fig', 'color-palette.svg', 'typography-guide.pdf'],
  },
  {
    id: 2, name: 'kopia', url: 'https://github.com/ravidesta/kopia',
    description: 'Fast and secure backup tool with encryption and deduplication',
    files: ['main.go', 'go.mod', 'cli/app.go', 'snapshot/policy/scheduling_policy.go',
            'repo/blob/s3/s3_storage.go', 'Makefile'],
    uploadDate: '2026-03-10T14:00:00Z', lastSync: '2026-03-16T07:00:00Z',
    stars: 5200, forks: 380, status: 'synced',
    secrets: [], notes: 'Backup engine powering the portal. Handles snapshots and policies.',
    collaborators: [],
    designFiles: [],
  },
  {
    id: 3, name: 'AppFlowy', url: 'https://github.com/ravidesta/AppFlowy',
    description: 'Open-source Notion alternative with databases, calendars, and kanban',
    files: ['pubspec.yaml', 'lib/main.dart', 'lib/workspace/database.dart',
            'lib/plugins/calendar.dart', 'rust-lib/Cargo.toml'],
    uploadDate: '2026-03-12T09:00:00Z', lastSync: '2026-03-15T22:30:00Z',
    stars: 48000, forks: 3100, status: 'pending',
    secrets: [], notes: 'Database and calendar engine for portfolio management.',
    collaborators: ['dev@appflowy.io'],
    designFiles: ['ui-components.fig'],
  },
  {
    id: 4, name: 'design', url: 'https://github.com/ravidesta/design',
    description: 'Luminous OS design system — bioluminescent surfaces and chromatic intelligence',
    files: ['book', 'README.md', 'assets/chromatic-orb.svg', 'assets/particles.json'],
    uploadDate: '2026-03-13T16:45:00Z', lastSync: '2026-03-16T06:00:00Z',
    stars: 8, forks: 1, status: 'synced',
    secrets: [], notes: 'Living design system with breathing surfaces and particle fields.',
    collaborators: [],
    designFiles: ['book', 'chromatic-orb.svg', 'field-coherence-spec.pdf'],
  },
];

// ── Styles ──────────────────────────────────────────────────────
const styles = `
@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Manrope:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap');

:root {
  --green-900: ${COLORS.green900}; --green-800: ${COLORS.green800};
  --green-700: ${COLORS.green700}; --green-200: ${COLORS.green200};
  --gold: ${COLORS.gold}; --gold-light: ${COLORS.goldLight};
  --bg-base: ${COLORS.bgBase}; --text-main: ${COLORS.textMain};
  --text-muted: ${COLORS.textMuted}; --border-light: ${COLORS.borderLight};
  --safe-top: env(safe-area-inset-top, 0px);
  --safe-bottom: env(safe-area-inset-bottom, 0px);
}

* { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }

body {
  font-family: 'Manrope', system-ui, -apple-system, sans-serif;
  background: var(--green-900);
  color: var(--text-main);
  overflow: hidden;
  -webkit-font-smoothing: antialiased;
}

/* iPad-optimized touch targets */
@media (pointer: coarse) {
  button, .clickable { min-height: 44px; min-width: 44px; }
}

@supports (padding: env(safe-area-inset-top)) {
  .app-container { padding-top: var(--safe-top); padding-bottom: var(--safe-bottom); }
}

.app-container {
  width: 100vw; height: 100vh; display: flex; flex-direction: column;
  background: var(--green-900); position: relative; overflow: hidden;
}

/* ── Paper Noise Texture ────────────────────────────────── */
.paper-noise::before {
  content: ''; position: absolute; inset: 0; z-index: 0; opacity: 0.035;
  background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
  pointer-events: none;
}

/* ── Breathing Blobs ────────────────────────────────────── */
.blob-container { position: absolute; inset: 0; z-index: 0; pointer-events: none; overflow: hidden; }
.blob {
  position: absolute; border-radius: 50%; filter: blur(80px);
  animation: breathe 15s ease-in-out infinite;
}
.blob-1 {
  width: 500px; height: 500px; top: -100px; left: -100px;
  background: radial-gradient(circle, rgba(89,201,165,0.12), transparent 70%);
}
.blob-2 {
  width: 400px; height: 400px; bottom: -80px; right: -80px;
  background: radial-gradient(circle, rgba(197,160,89,0.1), transparent 70%);
  animation-delay: -5s;
}
.blob-3 {
  width: 300px; height: 300px; top: 50%; left: 50%;
  background: radial-gradient(circle, rgba(123,140,222,0.06), transparent 70%);
  animation-delay: -8s;
}

@keyframes breathe {
  0%, 100% { transform: scale(1) translate(0, 0); opacity: 0.6; }
  33% { transform: scale(1.1) translate(15px, -10px); opacity: 0.8; }
  66% { transform: scale(0.95) translate(-10px, 15px); opacity: 0.5; }
}

/* ── Bioluminescent Indicator ───────────────────────────── */
@keyframes bioGlow {
  0%, 100% { box-shadow: 0 0 8px 2px var(--glow-color); opacity: 0.7; }
  50% { box-shadow: 0 0 16px 4px var(--glow-color); opacity: 1; }
}
.bio-indicator {
  width: 10px; height: 10px; border-radius: 50%;
  animation: bioGlow 3s ease-in-out infinite;
  flex-shrink: 0;
}
.bio-indicator.synced { --glow-color: rgba(89,201,165,0.6); background: #59C9A5; }
.bio-indicator.pending { --glow-color: rgba(244,162,97,0.6); background: #F4A261; }
.bio-indicator.error { --glow-color: rgba(239,100,97,0.6); background: #EF6461; }
.bio-indicator.backing-up { --glow-color: rgba(123,140,222,0.6); background: #7B8CDE;
  animation: bioGlow 1s ease-in-out infinite; }

/* ── Chromatic Orb ──────────────────────────────────────── */
@keyframes orbPulse {
  0%, 100% { transform: scale(1); filter: brightness(1); }
  50% { transform: scale(1.05); filter: brightness(1.3); }
}
.chromatic-orb {
  width: 48px; height: 48px; border-radius: 14px; display: flex;
  align-items: center; justify-content: center; font-weight: 700;
  font-size: 18px; color: white; position: relative; overflow: hidden;
  animation: orbPulse 4s ease-in-out infinite;
  font-family: 'JetBrains Mono', monospace;
}
.chromatic-orb::after {
  content: ''; position: absolute; inset: 0; border-radius: 14px;
  background: radial-gradient(circle at 30% 50%, rgba(255,255,255,0.2), transparent 60%);
}

/* ── Living Surface Card ────────────────────────────────── */
@keyframes surfaceBreathe {
  0%, 100% { background-color: rgba(255,255,255,0.04); border-color: rgba(255,255,255,0.06); }
  50% { background-color: rgba(255,255,255,0.06); border-color: rgba(255,255,255,0.1); }
}
.living-surface {
  background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.06);
  border-radius: 20px; padding: 24px; position: relative; overflow: hidden;
  animation: surfaceBreathe 6s ease-in-out infinite;
  transition: transform 0.3s ease, border-color 0.3s ease;
  cursor: pointer;
}
.living-surface:hover {
  transform: translateY(-2px); border-color: rgba(255,255,255,0.14);
}
.living-surface::before {
  content: ''; position: absolute; inset: 0; border-radius: 20px;
  background: radial-gradient(ellipse at 30% 50%, var(--surface-glow, rgba(89,201,165,0.05)), transparent 60%);
  pointer-events: none;
}

/* ── Glass Panel ────────────────────────────────────────── */
.glass-panel {
  background: rgba(255,255,255,0.03); backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px); border: 1px solid rgba(255,255,255,0.06);
  border-radius: 20px;
}

/* ── Header ─────────────────────────────────────────────── */
.app-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px 28px; z-index: 10; position: relative;
  border-bottom: 1px solid rgba(255,255,255,0.04);
}
.app-header h1 {
  font-family: 'Cormorant Garamond', serif; font-weight: 300;
  font-size: 22px; color: rgba(255,255,255,0.9); letter-spacing: 0.5px;
}
.app-header h1 span { color: ${COLORS.gold}; font-weight: 600; }

/* ── Navigation ─────────────────────────────────────────── */
.nav-tabs {
  display: flex; gap: 4px; background: rgba(255,255,255,0.03);
  border-radius: 12px; padding: 4px;
}
.nav-tab {
  padding: 8px 16px; border-radius: 8px; border: none;
  background: transparent; color: rgba(255,255,255,0.5);
  font-family: 'Manrope', sans-serif; font-size: 13px;
  font-weight: 500; cursor: pointer; transition: all 0.3s ease;
  white-space: nowrap;
}
.nav-tab.active {
  background: rgba(197,160,89,0.15); color: ${COLORS.gold};
}
.nav-tab:hover:not(.active) { color: rgba(255,255,255,0.8); }

/* ── Main Content ───────────────────────────────────────── */
.main-content {
  flex: 1; overflow-y: auto; overflow-x: hidden;
  padding: 24px 28px; position: relative; z-index: 1;
  scroll-behavior: smooth; -webkit-overflow-scrolling: touch;
}

/* ── Gallery Grid ───────────────────────────────────────── */
.gallery-grid {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 20px;
}
@media (max-width: 768px) {
  .gallery-grid { grid-template-columns: 1fr; }
}

/* ── Portfolio Card ─────────────────────────────────────── */
.portfolio-card .card-header {
  display: flex; align-items: flex-start; gap: 14px; margin-bottom: 16px;
}
.portfolio-card .card-meta {
  flex: 1; display: flex; flex-direction: column; gap: 4px;
}
.portfolio-card .callsign {
  font-family: 'JetBrains Mono', monospace; font-size: 10px;
  text-transform: uppercase; letter-spacing: 1.5px;
  color: rgba(255,255,255,0.35);
}
.portfolio-card .repo-name {
  font-family: 'Cormorant Garamond', serif; font-size: 20px;
  font-weight: 600; color: rgba(255,255,255,0.9);
}
.portfolio-card .repo-desc {
  font-size: 12px; color: rgba(255,255,255,0.45); line-height: 1.5;
  margin-bottom: 12px;
}
.portfolio-card .lang-tags {
  display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 14px;
}
.portfolio-card .lang-tag {
  font-size: 10px; padding: 3px 8px; border-radius: 6px;
  background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.5);
  font-family: 'JetBrains Mono', monospace;
}
.portfolio-card .card-footer {
  display: flex; justify-content: space-between; align-items: center;
  border-top: 1px solid rgba(255,255,255,0.04); padding-top: 12px;
  font-size: 11px; color: rgba(255,255,255,0.35);
}
.portfolio-card .status-row {
  display: flex; align-items: center; gap: 6px;
}

/* ── Detail View ────────────────────────────────────────── */
.detail-view { max-width: 1000px; margin: 0 auto; }
.detail-header {
  display: flex; align-items: center; gap: 20px; margin-bottom: 32px;
}
.detail-header .back-btn {
  background: rgba(255,255,255,0.06); border: 1px solid rgba(255,255,255,0.08);
  border-radius: 12px; padding: 10px 14px; color: rgba(255,255,255,0.6);
  cursor: pointer; font-size: 14px; transition: all 0.2s;
}
.detail-header .back-btn:hover { background: rgba(255,255,255,0.1); }
.detail-header .detail-title {
  font-family: 'Cormorant Garamond', serif; font-size: 32px;
  font-weight: 300; color: rgba(255,255,255,0.9);
}
.detail-header .detail-callsign {
  font-family: 'JetBrains Mono', monospace; font-size: 11px;
  text-transform: uppercase; letter-spacing: 2px; color: ${COLORS.gold};
}

.detail-sections { display: flex; flex-direction: column; gap: 20px; }

.detail-section {
  background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.05);
  border-radius: 16px; padding: 20px; position: relative;
}
.detail-section h3 {
  font-family: 'Cormorant Garamond', serif; font-size: 16px;
  font-weight: 600; color: rgba(255,255,255,0.7); margin-bottom: 14px;
  display: flex; align-items: center; gap: 8px;
}
.detail-section h3 .section-icon { font-size: 14px; opacity: 0.5; }

/* ── Database Table ─────────────────────────────────────── */
.db-table { width: 100%; border-collapse: collapse; }
.db-table th {
  text-align: left; font-size: 10px; text-transform: uppercase;
  letter-spacing: 1px; color: rgba(255,255,255,0.3); padding: 8px 12px;
  border-bottom: 1px solid rgba(255,255,255,0.06);
  font-family: 'JetBrains Mono', monospace;
}
.db-table td {
  font-size: 13px; color: rgba(255,255,255,0.7); padding: 10px 12px;
  border-bottom: 1px solid rgba(255,255,255,0.03);
}
.db-table tr:hover td { background: rgba(255,255,255,0.02); }

/* ── Calendar Ledger ────────────────────────────────────── */
.calendar-grid {
  display: grid; grid-template-columns: repeat(7, 1fr); gap: 4px;
}
.cal-header {
  font-size: 10px; text-transform: uppercase; text-align: center;
  color: rgba(255,255,255,0.25); padding: 8px 0;
  font-family: 'JetBrains Mono', monospace; letter-spacing: 1px;
}
.cal-day {
  aspect-ratio: 1; border-radius: 10px; display: flex;
  flex-direction: column; align-items: center; justify-content: center;
  font-size: 12px; color: rgba(255,255,255,0.4); position: relative;
  border: 1px solid transparent; cursor: pointer; transition: all 0.2s;
  gap: 2px;
}
.cal-day:hover { border-color: rgba(255,255,255,0.1); }
.cal-day.has-event { background: rgba(89,201,165,0.08); color: rgba(255,255,255,0.7); }
.cal-day.today { border-color: ${COLORS.gold}; color: ${COLORS.gold}; }
.cal-day .event-dot {
  width: 4px; height: 4px; border-radius: 50%; background: ${COLORS.growthGreen};
}

/* ── Event Log ──────────────────────────────────────────── */
.event-log { display: flex; flex-direction: column; gap: 8px; }
.event-item {
  display: flex; gap: 12px; padding: 10px 14px; border-radius: 10px;
  background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.04);
  align-items: flex-start;
}
.event-item .event-time {
  font-family: 'JetBrains Mono', monospace; font-size: 11px;
  color: rgba(255,255,255,0.3); white-space: nowrap; min-width: 80px;
}
.event-item .event-desc { font-size: 13px; color: rgba(255,255,255,0.6); flex: 1; }
.event-item .event-hash {
  font-family: 'JetBrains Mono', monospace; font-size: 10px;
  color: ${COLORS.gold}; opacity: 0.6;
}

/* ── Notes Editor ───────────────────────────────────────── */
.notes-editor {
  background: rgba(0,0,0,0.15); border: 1px solid rgba(255,255,255,0.06);
  border-radius: 12px; padding: 16px; color: rgba(255,255,255,0.7);
  font-family: 'Manrope', sans-serif; font-size: 14px; line-height: 1.7;
  width: 100%; min-height: 120px; resize: vertical;
  outline: none; transition: border-color 0.3s;
}
.notes-editor:focus { border-color: rgba(197,160,89,0.3); }

/* ── File Slots ─────────────────────────────────────────── */
.file-slots { display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 10px; }
.file-slot {
  display: flex; flex-direction: column; align-items: center; gap: 6px;
  padding: 16px 10px; border-radius: 12px; border: 1px dashed rgba(255,255,255,0.1);
  cursor: pointer; transition: all 0.2s; text-align: center;
}
.file-slot:hover { border-color: rgba(255,255,255,0.2); background: rgba(255,255,255,0.02); }
.file-slot .slot-icon { font-size: 24px; opacity: 0.4; }
.file-slot .slot-label {
  font-size: 10px; color: rgba(255,255,255,0.35);
  text-transform: uppercase; letter-spacing: 0.5px;
}
.file-slot.filled { border-style: solid; border-color: rgba(89,201,165,0.2);
  background: rgba(89,201,165,0.04); }
.file-slot.filled .slot-label { color: rgba(255,255,255,0.6); }

/* ── Secrets Field ──────────────────────────────────────── */
.secret-field {
  display: flex; gap: 8px; align-items: center;
}
.secret-input {
  flex: 1; background: rgba(0,0,0,0.2); border: 1px solid rgba(255,255,255,0.06);
  border-radius: 8px; padding: 8px 12px; color: rgba(255,255,255,0.7);
  font-family: 'JetBrains Mono', monospace; font-size: 12px;
}
.secret-input::placeholder { color: rgba(255,255,255,0.2); }

/* ── Settings Panel ─────────────────────────────────────── */
.settings-panel { max-width: 700px; margin: 0 auto; }
.setting-group {
  background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.05);
  border-radius: 16px; padding: 20px; margin-bottom: 16px;
}
.setting-group h3 {
  font-family: 'Cormorant Garamond', serif; font-size: 18px;
  color: rgba(255,255,255,0.8); margin-bottom: 16px;
}
.setting-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 10px 0; border-bottom: 1px solid rgba(255,255,255,0.03);
}
.setting-row:last-child { border-bottom: none; }
.setting-label { font-size: 13px; color: rgba(255,255,255,0.6); }
.setting-value {
  background: rgba(0,0,0,0.2); border: 1px solid rgba(255,255,255,0.06);
  border-radius: 8px; padding: 6px 12px; color: rgba(255,255,255,0.7);
  font-size: 13px; font-family: 'JetBrains Mono', monospace;
}

/* ── Collaborator Invite ────────────────────────────────── */
.collab-list { display: flex; flex-direction: column; gap: 8px; }
.collab-item {
  display: flex; align-items: center; gap: 10px;
  padding: 8px 12px; border-radius: 10px; background: rgba(255,255,255,0.03);
}
.collab-avatar {
  width: 28px; height: 28px; border-radius: 50%;
  background: linear-gradient(135deg, ${COLORS.growthGreen}, ${COLORS.strategicBlue});
  display: flex; align-items: center; justify-content: center;
  font-size: 11px; color: white; font-weight: 600;
}
.collab-email { font-size: 13px; color: rgba(255,255,255,0.6); flex: 1; }

.invite-row { display: flex; gap: 8px; margin-top: 10px; }
.invite-input {
  flex: 1; background: rgba(0,0,0,0.15); border: 1px solid rgba(255,255,255,0.06);
  border-radius: 8px; padding: 8px 12px; color: rgba(255,255,255,0.7);
  font-size: 13px;
}
.invite-input::placeholder { color: rgba(255,255,255,0.2); }

/* ── Buttons ────────────────────────────────────────────── */
.btn {
  padding: 8px 16px; border-radius: 10px; border: none; cursor: pointer;
  font-family: 'Manrope', sans-serif; font-size: 13px; font-weight: 500;
  transition: all 0.2s;
}
.btn-gold {
  background: linear-gradient(135deg, ${COLORS.gold}, ${COLORS.goldDark});
  color: white;
}
.btn-gold:hover { filter: brightness(1.1); transform: translateY(-1px); }
.btn-ghost {
  background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.6);
  border: 1px solid rgba(255,255,255,0.08);
}
.btn-ghost:hover { background: rgba(255,255,255,0.1); }

/* ── Search ─────────────────────────────────────────────── */
.search-bar {
  background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.06);
  border-radius: 12px; padding: 10px 16px; color: rgba(255,255,255,0.7);
  font-size: 14px; width: 240px; outline: none; transition: border-color 0.3s;
}
.search-bar::placeholder { color: rgba(255,255,255,0.25); }
.search-bar:focus { border-color: rgba(197,160,89,0.3); }

/* ── Terminal Output ────────────────────────────────────── */
.terminal-output {
  background: rgba(0,0,0,0.3); border-radius: 10px; padding: 14px;
  font-family: 'JetBrains Mono', monospace; font-size: 12px;
  color: rgba(255,255,255,0.5); max-height: 200px; overflow-y: auto;
  line-height: 1.6; white-space: pre-wrap; word-break: break-all;
}

/* ── Scrollbar ──────────────────────────────────────────── */
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 3px; }
::-webkit-scrollbar-thumb:hover { background: rgba(255,255,255,0.2); }

/* ── Fade In ────────────────────────────────────────────── */
@keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
.fade-in { animation: fadeIn 0.5s ease-out; }

/* ── iPad-specific ──────────────────────────────────────── */
@media (min-width: 768px) and (max-width: 1194px) {
  .gallery-grid { grid-template-columns: repeat(2, 1fr); }
  .app-header { padding: 20px 24px; }
  .main-content { padding: 20px 24px; }
}

/* ── Rotating Border (Active Surface) ───────────────────── */
@keyframes rotateBorder {
  from { --angle: 0deg; }
  to { --angle: 360deg; }
}
.active-border {
  border-image: conic-gradient(from var(--angle, 0deg), rgba(89,201,165,0.3), rgba(197,160,89,0.3), rgba(123,140,222,0.3), rgba(89,201,165,0.3)) 1;
  animation: rotateBorder 8s linear infinite;
}

/* ── Particle Field (CSS-only approximation) ────────────── */
@keyframes float1 { 0%,100% { transform: translate(0,0); } 50% { transform: translate(20px,-15px); } }
@keyframes float2 { 0%,100% { transform: translate(0,0); } 50% { transform: translate(-15px,20px); } }
@keyframes float3 { 0%,100% { transform: translate(0,0); } 50% { transform: translate(10px,10px); } }
.particle {
  position: absolute; width: 3px; height: 3px; border-radius: 50%;
  background: rgba(89,201,165,0.3); pointer-events: none;
}

/* ── PDF Report Preview ─────────────────────────────────── */
.report-preview {
  background: rgba(255,255,255,0.95); color: #122E21; border-radius: 12px;
  padding: 40px; max-width: 800px; margin: 0 auto;
  font-family: 'Cormorant Garamond', serif;
}
.report-preview h1 { font-size: 28px; margin-bottom: 8px; }
.report-preview h2 { font-size: 20px; margin: 24px 0 12px; color: #1B402E; }
.report-preview table { width: 100%; border-collapse: collapse; margin: 12px 0; }
.report-preview th, .report-preview td {
  padding: 8px 12px; text-align: left; border-bottom: 1px solid #E5EBE7;
  font-family: 'Manrope', sans-serif; font-size: 13px;
}
.report-preview th { font-weight: 600; color: #1B402E; }
`;

// ═══════════════════════════════════════════════════════════════════
// COMPONENTS
// ═══════════════════════════════════════════════════════════════════

// ── ChromaticOrb: Bioluminescent logo for each portfolio ────────
function ChromaticOrb({ name, color, size = 48 }) {
  const initials = name.split(/[-_ ]/).map(w => w[0]).join('').slice(0, 2).toUpperCase();
  return (
    <div className="chromatic-orb" style={{
      width: size, height: size, background: `linear-gradient(135deg, ${color}, ${color}dd)`,
    }}>
      {initials}
    </div>
  );
}

// ── BioIndicator: Status light ──────────────────────────────────
function BioIndicator({ status }) {
  return <div className={`bio-indicator ${status}`} title={status} />;
}

// ── PortfolioCard: Gallery mode card ────────────────────────────
function PortfolioCard({ repo, color, onClick }) {
  const callsign = generateCallsign(repo.name);
  const languages = detectLanguages(repo.files);
  return (
    <div className="living-surface portfolio-card fade-in"
      style={{ '--surface-glow': `${color}15` }} onClick={onClick}>
      <div className="card-header">
        <ChromaticOrb name={repo.name} color={color} />
        <div className="card-meta">
          <div className="callsign">{callsign}</div>
          <div className="repo-name">{repo.name}</div>
        </div>
        <BioIndicator status={repo.status} />
      </div>
      <div className="repo-desc">{repo.description}</div>
      <div className="lang-tags">
        {languages.slice(0, 4).map(l => <span key={l} className="lang-tag">{l}</span>)}
      </div>
      <div className="card-footer">
        <span>{new Date(repo.uploadDate).toLocaleDateString()}</span>
        <div className="status-row">
          <span>{repo.files.length} files</span>
          <span style={{ margin: '0 6px', opacity: 0.3 }}>|</span>
          <span>{repo.collaborators.length} collaborator{repo.collaborators.length !== 1 ? 's' : ''}</span>
        </div>
      </div>
    </div>
  );
}

// ── CalendarLedger: Monthly calendar with event logging ─────────
function CalendarLedger({ repos, events }) {
  const today = new Date();
  const year = today.getFullYear();
  const month = today.getMonth();
  const firstDay = new Date(year, month, 1).getDay();
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const monthName = today.toLocaleString('default', { month: 'long', year: 'numeric' });

  const eventsByDay = {};
  events.forEach(e => {
    const d = new Date(e.date).getDate();
    if (!eventsByDay[d]) eventsByDay[d] = [];
    eventsByDay[d].push(e);
  });

  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  return (
    <div className="fade-in">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
        <h2 style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 24, fontWeight: 300,
          color: 'rgba(255,255,255,0.9)' }}>
          {monthName} <span style={{ color: COLORS.gold, fontSize: 14, fontWeight: 500,
            fontFamily: "'Manrope', sans-serif" }}>System Ledger</span>
        </h2>
      </div>

      <div className="glass-panel" style={{ padding: 20, marginBottom: 20 }}>
        <div className="calendar-grid">
          {days.map(d => <div key={d} className="cal-header">{d}</div>)}
          {Array.from({ length: firstDay }, (_, i) => <div key={`e${i}`} />)}
          {Array.from({ length: daysInMonth }, (_, i) => {
            const day = i + 1;
            const isToday = day === today.getDate();
            const hasEvent = eventsByDay[day];
            return (
              <div key={day} className={`cal-day ${isToday ? 'today' : ''} ${hasEvent ? 'has-event' : ''}`}>
                <span>{day}</span>
                {hasEvent && <div className="event-dot" />}
              </div>
            );
          })}
        </div>
      </div>

      <div className="detail-section">
        <h3><span className="section-icon">&#x1D54B;</span> Event Log</h3>
        <div className="event-log">
          {events.slice(0, 15).map((e, i) => (
            <div key={i} className="event-item">
              <div className="event-time">{new Date(e.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</div>
              <div className="event-desc">{e.description}</div>
              <div className="event-hash">{e.hash}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ── DatabaseView: AppFlowy-style database table ─────────────────
function DatabaseView({ repos }) {
  return (
    <div className="fade-in">
      <h2 style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 24, fontWeight: 300,
        color: 'rgba(255,255,255,0.9)', marginBottom: 20 }}>
        Portfolio Database <span style={{ color: COLORS.gold, fontSize: 14, fontWeight: 500,
          fontFamily: "'Manrope', sans-serif" }}>AppFlowy Integration</span>
      </h2>
      <div className="glass-panel" style={{ padding: 4, overflow: 'auto' }}>
        <table className="db-table">
          <thead>
            <tr>
              <th>Status</th><th>Portfolio</th><th>Callsign</th><th>Languages</th>
              <th>Files</th><th>Upload Date</th><th>Last Sync</th>
              <th>Collaborators</th><th>Bitstamp</th>
            </tr>
          </thead>
          <tbody>
            {repos.map((r, i) => {
              const langs = detectLanguages(r.files);
              const hash = generateBitstampHash(r.name + r.lastSync);
              return (
                <tr key={r.id}>
                  <td><BioIndicator status={r.status} /></td>
                  <td style={{ fontWeight: 600, color: 'rgba(255,255,255,0.85)' }}>{r.name}</td>
                  <td style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 10, opacity: 0.5 }}>
                    {generateCallsign(r.name).replace('Operation: ', 'OP:')}
                  </td>
                  <td>{langs.slice(0, 2).join(', ')}</td>
                  <td>{r.files.length}</td>
                  <td>{new Date(r.uploadDate).toLocaleDateString()}</td>
                  <td>{new Date(r.lastSync).toLocaleDateString()}</td>
                  <td>{r.collaborators.length}</td>
                  <td style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 10, color: COLORS.gold, opacity: 0.6 }}>
                    {hash.slice(0, 12)}...
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ── PortfolioDetail: Full slide/portfolio view ──────────────────
function PortfolioDetail({ repo, color, onBack, onUpdate }) {
  const [activeTab, setActiveTab] = useState('overview');
  const [notes, setNotes] = useState(repo.notes);
  const [inviteEmail, setInviteEmail] = useState('');
  const [secretKey, setSecretKey] = useState('');
  const [secretVal, setSecretVal] = useState('');
  const callsign = generateCallsign(repo.name);
  const languages = detectLanguages(repo.files);
  const hash = generateBitstampHash(repo.name + repo.lastSync);

  const fileSlots = [
    { label: 'Design Files', icon: '\u25B3', files: repo.designFiles },
    { label: 'Documentation', icon: '\u2630', files: [] },
    { label: 'Assets', icon: '\u25C7', files: [] },
    { label: 'Configuration', icon: '\u2699', files: [] },
    { label: 'Tests', icon: '\u2713', files: [] },
    { label: 'CI/CD', icon: '\u21BB', files: [] },
  ];

  const tabs = [
    { id: 'overview', label: 'Overview' },
    { id: 'database', label: 'Database' },
    { id: 'calendar', label: 'Calendar' },
    { id: 'notes', label: 'Notes' },
    { id: 'files', label: 'File Slots' },
    { id: 'secrets', label: 'Secrets' },
    { id: 'collabs', label: 'Team' },
  ];

  const repoEvents = [
    { date: repo.lastSync, description: `Snapshot synced for ${repo.name}`, hash: hash },
    { date: repo.uploadDate, description: `Initial upload of ${repo.name}`, hash: generateBitstampHash(repo.name + repo.uploadDate) },
  ];

  return (
    <div className="detail-view fade-in">
      <div className="detail-header">
        <button className="back-btn" onClick={onBack}>&larr;</button>
        <div>
          <div className="detail-callsign">{callsign}</div>
          <div className="detail-title">{repo.name}</div>
        </div>
        <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 12 }}>
          <BioIndicator status={repo.status} />
          <ChromaticOrb name={repo.name} color={color} size={40} />
        </div>
      </div>

      <div className="nav-tabs" style={{ marginBottom: 24 }}>
        {tabs.map(t => (
          <button key={t.id} className={`nav-tab ${activeTab === t.id ? 'active' : ''}`}
            onClick={() => setActiveTab(t.id)}>{t.label}</button>
        ))}
      </div>

      {activeTab === 'overview' && (
        <div className="detail-sections">
          <div className="detail-section">
            <h3><span className="section-icon">&#x2609;</span> Portfolio Information</h3>
            <table className="db-table">
              <tbody>
                <tr><td style={{ color: 'rgba(255,255,255,0.4)', width: 160 }}>Repository URL</td>
                  <td><a href={repo.url} style={{ color: COLORS.growthGreen }}>{repo.url}</a></td></tr>
                <tr><td style={{ color: 'rgba(255,255,255,0.4)' }}>Upload Date</td>
                  <td>{new Date(repo.uploadDate).toLocaleString()}</td></tr>
                <tr><td style={{ color: 'rgba(255,255,255,0.4)' }}>Last Synchronized</td>
                  <td>{new Date(repo.lastSync).toLocaleString()}</td></tr>
                <tr><td style={{ color: 'rgba(255,255,255,0.4)' }}>Languages</td>
                  <td>{languages.join(', ') || 'Unknown'}</td></tr>
                <tr><td style={{ color: 'rgba(255,255,255,0.4)' }}>Files Tracked</td>
                  <td>{repo.files.length}</td></tr>
                <tr><td style={{ color: 'rgba(255,255,255,0.4)' }}>Stars / Forks</td>
                  <td>{repo.stars} / {repo.forks}</td></tr>
                <tr><td style={{ color: 'rgba(255,255,255,0.4)' }}>Bitstamp Hash</td>
                  <td style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 12, color: COLORS.gold }}>{hash}</td></tr>
                <tr><td style={{ color: 'rgba(255,255,255,0.4)' }}>Callsign</td>
                  <td style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 12 }}>{callsign}</td></tr>
                <tr><td style={{ color: 'rgba(255,255,255,0.4)' }}>Collaborators</td>
                  <td>{repo.collaborators.length > 0 ? repo.collaborators.join(', ') : 'None'}</td></tr>
                <tr><td style={{ color: 'rgba(255,255,255,0.4)' }}>Backup Status</td>
                  <td style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <BioIndicator status={repo.status} /> {repo.status}
                  </td></tr>
              </tbody>
            </table>
          </div>

          <div className="detail-section">
            <h3><span className="section-icon">&#x2630;</span> Files</h3>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
              {repo.files.map(f => (
                <span key={f} style={{ fontSize: 12, padding: '4px 10px', borderRadius: 6,
                  background: 'rgba(255,255,255,0.04)', color: 'rgba(255,255,255,0.5)',
                  fontFamily: "'JetBrains Mono', monospace" }}>{f}</span>
              ))}
            </div>
          </div>
        </div>
      )}

      {activeTab === 'database' && (
        <div className="detail-section">
          <h3><span className="section-icon">&#x25A6;</span> Properties Database</h3>
          <table className="db-table">
            <thead>
              <tr><th>Property</th><th>Type</th><th>Value</th></tr>
            </thead>
            <tbody>
              <tr><td>Name</td><td style={{opacity:0.4}}>Text</td><td>{repo.name}</td></tr>
              <tr><td>URL</td><td style={{opacity:0.4}}>URL</td><td>{repo.url}</td></tr>
              <tr><td>Status</td><td style={{opacity:0.4}}>Select</td><td>{repo.status}</td></tr>
              <tr><td>Upload Date</td><td style={{opacity:0.4}}>Date</td><td>{new Date(repo.uploadDate).toLocaleDateString()}</td></tr>
              <tr><td>Last Sync</td><td style={{opacity:0.4}}>Date</td><td>{new Date(repo.lastSync).toLocaleDateString()}</td></tr>
              <tr><td>Languages</td><td style={{opacity:0.4}}>Multi-Select</td><td>{languages.join(', ')}</td></tr>
              <tr><td>File Count</td><td style={{opacity:0.4}}>Number</td><td>{repo.files.length}</td></tr>
              <tr><td>Stars</td><td style={{opacity:0.4}}>Number</td><td>{repo.stars}</td></tr>
              <tr><td>Forks</td><td style={{opacity:0.4}}>Number</td><td>{repo.forks}</td></tr>
              <tr><td>Bitstamp</td><td style={{opacity:0.4}}>Text</td><td style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 11, color: COLORS.gold }}>{hash}</td></tr>
              <tr><td>Callsign</td><td style={{opacity:0.4}}>Text</td><td>{callsign}</td></tr>
              <tr><td>Collaborators</td><td style={{opacity:0.4}}>Multi-Select</td><td>{repo.collaborators.join(', ') || '—'}</td></tr>
              <tr><td>Design Files</td><td style={{opacity:0.4}}>Files</td><td>{repo.designFiles.join(', ') || '—'}</td></tr>
            </tbody>
          </table>
        </div>
      )}

      {activeTab === 'calendar' && (
        <CalendarLedger repos={[repo]} events={repoEvents} />
      )}

      {activeTab === 'notes' && (
        <div className="detail-section">
          <h3><span className="section-icon">&#x270E;</span> Landing Page &amp; Notes</h3>
          <textarea className="notes-editor" value={notes}
            onChange={e => setNotes(e.target.value)}
            placeholder="Write notes, landing page content, documentation..." />
          <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
            <button className="btn btn-gold" onClick={() => onUpdate({ ...repo, notes })}>
              Save Notes
            </button>
          </div>
        </div>
      )}

      {activeTab === 'files' && (
        <div className="detail-section">
          <h3><span className="section-icon">&#x25C7;</span> File Slots</h3>
          <div className="file-slots">
            {fileSlots.map((slot, i) => (
              <div key={i} className={`file-slot ${slot.files.length > 0 ? 'filled' : ''}`}>
                <div className="slot-icon">{slot.icon}</div>
                <div className="slot-label">{slot.label}</div>
                {slot.files.length > 0 && (
                  <div style={{ fontSize: 10, color: COLORS.growthGreen }}>
                    {slot.files.length} file{slot.files.length !== 1 ? 's' : ''}
                  </div>
                )}
              </div>
            ))}
          </div>
          {repo.designFiles.length > 0 && (
            <div style={{ marginTop: 16 }}>
              <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.4)', marginBottom: 8 }}>Attached Design Files:</div>
              {repo.designFiles.map((f, i) => (
                <div key={i} style={{ fontSize: 13, color: 'rgba(255,255,255,0.6)', padding: '4px 0',
                  fontFamily: "'JetBrains Mono', monospace" }}>
                  &#x25C6; {f}
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {activeTab === 'secrets' && (
        <div className="detail-section">
          <h3><span className="section-icon">&#x26BF;</span> Secrets Vault</h3>
          <p style={{ fontSize: 12, color: 'rgba(255,255,255,0.35)', marginBottom: 16 }}>
            Encrypted secrets stored locally. Never synced to remote unless explicitly configured.
          </p>
          {(repo.secrets || []).map((s, i) => (
            <div key={i} className="secret-field" style={{ marginBottom: 8 }}>
              <input className="secret-input" value={s.key} readOnly style={{ maxWidth: 160 }} />
              <input className="secret-input" type="password" value={s.value} readOnly />
            </div>
          ))}
          <div className="secret-field" style={{ marginTop: 12 }}>
            <input className="secret-input" placeholder="Key name" value={secretKey}
              onChange={e => setSecretKey(e.target.value)} style={{ maxWidth: 160 }} />
            <input className="secret-input" placeholder="Secret value" value={secretVal}
              onChange={e => setSecretVal(e.target.value)} type="password" />
            <button className="btn btn-gold" onClick={() => {
              if (secretKey && secretVal) {
                const updated = { ...repo, secrets: [...(repo.secrets || []), { key: secretKey, value: secretVal }] };
                onUpdate(updated); setSecretKey(''); setSecretVal('');
              }
            }}>Add</button>
          </div>
        </div>
      )}

      {activeTab === 'collabs' && (
        <div className="detail-section">
          <h3><span className="section-icon">&#x2605;</span> Collaborators</h3>
          <div className="collab-list">
            {repo.collaborators.map((c, i) => (
              <div key={i} className="collab-item">
                <div className="collab-avatar">{c[0].toUpperCase()}</div>
                <div className="collab-email">{c}</div>
                <span style={{ fontSize: 11, color: COLORS.growthGreen }}>Active</span>
              </div>
            ))}
          </div>
          <div className="invite-row">
            <input className="invite-input" placeholder="Invite collaborator by email..."
              value={inviteEmail} onChange={e => setInviteEmail(e.target.value)} />
            <button className="btn btn-gold" onClick={() => {
              if (inviteEmail) {
                onUpdate({ ...repo, collaborators: [...repo.collaborators, inviteEmail] });
                setInviteEmail('');
              }
            }}>Invite</button>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Settings: Kopia + AppFlowy Integration ──────────────────────
function SettingsView() {
  const [kopiaPath, setKopiaPath] = useState('C:\\Program Files\\Kopia\\kopia.exe');
  const [repoPath, setRepoPath] = useState('C:\\Users\\user\\KopiaBackups');
  const [schedule, setSchedule] = useState('0 */6 * * *');
  const [retention, setRetention] = useState('30');
  const [appflowyPath, setAppflowyPath] = useState('C:\\Users\\user\\AppFlowy');
  const [serverUrl, setServerUrl] = useState('https://localhost:51515');
  const [compression, setCompression] = useState('zstd-fastest');
  const [encryption, setEncryption] = useState('AES256-GCM');

  return (
    <div className="settings-panel fade-in">
      <h2 style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 24, fontWeight: 300,
        color: 'rgba(255,255,255,0.9)', marginBottom: 24 }}>
        Settings <span style={{ color: COLORS.gold, fontSize: 14, fontWeight: 500,
          fontFamily: "'Manrope', sans-serif" }}>Intuitive Defaults</span>
      </h2>

      <div className="setting-group">
        <h3>Kopia Backup Engine</h3>
        <div className="setting-row">
          <span className="setting-label">Kopia Executable</span>
          <input className="setting-value" value={kopiaPath} onChange={e => setKopiaPath(e.target.value)} />
        </div>
        <div className="setting-row">
          <span className="setting-label">Repository Path</span>
          <input className="setting-value" value={repoPath} onChange={e => setRepoPath(e.target.value)} />
        </div>
        <div className="setting-row">
          <span className="setting-label">Snapshot Schedule (Cron)</span>
          <input className="setting-value" value={schedule} onChange={e => setSchedule(e.target.value)} />
        </div>
        <div className="setting-row">
          <span className="setting-label">Retention (days)</span>
          <input className="setting-value" value={retention} onChange={e => setRetention(e.target.value)} style={{ width: 60 }} />
        </div>
        <div className="setting-row">
          <span className="setting-label">Compression</span>
          <select className="setting-value" value={compression} onChange={e => setCompression(e.target.value)}
            style={{ background: 'rgba(0,0,0,0.2)', border: '1px solid rgba(255,255,255,0.06)',
              color: 'rgba(255,255,255,0.7)', borderRadius: 8, padding: '6px 12px' }}>
            <option value="zstd-fastest">ZSTD Fastest</option>
            <option value="zstd-better">ZSTD Better</option>
            <option value="gzip">GZIP</option>
            <option value="none">None</option>
          </select>
        </div>
        <div className="setting-row">
          <span className="setting-label">Encryption</span>
          <select className="setting-value" value={encryption} onChange={e => setEncryption(e.target.value)}
            style={{ background: 'rgba(0,0,0,0.2)', border: '1px solid rgba(255,255,255,0.06)',
              color: 'rgba(255,255,255,0.7)', borderRadius: 8, padding: '6px 12px' }}>
            <option value="AES256-GCM">AES-256-GCM</option>
            <option value="CHACHA20-POLY1305">ChaCha20-Poly1305</option>
          </select>
        </div>
      </div>

      <div className="setting-group">
        <h3>AppFlowy Integration</h3>
        <div className="setting-row">
          <span className="setting-label">AppFlowy Data Path</span>
          <input className="setting-value" value={appflowyPath} onChange={e => setAppflowyPath(e.target.value)} />
        </div>
        <div className="setting-row">
          <span className="setting-label">Auto-create Database</span>
          <span className="setting-value" style={{ color: COLORS.growthGreen }}>Enabled</span>
        </div>
        <div className="setting-row">
          <span className="setting-label">Calendar Sync</span>
          <span className="setting-value" style={{ color: COLORS.growthGreen }}>Enabled</span>
        </div>
        <div className="setting-row">
          <span className="setting-label">Auto-generate Slides</span>
          <span className="setting-value" style={{ color: COLORS.growthGreen }}>Enabled</span>
        </div>
      </div>

      <div className="setting-group">
        <h3>Server Configuration</h3>
        <div className="setting-row">
          <span className="setting-label">Upload Server URL</span>
          <input className="setting-value" value={serverUrl} onChange={e => setServerUrl(e.target.value)} />
        </div>
        <div className="setting-row">
          <span className="setting-label">Auto-analyze Projects</span>
          <span className="setting-value" style={{ color: COLORS.growthGreen }}>Enabled</span>
        </div>
        <div className="setting-row">
          <span className="setting-label">Bitstamp Verification</span>
          <span className="setting-value" style={{ color: COLORS.growthGreen }}>openbitstamp.org</span>
        </div>
      </div>

      <div className="setting-group">
        <h3>PDF Report Settings (iPad)</h3>
        <div className="setting-row">
          <span className="setting-label">Report Engine</span>
          <span className="setting-value">PDFKit</span>
        </div>
        <div className="setting-row">
          <span className="setting-label">Auto-generate on Sync</span>
          <span className="setting-value" style={{ color: COLORS.gold }}>Optional</span>
        </div>
        <div className="setting-row">
          <span className="setting-label">Include Bitstamp Hashes</span>
          <span className="setting-value" style={{ color: COLORS.growthGreen }}>Enabled</span>
        </div>
      </div>

      <div style={{ textAlign: 'center', marginTop: 20 }}>
        <button className="btn btn-gold" style={{ padding: '12px 32px', fontSize: 14 }}>
          Save &amp; Apply Configuration
        </button>
      </div>
    </div>
  );
}

// ── PDF Report Preview (for iPad) ───────────────────────────────
function ReportPreview({ repos }) {
  const today = new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
  return (
    <div className="fade-in" style={{ maxWidth: 800, margin: '0 auto' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
        <h2 style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 24, fontWeight: 300,
          color: 'rgba(255,255,255,0.9)' }}>
          Report Preview <span style={{ color: COLORS.gold, fontSize: 14, fontWeight: 500,
            fontFamily: "'Manrope', sans-serif" }}>PDFKit</span>
        </h2>
        <button className="btn btn-gold">Export PDF</button>
      </div>
      <div className="report-preview">
        <h1 style={{ color: '#0A1C14' }}>Resonance GitHub Backup Portal</h1>
        <p style={{ color: '#5C7065', fontFamily: "'Manrope', sans-serif", fontSize: 13 }}>
          Generated: {today} | Portfolios: {repos.length} | Engine: Kopia + AppFlowy
        </p>

        {repos.map((repo, i) => {
          const langs = detectLanguages(repo.files);
          const hash = generateBitstampHash(repo.name + repo.lastSync);
          return (
            <div key={i}>
              <h2>{generateCallsign(repo.name)}</h2>
              <table>
                <tbody>
                  <tr><th>Repository</th><td>{repo.name}</td></tr>
                  <tr><th>URL</th><td>{repo.url}</td></tr>
                  <tr><th>Description</th><td>{repo.description}</td></tr>
                  <tr><th>Languages</th><td>{langs.join(', ')}</td></tr>
                  <tr><th>Files</th><td>{repo.files.length}</td></tr>
                  <tr><th>Upload Date</th><td>{new Date(repo.uploadDate).toLocaleDateString()}</td></tr>
                  <tr><th>Last Sync</th><td>{new Date(repo.lastSync).toLocaleDateString()}</td></tr>
                  <tr><th>Status</th><td>{repo.status}</td></tr>
                  <tr><th>Bitstamp Hash</th><td style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 11 }}>{hash}</td></tr>
                  <tr><th>Collaborators</th><td>{repo.collaborators.join(', ') || 'None'}</td></tr>
                  <tr><th>Design Files</th><td>{repo.designFiles.join(', ') || 'None'}</td></tr>
                </tbody>
              </table>
            </div>
          );
        })}

        <h2>System Configuration</h2>
        <table>
          <tbody>
            <tr><th>Backup Engine</th><td>Kopia (encrypted, deduplicated)</td></tr>
            <tr><th>Database</th><td>AppFlowy (auto-generated slides)</td></tr>
            <tr><th>Compression</th><td>ZSTD Fastest</td></tr>
            <tr><th>Encryption</th><td>AES-256-GCM</td></tr>
            <tr><th>Schedule</th><td>Every 6 hours (0 */6 * * *)</td></tr>
            <tr><th>Bitstamp Source</th><td>openbitstamp.org</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════
// MAIN APP
// ═══════════════════════════════════════════════════════════════════

export default function App() {
  const [view, setView] = useState('gallery');
  const [repos, setRepos] = useState(INITIAL_REPOS);
  const [selectedRepo, setSelectedRepo] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [terminalOutput, setTerminalOutput] = useState('');
  const [showTerminal, setShowTerminal] = useState(false);

  // Generate system events
  const systemEvents = repos.flatMap(r => [
    { date: r.lastSync, description: `Kopia snapshot: ${r.name}`, hash: generateBitstampHash(r.name + r.lastSync) },
    { date: r.uploadDate, description: `Initial upload: ${r.name}`, hash: generateBitstampHash(r.name + r.uploadDate) },
    { date: new Date(new Date(r.lastSync).getTime() - 86400000).toISOString(),
      description: `Policy check: ${r.name}`, hash: generateBitstampHash(r.name + 'policy') },
    { date: new Date(new Date(r.lastSync).getTime() - 172800000).toISOString(),
      description: `Bitstamp verified: ${r.name}`, hash: generateBitstampHash(r.name + 'bitstamp') },
  ]).sort((a, b) => new Date(b.date) - new Date(a.date));

  const filteredRepos = repos.filter(r =>
    r.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    r.description.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const updateRepo = (updated) => {
    setRepos(prev => prev.map(r => r.id === updated.id ? updated : r));
    setSelectedRepo(updated);
  };

  // Electron IPC listener
  useEffect(() => {
    if (typeof window !== 'undefined' && window.require) {
      try {
        const { ipcRenderer } = window.require('electron');
        ipcRenderer.on('server:output', (_, data) => {
          setTerminalOutput(prev => prev + `\n$ ${data.command}\n${data.stdout || data.stderr || data.error}\n`);
          setShowTerminal(true);
        });
        ipcRenderer.on('menu:view-gallery', () => { setView('gallery'); setSelectedRepo(null); });
        ipcRenderer.on('menu:view-calendar', () => { setView('calendar'); setSelectedRepo(null); });
        ipcRenderer.on('menu:view-database', () => { setView('database'); setSelectedRepo(null); });
        ipcRenderer.on('menu:settings', () => { setView('settings'); setSelectedRepo(null); });
        ipcRenderer.on('menu:generate-report', () => { setView('report'); setSelectedRepo(null); });
        ipcRenderer.on('menu:toggle-dark', () => document.body.classList.toggle('theme-deep'));
      } catch (e) { /* Not in Electron */ }
    }
  }, []);

  return (
    <>
      <style>{styles}</style>
      <div className="app-container paper-noise">
        {/* Breathing Blobs */}
        <div className="blob-container">
          <div className="blob blob-1" />
          <div className="blob blob-2" />
          <div className="blob blob-3" />
        </div>

        {/* Header */}
        <div className="app-header glass-panel" style={{ borderRadius: 0 }}>
          <h1><span>Resonance</span> GitHub Backup Portal</h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <input className="search-bar" placeholder="Search portfolios..."
              value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
            <div className="nav-tabs">
              {[
                { id: 'gallery', label: 'Gallery' },
                { id: 'database', label: 'Database' },
                { id: 'calendar', label: 'Ledger' },
                { id: 'report', label: 'Report' },
                { id: 'settings', label: 'Settings' },
              ].map(t => (
                <button key={t.id} className={`nav-tab ${view === t.id && !selectedRepo ? 'active' : ''}`}
                  onClick={() => { setView(t.id); setSelectedRepo(null); }}>
                  {t.label}
                </button>
              ))}
            </div>
            <button className="btn btn-ghost" onClick={() => setShowTerminal(!showTerminal)}
              style={{ fontSize: 12, fontFamily: "'JetBrains Mono', monospace" }}>
              {showTerminal ? 'Hide' : 'Terminal'}
            </button>
          </div>
        </div>

        {/* Main Content */}
        <div className="main-content">
          {selectedRepo ? (
            <PortfolioDetail
              repo={selectedRepo}
              color={CHROMATIC_PALETTE[selectedRepo.id % CHROMATIC_PALETTE.length]}
              onBack={() => setSelectedRepo(null)}
              onUpdate={updateRepo}
            />
          ) : view === 'gallery' ? (
            <div className="gallery-grid">
              {filteredRepos.map((r, i) => (
                <PortfolioCard key={r.id} repo={r}
                  color={CHROMATIC_PALETTE[r.id % CHROMATIC_PALETTE.length]}
                  onClick={() => setSelectedRepo(r)} />
              ))}
            </div>
          ) : view === 'database' ? (
            <DatabaseView repos={filteredRepos} />
          ) : view === 'calendar' ? (
            <CalendarLedger repos={repos} events={systemEvents} />
          ) : view === 'report' ? (
            <ReportPreview repos={repos} />
          ) : view === 'settings' ? (
            <SettingsView />
          ) : null}
        </div>

        {/* Terminal Drawer */}
        {showTerminal && (
          <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 20,
            borderTop: '1px solid rgba(255,255,255,0.06)' }}>
            <div className="glass-panel" style={{ borderRadius: '16px 16px 0 0', padding: 16 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
                <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.4)',
                  fontFamily: "'JetBrains Mono', monospace" }}>Server Terminal</span>
                <button style={{ background: 'none', border: 'none', color: 'rgba(255,255,255,0.3)',
                  cursor: 'pointer', fontSize: 14 }} onClick={() => setShowTerminal(false)}>x</button>
              </div>
              <div className="terminal-output">
                {terminalOutput || '$ Ready. Use File menu or Server menu for commands.\n$ Kopia, Git, and server commands available.'}
              </div>
            </div>
          </div>
        )}
      </div>
    </>
  );
}
