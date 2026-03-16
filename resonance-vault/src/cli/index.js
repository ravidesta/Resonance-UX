#!/usr/bin/env node

/**
 * ╔═══════════════════════════════════════════════════════════╗
 * ║  RESONANCE VAULT CLI                                     ║
 * ║  GitHub Backup & Portfolio System                        ║
 * ║  Cross-platform: Linux & Windows                         ║
 * ╚═══════════════════════════════════════════════════════════╝
 */

const { Command } = require('commander');
const chalk = require('chalk');
const path = require('path');
const fs = require('fs');
const os = require('os');
const crypto = require('crypto');
const { execSync, spawn } = require('child_process');

// ── Platform Detection ──
const IS_WINDOWS = os.platform() === 'win32';
const HOME_DIR = os.homedir();
const CONFIG_DIR = IS_WINDOWS
  ? path.join(process.env.APPDATA || path.join(HOME_DIR, 'AppData', 'Roaming'), 'resonance-vault')
  : path.join(HOME_DIR, '.config', 'resonance-vault');
const DATA_DIR = IS_WINDOWS
  ? path.join(process.env.LOCALAPPDATA || path.join(HOME_DIR, 'AppData', 'Local'), 'resonance-vault')
  : path.join(HOME_DIR, '.local', 'share', 'resonance-vault');
const BACKUP_DIR = path.join(DATA_DIR, 'backups');
const KOPIA_REPO = path.join(DATA_DIR, 'kopia-repo');

// ── Design Tokens for CLI ──
const C = {
  green: chalk.hex('#59C9A5'),
  gold: chalk.hex('#C5A059'),
  blue: chalk.hex('#7B8CDE'),
  magenta: chalk.hex('#E040FB'),
  amber: chalk.hex('#F4A261'),
  teal: chalk.hex('#4ECDC4'),
  coral: chalk.hex('#EF6461'),
  muted: chalk.hex('#8A9C91'),
  dim: chalk.hex('#5C7065'),
  bright: chalk.hex('#FAFAF8'),
  forest: chalk.hex('#122E21'),
};

// ── Bioluminescent UI Elements ──
const BIO = {
  dot: (color = C.green) => color('●'),
  pulse: (color = C.green) => color('◉'),
  orb: (color = C.gold) => color('◈'),
  line: (w = 50) => C.dim('─'.repeat(w)),
  doubleLine: (w = 50) => C.dim('═'.repeat(w)),
  glow: (text, color = C.green) => color.bold(text),
};

function banner() {
  console.log('');
  console.log(C.green('  ╔═══════════════════════════════════════════════╗'));
  console.log(C.green('  ║') + C.gold.bold('   ◈  RESONANCE VAULT                       ') + C.green('║'));
  console.log(C.green('  ║') + C.muted('   GitHub Backup & Portfolio System           ') + C.green('║'));
  console.log(C.green('  ╚═══════════════════════════════════════════════╝'));
  console.log('');
}

function bioHeader(title) {
  console.log('');
  console.log(`  ${BIO.orb()} ${C.gold.bold(title)}`);
  console.log(`  ${BIO.line(45)}`);
}

// ── Config Management ──
function ensureDirs() {
  [CONFIG_DIR, DATA_DIR, BACKUP_DIR, KOPIA_REPO].forEach(d => {
    if (!fs.existsSync(d)) fs.mkdirSync(d, { recursive: true });
  });
}

function loadConfig() {
  const configPath = path.join(CONFIG_DIR, 'config.json');
  if (fs.existsSync(configPath)) {
    return JSON.parse(fs.readFileSync(configPath, 'utf-8'));
  }
  return {
    github_token: '',
    kopia_repo: KOPIA_REPO,
    kopia_password: '',
    kopia_compression: 'zstd',
    snapshot_interval: '6h',
    retention: { daily: 7, weekly: 4, monthly: 12 },
    bitstamp_enabled: true,
    bitstamp_sources: ['openbitstamp', 'opentimestamps'],
    server_port: 7700,
    theme: 'light',
    portfolios: [],
  };
}

function saveConfig(config) {
  ensureDirs();
  const configPath = path.join(CONFIG_DIR, 'config.json');
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  console.log(`  ${BIO.dot()} Config saved to ${C.muted(configPath)}`);
}

// ── Hash Utilities ──
function hashFile(filePath) {
  const data = fs.readFileSync(filePath);
  return crypto.createHash('sha256').update(data).digest('hex');
}

function hashDirectory(dirPath) {
  const hash = crypto.createHash('sha256');
  function walk(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name));
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      if (entry.name === '.git' || entry.name === 'node_modules') continue;
      if (entry.isDirectory()) {
        walk(fullPath);
      } else {
        hash.update(`${path.relative(dirPath, fullPath)}:`);
        hash.update(fs.readFileSync(fullPath));
      }
    }
  }
  walk(dirPath);
  return hash.digest('hex');
}

// ── Kopia Wrapper ──
function kopiaAvailable() {
  try {
    execSync('kopia --version', { stdio: 'pipe' });
    return true;
  } catch {
    return false;
  }
}

function kopiaExec(args, opts = {}) {
  const cmd = `kopia ${args}`;
  try {
    return execSync(cmd, { encoding: 'utf-8', stdio: opts.silent ? 'pipe' : 'inherit', ...opts });
  } catch (e) {
    if (!opts.silent) console.error(C.coral(`  Error: ${e.message}`));
    return null;
  }
}

// ── Git Utilities ──
function gitClone(url, dest) {
  console.log(`  ${BIO.dot(C.blue)} Cloning ${C.muted(url)}...`);
  try {
    execSync(`git clone --depth=1 "${url}" "${dest}"`, { stdio: 'pipe' });
    return true;
  } catch (e) {
    console.error(C.coral(`  Failed to clone: ${e.message}`));
    return false;
  }
}

function getRepoInfo(dir) {
  try {
    const remote = execSync('git remote get-url origin', { cwd: dir, encoding: 'utf-8', stdio: 'pipe' }).trim();
    const branch = execSync('git rev-parse --abbrev-ref HEAD', { cwd: dir, encoding: 'utf-8', stdio: 'pipe' }).trim();
    return { remote, branch };
  } catch {
    return { remote: '', branch: '' };
  }
}

// ── Language Detection ──
function detectLanguage(dir) {
  const extCounts = {};
  const extMap = {
    '.js': 'JavaScript', '.jsx': 'JavaScript', '.ts': 'TypeScript', '.tsx': 'TypeScript',
    '.py': 'Python', '.go': 'Go', '.rs': 'Rust', '.java': 'Java', '.kt': 'Kotlin',
    '.rb': 'Ruby', '.php': 'PHP', '.swift': 'Swift', '.dart': 'Dart',
    '.c': 'C', '.cpp': 'C++', '.h': 'C', '.hpp': 'C++',
    '.sh': 'Shell', '.bash': 'Shell', '.zsh': 'Shell',
    '.html': 'HTML', '.css': 'CSS', '.md': 'Markdown',
  };

  function walk(d, depth = 0) {
    if (depth > 3) return;
    try {
      const entries = fs.readdirSync(d, { withFileTypes: true });
      for (const entry of entries) {
        if (entry.name.startsWith('.') || entry.name === 'node_modules' || entry.name === 'vendor') continue;
        const full = path.join(d, entry.name);
        if (entry.isDirectory()) {
          walk(full, depth + 1);
        } else {
          const ext = path.extname(entry.name).toLowerCase();
          if (extMap[ext]) {
            extCounts[extMap[ext]] = (extCounts[extMap[ext]] || 0) + 1;
          }
        }
      }
    } catch {}
  }
  walk(dir);

  const sorted = Object.entries(extCounts).sort((a, b) => b[1] - a[1]);
  return sorted.length > 0 ? sorted[0][0] : 'Unknown';
}

// ── Portfolio Briefing Generator (Printable) ──
function generateBriefing(portfolio, format = 'text') {
  const sep = '─'.repeat(60);
  const doubleSep = '═'.repeat(60);

  if (format === 'text') {
    const lines = [
      doubleSep,
      `  RESONANCE VAULT · PORTFOLIO BRIEFING`,
      doubleSep,
      '',
      `  ${portfolio.callsign || 'Operation: ' + portfolio.name}`,
      `  ${portfolio.name}`,
      sep,
      '',
      `  DESCRIPTION`,
      `  ${portfolio.description || '—'}`,
      '',
      `  TECHNICAL PROFILE`,
      `  Language:      ${portfolio.language || '—'}`,
      `  License:       ${portfolio.license || '—'}`,
      `  Branch:        ${portfolio.default_branch || '—'}`,
      `  Visibility:    ${portfolio.visibility || '—'}`,
      `  Size:          ${portfolio.size_kb ? (portfolio.size_kb / 1024).toFixed(1) + ' MB' : '—'}`,
      '',
      `  COMMUNITY`,
      `  Stars:         ${portfolio.stars || 0}`,
      `  Forks:         ${portfolio.forks || 0}`,
      `  Open Issues:   ${portfolio.open_issues || 0}`,
      `  Collaborators: ${(portfolio.collaborators || []).length}`,
      '',
      `  ORIGIN`,
      `  URL:           ${portfolio.original_url || '—'}`,
      `  Uploaded:      ${portfolio.uploaded_at || '—'}`,
      `  Last Sync:     ${portfolio.last_sync || '—'}`,
      '',
      `  TOPICS`,
      `  ${(portfolio.topics || []).join(', ') || '—'}`,
      '',
      `  NOTES`,
      `  ${portfolio.notes || '—'}`,
      '',
      `  COLLABORATORS`,
      ...(portfolio.collaborators || []).map(c => `  · ${c.name} (${c.role}) — ${c.email}`),
      '',
      sep,
      `  Generated: ${new Date().toISOString()}`,
      `  Resonance Vault v1.0`,
      doubleSep,
    ];
    return lines.join('\n');
  }

  if (format === 'html') {
    return `<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<title>${portfolio.callsign || portfolio.name} — Portfolio Briefing</title>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;500;600&family=Manrope:wght@400;500&display=swap" rel="stylesheet">
<style>
  body { font-family: 'Manrope', sans-serif; max-width: 700px; margin: 40px auto; padding: 40px; color: #122E21; background: #FAFAF8; }
  h1 { font-family: 'Cormorant Garamond', serif; font-size: 28px; color: #122E21; margin: 0; }
  h2 { font-family: 'Cormorant Garamond', serif; font-size: 16px; color: #5C7065; margin: 24px 0 8px; text-transform: uppercase; letter-spacing: 2px; }
  .callsign { font-family: 'Cormorant Garamond', serif; font-size: 12px; color: ${portfolio.color || '#59C9A5'}; text-transform: uppercase; letter-spacing: 3px; margin-bottom: 4px; }
  .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
  .row { display: flex; justify-content: space-between; padding: 4px 0; border-bottom: 1px solid #E5EBE7; font-size: 13px; }
  .row .label { color: #8A9C91; }
  .row .value { color: #122E21; font-weight: 500; }
  .tag { display: inline-block; padding: 2px 10px; border-radius: 20px; font-size: 11px; background: ${portfolio.color || '#59C9A5'}20; color: ${portfolio.color || '#59C9A5'}; margin: 2px; }
  .footer { text-align: center; color: #8A9C91; font-size: 10px; margin-top: 40px; padding-top: 16px; border-top: 1px solid #E5EBE7; }
  .bio-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; background: ${portfolio.color || '#59C9A5'}; box-shadow: 0 0 8px ${portfolio.color || '#59C9A5'}; }
  @media print { body { margin: 0; padding: 20px; } }
</style>
</head><body>
<div style="text-align:center; margin-bottom:32px; padding-bottom:24px; border-bottom:2px solid #E5EBE7;">
  <div class="callsign">Resonance Vault · Portfolio Briefing</div>
  <h1>${portfolio.name}</h1>
  <div class="callsign" style="margin-top:4px">${portfolio.callsign || ''}</div>
  <p style="color:#5C7065; font-size:14px;">${portfolio.description || ''}</p>
</div>
<div class="grid">
  <div>
    <h2>Technical Profile</h2>
    ${[['Language', portfolio.language], ['License', portfolio.license], ['Branch', portfolio.default_branch], ['Visibility', portfolio.visibility], ['Size', portfolio.size_kb ? (portfolio.size_kb/1024).toFixed(1)+' MB' : '—']].map(([k,v]) => `<div class="row"><span class="label">${k}</span><span class="value">${v||'—'}</span></div>`).join('')}
  </div>
  <div>
    <h2>Community</h2>
    ${[['Stars', portfolio.stars], ['Forks', portfolio.forks], ['Issues', portfolio.open_issues], ['Collaborators', (portfolio.collaborators||[]).length]].map(([k,v]) => `<div class="row"><span class="label">${k}</span><span class="value">${v||0}</span></div>`).join('')}
  </div>
</div>
<h2>Origin</h2>
<div class="row"><span class="label">URL</span><span class="value" style="font-family:monospace;font-size:11px">${portfolio.original_url||'—'}</span></div>
<div class="row"><span class="label">Uploaded</span><span class="value">${portfolio.uploaded_at||'—'}</span></div>
<h2>Topics</h2>
<div>${(portfolio.topics||[]).map(t => `<span class="tag">${t}</span>`).join('')}</div>
<h2>Notes</h2>
<p style="font-size:13px;line-height:1.6;color:#5C7065">${portfolio.notes||'—'}</p>
<h2>Collaborators</h2>
${(portfolio.collaborators||[]).map(c => `<div class="row"><span class="label"><span class="bio-dot"></span> ${c.name}</span><span class="value">${c.role}</span></div>`).join('')}
<div class="footer">Generated ${new Date().toISOString()} · Resonance Vault v1.0</div>
</body></html>`;
  }

  return '';
}

// ══════════════════════════════════════════════════════
// CLI COMMANDS
// ══════════════════════════════════════════════════════

const program = new Command();
program
  .name('resonance-vault')
  .description('Resonance Vault — GitHub Backup & Portfolio System')
  .version('1.0.0');

// ── Init ──
program
  .command('init')
  .description('Initialize Resonance Vault on this system')
  .action(() => {
    banner();
    bioHeader('Initializing Resonance Vault');
    ensureDirs();

    console.log(`  ${BIO.dot()} Platform: ${C.green(IS_WINDOWS ? 'Windows' : 'Linux')}`);
    console.log(`  ${BIO.dot()} Config:   ${C.muted(CONFIG_DIR)}`);
    console.log(`  ${BIO.dot()} Data:     ${C.muted(DATA_DIR)}`);
    console.log(`  ${BIO.dot()} Backups:  ${C.muted(BACKUP_DIR)}`);

    const config = loadConfig();
    saveConfig(config);

    // Initialize Kopia if available
    if (kopiaAvailable()) {
      console.log(`  ${BIO.dot(C.green)} Kopia detected`);
      console.log(`  ${BIO.dot()} Initializing Kopia repository...`);
      kopiaExec(`repository create filesystem --path="${KOPIA_REPO}" --password=""`, { silent: true });
      console.log(`  ${BIO.dot(C.green)} Kopia repository ready at ${C.muted(KOPIA_REPO)}`);
    } else {
      console.log(`  ${BIO.dot(C.amber)} Kopia not found. Install kopia for backup features.`);
      console.log(`  ${C.muted('  https://kopia.io/docs/installation/')}`);
    }

    console.log('');
    console.log(`  ${BIO.glow('Resonance Vault initialized.', C.green)}`);
    console.log(`  ${C.muted('Run')} ${C.gold('resonance-vault import <repo-url>')} ${C.muted('to add your first portfolio.')}`);
    console.log('');
  });

// ── Import Repository ──
program
  .command('import <url>')
  .description('Import a GitHub repository as a portfolio')
  .option('--name <name>', 'Override portfolio name')
  .action((url, opts) => {
    banner();
    bioHeader('Importing Repository');
    ensureDirs();

    const repoName = opts.name || url.split('/').pop().replace('.git', '');
    const dest = path.join(BACKUP_DIR, repoName);

    if (fs.existsSync(dest)) {
      console.log(`  ${BIO.dot(C.amber)} Portfolio directory already exists: ${C.muted(dest)}`);
      console.log(`  ${C.muted('Use')} ${C.gold('resonance-vault sync ' + repoName)} ${C.muted('to update.')}`);
      return;
    }

    // Clone
    const success = gitClone(url, dest);
    if (!success) return;

    // Analyze
    const language = detectLanguage(dest);
    const projectHash = hashDirectory(dest);
    const callsign = `Operation: ${repoName.split(/[-_]/).map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}`;

    console.log(`  ${BIO.dot(C.green)} Cloned successfully`);
    console.log(`  ${BIO.dot()} Language detected: ${C.green(language)}`);
    console.log(`  ${BIO.dot()} Callsign: ${C.gold(callsign)}`);
    console.log(`  ${BIO.dot()} Project hash: ${C.muted(projectHash.substring(0, 16))}...`);

    // Save to config
    const config = loadConfig();
    const portfolio = {
      id: crypto.randomUUID(),
      name: repoName,
      callsign,
      original_url: url,
      language,
      color: (Object.values({
        JavaScript: '#F7DF1E', TypeScript: '#3178C6', Python: '#3776AB',
        Go: '#00ADD8', Rust: '#DEA584', Dart: '#0175C2',
      })[language] || '#59C9A5'),
      status: 'active',
      created_at: new Date().toISOString(),
      uploaded_at: new Date().toISOString(),
      last_sync: new Date().toISOString(),
      local_path: dest,
      project_hash: projectHash,
    };

    config.portfolios.push(portfolio);
    saveConfig(config);

    // Create Kopia snapshot if available
    if (kopiaAvailable()) {
      console.log(`  ${BIO.dot(C.teal)} Creating Kopia snapshot...`);
      kopiaExec(`snapshot create "${dest}" --description="Initial import: ${repoName}"`, { silent: true });
      console.log(`  ${BIO.dot(C.green)} Snapshot created`);
    }

    // Log to calendar
    const calendarPath = path.join(CONFIG_DIR, 'calendar.json');
    const calendar = fs.existsSync(calendarPath) ? JSON.parse(fs.readFileSync(calendarPath, 'utf-8')) : [];
    calendar.push({
      id: crypto.randomUUID(),
      portfolio_id: portfolio.id,
      event_type: 'upload',
      title: `Initial upload: ${repoName}`,
      timestamp: new Date().toISOString(),
      project_hash: projectHash,
      notes: `Imported from ${url}. Language: ${language}. Hash: ${projectHash}`,
    });
    calendar.push({
      id: crypto.randomUUID(),
      portfolio_id: portfolio.id,
      event_type: 'bitstamp',
      title: `Hash anchored: ${projectHash.substring(0, 12)}...`,
      timestamp: new Date().toISOString(),
      bitstamp_hash: projectHash,
      bitstamp_source: 'internal',
      notes: `Local SHA-256 anchor for initial import`,
    });
    fs.writeFileSync(calendarPath, JSON.stringify(calendar, null, 2));

    console.log(`  ${BIO.dot(C.gold)} Calendar entry logged`);
    console.log(`  ${BIO.dot(C.gold)} Bitstamp hash anchored (internal)`);
    console.log('');
    console.log(`  ${BIO.glow('Portfolio created:', C.green)} ${C.gold(callsign)}`);
    console.log('');
  });

// ── List Portfolios ──
program
  .command('list')
  .alias('ls')
  .description('List all portfolios')
  .option('--json', 'Output as JSON')
  .action((opts) => {
    if (!opts.json) banner();
    const config = loadConfig();

    if (opts.json) {
      console.log(JSON.stringify(config.portfolios, null, 2));
      return;
    }

    if (config.portfolios.length === 0) {
      console.log(`  ${C.muted('No portfolios yet.')} ${C.dim('Run')} ${C.gold('resonance-vault import <url>')} ${C.dim('to begin.')}`);
      return;
    }

    bioHeader('Portfolio Gallery');
    console.log('');

    const langColors = {
      JavaScript: C.gold, TypeScript: C.blue, Python: C.blue,
      Go: C.teal, Rust: C.amber, Dart: C.blue, default: C.green,
    };

    config.portfolios.forEach((p, i) => {
      const lc = langColors[p.language] || langColors.default;
      console.log(`  ${BIO.pulse(lc)} ${chalk.bold(p.name)}`);
      console.log(`    ${C.gold(p.callsign)}`);
      console.log(`    ${C.dim('Language:')} ${lc(p.language || '—')}  ${C.dim('Status:')} ${C.green(p.status)}`);
      console.log(`    ${C.dim('Origin:')} ${C.muted(p.original_url || '—')}`);
      console.log(`    ${C.dim('Last sync:')} ${C.muted(p.last_sync || '—')}`);
      if (p.project_hash) {
        console.log(`    ${C.dim('Hash:')} ${C.muted(p.project_hash.substring(0, 24))}...`);
      }
      console.log('');
    });
  });

// ── Sync ──
program
  .command('sync [name]')
  .description('Sync a portfolio (or all) from GitHub')
  .option('--all', 'Sync all portfolios')
  .action((name, opts) => {
    banner();
    const config = loadConfig();
    const targets = opts.all ? config.portfolios : config.portfolios.filter(p => p.name === name);

    if (targets.length === 0) {
      console.log(`  ${C.coral('Portfolio not found.')} ${C.muted('Run')} ${C.gold('resonance-vault list')} ${C.muted('to see all.')}`);
      return;
    }

    bioHeader('Syncing Portfolios');

    targets.forEach(p => {
      console.log(`  ${BIO.dot(C.blue)} Syncing ${C.gold(p.name)}...`);
      if (!fs.existsSync(p.local_path)) {
        console.log(`    ${C.coral('Local path missing:')} ${C.muted(p.local_path)}`);
        return;
      }

      try {
        execSync('git pull --ff-only', { cwd: p.local_path, stdio: 'pipe' });
        const newHash = hashDirectory(p.local_path);
        const changed = newHash !== p.project_hash;

        if (changed) {
          console.log(`    ${BIO.dot(C.amber)} Changes detected`);
          console.log(`    ${C.dim('Old hash:')} ${C.muted((p.project_hash || '').substring(0, 16))}...`);
          console.log(`    ${C.dim('New hash:')} ${C.muted(newHash.substring(0, 16))}...`);
          p.project_hash = newHash;

          // Log to calendar
          const calendarPath = path.join(CONFIG_DIR, 'calendar.json');
          const calendar = fs.existsSync(calendarPath) ? JSON.parse(fs.readFileSync(calendarPath, 'utf-8')) : [];
          calendar.push({
            id: crypto.randomUUID(),
            portfolio_id: p.id,
            event_type: 'sync',
            title: `Sync: ${p.name} updated`,
            timestamp: new Date().toISOString(),
            project_hash: newHash,
            notes: `Pulled latest changes. New hash: ${newHash}`,
          });
          calendar.push({
            id: crypto.randomUUID(),
            portfolio_id: p.id,
            event_type: 'bitstamp',
            title: `Hash anchored: ${newHash.substring(0, 12)}...`,
            timestamp: new Date().toISOString(),
            bitstamp_hash: newHash,
            bitstamp_source: 'internal',
            notes: 'Post-sync hash anchor',
          });
          fs.writeFileSync(calendarPath, JSON.stringify(calendar, null, 2));
          console.log(`    ${BIO.dot(C.gold)} Calendar & bitstamp updated`);

          // Kopia snapshot
          if (kopiaAvailable()) {
            kopiaExec(`snapshot create "${p.local_path}" --description="Sync: ${p.name}"`, { silent: true });
            console.log(`    ${BIO.dot(C.teal)} Kopia snapshot created`);
          }
        } else {
          console.log(`    ${BIO.dot(C.green)} Already up to date`);
        }

        p.last_sync = new Date().toISOString();
      } catch (e) {
        console.log(`    ${C.coral('Sync failed:')} ${e.message}`);
      }
    });

    saveConfig(config);
    console.log('');
  });

// ── Briefing ──
program
  .command('briefing [name]')
  .description('Generate a portfolio briefing (printable)')
  .option('--format <format>', 'Output format (text|html)', 'text')
  .option('--all', 'Generate briefings for all portfolios')
  .option('-o, --output <path>', 'Output file path')
  .action((name, opts) => {
    const config = loadConfig();
    const targets = opts.all ? config.portfolios : config.portfolios.filter(p => p.name === name);

    if (targets.length === 0) {
      console.log(`  ${C.coral('Portfolio not found.')}`);
      return;
    }

    targets.forEach(p => {
      const content = generateBriefing(p, opts.format);

      if (opts.output) {
        const ext = opts.format === 'html' ? '.html' : '.txt';
        const outPath = opts.all
          ? path.join(opts.output, `${p.name}-briefing${ext}`)
          : opts.output;

        if (opts.all && !fs.existsSync(opts.output)) {
          fs.mkdirSync(opts.output, { recursive: true });
        }

        fs.writeFileSync(outPath, content);
        console.log(`  ${BIO.dot(C.green)} Briefing saved: ${C.muted(outPath)}`);
      } else {
        console.log(content);
      }
    });
  });

// ── Calendar / Ledger ──
program
  .command('calendar')
  .alias('ledger')
  .description('View the system calendar / ledger')
  .option('--portfolio <name>', 'Filter by portfolio')
  .option('--type <type>', 'Filter by event type (upload|sync|change|backup|bitstamp)')
  .option('--json', 'Output as JSON')
  .action((opts) => {
    const calendarPath = path.join(CONFIG_DIR, 'calendar.json');
    let entries = fs.existsSync(calendarPath) ? JSON.parse(fs.readFileSync(calendarPath, 'utf-8')) : [];
    const config = loadConfig();

    if (opts.portfolio) {
      const p = config.portfolios.find(p => p.name === opts.portfolio);
      if (p) entries = entries.filter(e => e.portfolio_id === p.id);
    }
    if (opts.type) entries = entries.filter(e => e.event_type === opts.type);

    if (opts.json) {
      console.log(JSON.stringify(entries, null, 2));
      return;
    }

    banner();
    bioHeader('System Calendar · Ledger');
    console.log('');

    const eventColors = {
      upload: C.green, sync: C.blue, change: C.amber,
      backup: C.teal, restore: C.coral, bitstamp: C.gold,
    };

    entries.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)).forEach(e => {
      const ec = eventColors[e.event_type] || C.muted;
      const portfolio = config.portfolios.find(p => p.id === e.portfolio_id);
      console.log(`  ${BIO.dot(ec)} ${ec(e.event_type.toUpperCase().padEnd(10))} ${chalk.bold(e.title)}`);
      console.log(`    ${C.dim(new Date(e.timestamp).toLocaleString())}${portfolio ? '  ' + C.muted(portfolio.name) : ''}`);
      if (e.project_hash) console.log(`    ${C.dim('Hash:')} ${C.muted(e.project_hash.substring(0, 24))}`);
      if (e.bitstamp_source) console.log(`    ${C.dim('Anchor:')} ${C.gold(e.bitstamp_source)}`);
      if (e.notes) console.log(`    ${C.dim(e.notes)}`);
      console.log('');
    });

    if (entries.length === 0) {
      console.log(`  ${C.muted('No calendar entries yet.')}`);
    }
  });

// ── Status ──
program
  .command('status')
  .description('Show Resonance Vault status')
  .action(() => {
    banner();
    const config = loadConfig();

    bioHeader('System Status');
    console.log(`  ${BIO.dot()} Platform:    ${C.green(IS_WINDOWS ? 'Windows' : 'Linux')} (${os.arch()})`);
    console.log(`  ${BIO.dot()} Node:        ${C.muted(process.version)}`);
    console.log(`  ${BIO.dot()} Config:      ${C.muted(CONFIG_DIR)}`);
    console.log(`  ${BIO.dot()} Data:        ${C.muted(DATA_DIR)}`);
    console.log(`  ${BIO.dot()} Portfolios:  ${C.green(String(config.portfolios.length))}`);
    console.log(`  ${BIO.dot()} Kopia:       ${kopiaAvailable() ? C.green('Available') : C.amber('Not installed')}`);

    const calendarPath = path.join(CONFIG_DIR, 'calendar.json');
    const calCount = fs.existsSync(calendarPath) ? JSON.parse(fs.readFileSync(calendarPath, 'utf-8')).length : 0;
    console.log(`  ${BIO.dot()} Calendar:    ${C.muted(calCount + ' entries')}`);

    console.log('');
    console.log(`  ${BIO.dot(C.gold)} Bitstamp:    ${config.bitstamp_enabled ? C.green('Enabled') : C.muted('Disabled')}`);
    console.log(`  ${BIO.dot(C.gold)} Services:    ${C.muted((config.bitstamp_sources || []).join(', '))}`);
    console.log('');
  });

// ── Backup (Kopia Snapshot) ──
program
  .command('backup [name]')
  .description('Create a Kopia backup snapshot')
  .option('--all', 'Backup all portfolios')
  .action((name, opts) => {
    banner();
    if (!kopiaAvailable()) {
      console.log(`  ${C.coral('Kopia is not installed.')} ${C.muted('Visit https://kopia.io/docs/installation/')}`);
      return;
    }

    const config = loadConfig();
    const targets = opts.all ? config.portfolios : config.portfolios.filter(p => p.name === name);

    bioHeader('Creating Backup Snapshots');

    targets.forEach(p => {
      if (!p.local_path || !fs.existsSync(p.local_path)) {
        console.log(`  ${C.coral('Path missing for')} ${p.name}`);
        return;
      }
      console.log(`  ${BIO.dot(C.teal)} Backing up ${C.gold(p.callsign || p.name)}...`);
      kopiaExec(`snapshot create "${p.local_path}" --description="Manual backup: ${p.name}"`, { silent: true });

      const newHash = hashDirectory(p.local_path);
      const calendarPath = path.join(CONFIG_DIR, 'calendar.json');
      const calendar = fs.existsSync(calendarPath) ? JSON.parse(fs.readFileSync(calendarPath, 'utf-8')) : [];
      calendar.push({
        id: crypto.randomUUID(),
        portfolio_id: p.id,
        event_type: 'backup',
        title: `Kopia snapshot: ${p.name}`,
        timestamp: new Date().toISOString(),
        project_hash: newHash,
        notes: `Manual backup snapshot created`,
      });
      fs.writeFileSync(calendarPath, JSON.stringify(calendar, null, 2));
      console.log(`  ${BIO.dot(C.green)} Done · ${C.muted('Hash: ' + newHash.substring(0, 16))}...`);
    });
    console.log('');
  });

// ── Server ──
program
  .command('server')
  .description('Start the Resonance Vault web server')
  .option('-p, --port <port>', 'Port number', '7700')
  .action((opts) => {
    banner();
    bioHeader('Starting Web Server');
    console.log(`  ${BIO.dot(C.green)} Starting on port ${C.gold(opts.port)}...`);
    console.log(`  ${C.muted('  Open')} ${C.green(`http://localhost:${opts.port}`)} ${C.muted('in your browser')}`);
    console.log('');

    // In a real implementation this would start the Express server
    // For now, show the command
    const serverPath = path.join(__dirname, '..', 'server', 'index.js');
    if (fs.existsSync(serverPath)) {
      require(serverPath);
    } else {
      console.log(`  ${C.muted('Server module not built yet. Run')} ${C.gold('npm run dev')} ${C.muted('for the React UI.')}`);
    }
  });

// ── Config ──
program
  .command('config')
  .description('View or modify configuration')
  .option('--set <key=value>', 'Set a config value')
  .option('--get <key>', 'Get a config value')
  .action((opts) => {
    const config = loadConfig();

    if (opts.set) {
      const [key, ...valueParts] = opts.set.split('=');
      const value = valueParts.join('=');
      config[key] = value;
      saveConfig(config);
      console.log(`  ${BIO.dot(C.green)} Set ${C.gold(key)} = ${C.muted(value)}`);
    } else if (opts.get) {
      console.log(config[opts.get] !== undefined ? config[opts.get] : `  ${C.muted('Key not found')}`);
    } else {
      banner();
      bioHeader('Configuration');
      Object.entries(config).forEach(([k, v]) => {
        if (k === 'portfolios') {
          console.log(`  ${C.dim(k.padEnd(22))} ${C.muted(`[${v.length} portfolios]`)}`);
        } else if (typeof v === 'object') {
          console.log(`  ${C.dim(k.padEnd(22))} ${C.muted(JSON.stringify(v))}`);
        } else {
          const display = k.includes('password') || k.includes('token') ? '••••••' : v;
          console.log(`  ${C.dim(k.padEnd(22))} ${C.muted(String(display))}`);
        }
      });
      console.log('');
    }
  });

program.parse(process.argv);

if (!process.argv.slice(2).length) {
  banner();
  program.outputHelp();
}
