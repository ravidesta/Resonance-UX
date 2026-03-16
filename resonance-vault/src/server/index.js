/**
 * ╔═══════════════════════════════════════════════════════════╗
 * ║  RESONANCE VAULT — Server                                ║
 * ║  Express API + Static React UI + Kopia Integration       ║
 * ╚═══════════════════════════════════════════════════════════╝
 */

const express = require('express');
const path = require('path');
const fs = require('fs');
const os = require('os');
const crypto = require('crypto');
const { execSync } = require('child_process');

const IS_WINDOWS = os.platform() === 'win32';
const HOME_DIR = os.homedir();
const CONFIG_DIR = IS_WINDOWS
  ? path.join(process.env.APPDATA || path.join(HOME_DIR, 'AppData', 'Roaming'), 'resonance-vault')
  : path.join(HOME_DIR, '.config', 'resonance-vault');

const app = express();
app.use(express.json());

// ── Serve React build ──
const buildPath = path.join(__dirname, '..', '..', 'build');
if (fs.existsSync(buildPath)) {
  app.use(express.static(buildPath));
}

// ── Config helpers ──
function loadConfig() {
  const p = path.join(CONFIG_DIR, 'config.json');
  return fs.existsSync(p) ? JSON.parse(fs.readFileSync(p, 'utf-8')) : { portfolios: [] };
}

function loadCalendar() {
  const p = path.join(CONFIG_DIR, 'calendar.json');
  return fs.existsSync(p) ? JSON.parse(fs.readFileSync(p, 'utf-8')) : [];
}

// ── API Routes ──

// GET /api/status
app.get('/api/status', (req, res) => {
  const config = loadConfig();
  let kopiaAvailable = false;
  try { execSync('kopia --version', { stdio: 'pipe' }); kopiaAvailable = true; } catch {}

  res.json({
    platform: IS_WINDOWS ? 'windows' : 'linux',
    arch: os.arch(),
    node: process.version,
    portfolios: config.portfolios.length,
    kopia: kopiaAvailable,
    uptime: process.uptime(),
  });
});

// GET /api/portfolios
app.get('/api/portfolios', (req, res) => {
  const config = loadConfig();
  res.json(config.portfolios);
});

// GET /api/portfolios/:id
app.get('/api/portfolios/:id', (req, res) => {
  const config = loadConfig();
  const p = config.portfolios.find(p => p.id === req.params.id || p.name === req.params.id);
  if (!p) return res.status(404).json({ error: 'Portfolio not found' });
  res.json(p);
});

// GET /api/calendar
app.get('/api/calendar', (req, res) => {
  let entries = loadCalendar();
  if (req.query.portfolio) {
    const config = loadConfig();
    const p = config.portfolios.find(p => p.name === req.query.portfolio);
    if (p) entries = entries.filter(e => e.portfolio_id === p.id);
  }
  if (req.query.type) entries = entries.filter(e => e.event_type === req.query.type);
  res.json(entries.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)));
});

// GET /api/settings
app.get('/api/settings', (req, res) => {
  const config = loadConfig();
  const safeConfig = { ...config };
  delete safeConfig.portfolios;
  if (safeConfig.kopia_password) safeConfig.kopia_password = '••••••';
  if (safeConfig.github_token) safeConfig.github_token = '••••••';
  res.json(safeConfig);
});

// POST /api/command
app.post('/api/command', (req, res) => {
  const { command } = req.body;
  const results = { command, status: 'ok', message: '' };

  switch (command) {
    case 'kopia:status':
      try {
        const output = execSync('kopia repository status', { encoding: 'utf-8', stdio: 'pipe' });
        results.message = output;
      } catch (e) {
        results.status = 'error';
        results.message = 'Kopia not connected or not installed';
      }
      break;

    case 'kopia:snapshot':
      results.message = 'Snapshot triggered. Use CLI for full backup: resonance-vault backup --all';
      break;

    case 'sync:all':
      results.message = 'Sync triggered. Use CLI: resonance-vault sync --all';
      break;

    default:
      results.message = `Command ${command} acknowledged`;
  }

  res.json(results);
});

// GET /api/briefing/:name
app.get('/api/briefing/:name', (req, res) => {
  const config = loadConfig();
  const p = config.portfolios.find(p => p.name === req.params.name);
  if (!p) return res.status(404).json({ error: 'Portfolio not found' });

  const format = req.query.format || 'html';
  // Simplified — full briefing generation is in CLI
  res.json({
    portfolio: p.name,
    callsign: p.callsign,
    format,
    message: `Use CLI for full briefing: resonance-vault briefing ${p.name} --format=${format}`,
  });
});

// SPA fallback
app.get('*', (req, res) => {
  if (fs.existsSync(path.join(buildPath, 'index.html'))) {
    res.sendFile(path.join(buildPath, 'index.html'));
  } else {
    res.json({ message: 'Resonance Vault API running. Build React UI with: npm run build' });
  }
});

// ── Start ──
const PORT = process.env.PORT || 7700;
app.listen(PORT, () => {
  console.log(`  ◈  Resonance Vault server running on http://localhost:${PORT}`);
  console.log(`  ●  API: http://localhost:${PORT}/api/status`);
});

module.exports = app;
