#!/usr/bin/env node
// ═══════════════════════════════════════════════════════════════════
// KOPIA SETUP HELPER FOR RESONANCE GITHUB BACKUP PORTAL
// Automates Kopia repository creation, policy configuration,
// and scheduling for GitHub repository backups on Windows
// ═══════════════════════════════════════════════════════════════════

const { execSync, exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

// ── Default Configuration ───────────────────────────────────────
const DEFAULT_CONFIG = {
  kopiaPath: process.platform === 'win32'
    ? 'C:\\Program Files\\Kopia\\kopia.exe'
    : '/usr/local/bin/kopia',
  repositoryPath: path.join(os.homedir(), 'KopiaGitHubBackups'),
  password: '', // Must be set by user
  compression: 'zstd-fastest',
  scheduling: {
    intervalHours: 6,
    cron: '0 */6 * * *',
  },
  retention: {
    keepLatest: 10,
    keepDaily: 7,
    keepWeekly: 4,
    keepMonthly: 6,
    keepAnnual: 2,
  },
  encryption: 'AES256-GCM-HMAC-SHA256',
};

// ── Helper: Run Kopia Command ───────────────────────────────────
function runKopia(args, config = DEFAULT_CONFIG) {
  const cmd = `"${config.kopiaPath}" ${args}`;
  try {
    const result = execSync(cmd, { encoding: 'utf8', timeout: 30000 });
    return { success: true, output: result.trim() };
  } catch (error) {
    return { success: false, error: error.stderr || error.message };
  }
}

// ── Initialize Repository ───────────────────────────────────────
function initializeRepository(config = DEFAULT_CONFIG) {
  console.log('Initializing Kopia repository...');

  // Create repository directory
  if (!fs.existsSync(config.repositoryPath)) {
    fs.mkdirSync(config.repositoryPath, { recursive: true });
    console.log(`  Created: ${config.repositoryPath}`);
  }

  // Create Kopia repository
  const result = runKopia(
    `repository create filesystem --path "${config.repositoryPath}" ` +
    `--password "${config.password}" ` +
    `--block-hash BLAKE3-256-128 ` +
    `--encryption ${config.encryption} ` +
    `--object-splitter DYNAMIC-8M-BUZHASH`,
    config
  );

  if (result.success) {
    console.log('  Repository created successfully.');
  } else {
    console.log(`  Note: ${result.error}`);
  }

  return result;
}

// ── Configure Policies ──────────────────────────────────────────
function configurePolicies(sourcePath, config = DEFAULT_CONFIG) {
  console.log(`Configuring policies for: ${sourcePath}`);

  const ret = config.retention;

  // Set retention policy
  runKopia(
    `policy set "${sourcePath}" ` +
    `--keep-latest ${ret.keepLatest} ` +
    `--keep-daily ${ret.keepDaily} ` +
    `--keep-weekly ${ret.keepWeekly} ` +
    `--keep-monthly ${ret.keepMonthly} ` +
    `--keep-annual ${ret.keepAnnual}`,
    config
  );

  // Set compression
  runKopia(
    `policy set "${sourcePath}" --compression ${config.compression}`,
    config
  );

  // Set scheduling
  runKopia(
    `policy set "${sourcePath}" --snapshot-interval ${config.scheduling.intervalHours}h`,
    config
  );

  // Ignore common non-essential files
  const ignorePatterns = [
    'node_modules', '.git/objects', '__pycache__', '.next',
    'target/debug', 'build/intermediates', '.gradle',
    '*.log', '.DS_Store', 'Thumbs.db',
  ];

  ignorePatterns.forEach(pattern => {
    runKopia(`policy set "${sourcePath}" --add-ignore "${pattern}"`, config);
  });

  console.log('  Policies configured.');
}

// ── Create Snapshot ─────────────────────────────────────────────
function createSnapshot(sourcePath, config = DEFAULT_CONFIG) {
  console.log(`Creating snapshot: ${sourcePath}`);
  const result = runKopia(`snapshot create "${sourcePath}"`, config);
  if (result.success) {
    console.log(`  Snapshot created: ${result.output.split('\n').pop()}`);
  }
  return result;
}

// ── List Snapshots ──────────────────────────────────────────────
function listSnapshots(config = DEFAULT_CONFIG) {
  return runKopia('snapshot list --json', config);
}

// ── Setup GitHub Repo Backup ────────────────────────────────────
function setupGitHubRepoBackup(repoUrl, localPath, config = DEFAULT_CONFIG) {
  console.log(`\nSetting up backup for: ${repoUrl}`);
  console.log(`  Local path: ${localPath}`);

  // Clone or pull the repo
  if (!fs.existsSync(localPath)) {
    console.log('  Cloning repository...');
    try {
      execSync(`git clone "${repoUrl}" "${localPath}"`, { encoding: 'utf8', timeout: 120000 });
      console.log('  Cloned successfully.');
    } catch (e) {
      console.log(`  Clone failed: ${e.message}`);
      return false;
    }
  } else {
    console.log('  Repository exists, pulling latest...');
    try {
      execSync('git pull', { cwd: localPath, encoding: 'utf8', timeout: 60000 });
      console.log('  Pulled latest changes.');
    } catch (e) {
      console.log(`  Pull note: ${e.message}`);
    }
  }

  // Configure Kopia policy for this repo
  configurePolicies(localPath, config);

  // Create initial snapshot
  createSnapshot(localPath, config);

  return true;
}

// ── Generate AppFlowy Database Entry ────────────────────────────
function generateAppFlowyEntry(repoInfo) {
  const { generateCallsign, generateBitstampHash, detectLanguages } = require('./generate-pdf-report');

  return {
    type: 'database_row',
    fields: {
      name: { type: 'text', value: repoInfo.name },
      url: { type: 'url', value: repoInfo.url },
      callsign: { type: 'text', value: generateCallsign(repoInfo.name) },
      status: { type: 'select', value: 'synced', options: ['synced', 'pending', 'error', 'backing-up'] },
      upload_date: { type: 'date', value: new Date().toISOString() },
      last_sync: { type: 'date', value: new Date().toISOString() },
      languages: { type: 'multi_select', value: detectLanguages(repoInfo.files || []) },
      file_count: { type: 'number', value: (repoInfo.files || []).length },
      bitstamp_hash: { type: 'text', value: generateBitstampHash(repoInfo.name + new Date().toISOString()) },
      collaborators: { type: 'multi_select', value: repoInfo.collaborators || [] },
      notes: { type: 'rich_text', value: repoInfo.description || '' },
      secrets: { type: 'relation', value: [] },
      design_files: { type: 'file', value: repoInfo.designFiles || [] },
    },
    calendar_event: {
      title: `Backup: ${repoInfo.name}`,
      date: new Date().toISOString(),
      description: `Initial backup of ${repoInfo.name}`,
      bitstamp: generateBitstampHash(repoInfo.name + new Date().toISOString()),
    },
  };
}

// ── Windows Scheduled Task Setup ────────────────────────────────
function setupWindowsScheduledTask(config = DEFAULT_CONFIG) {
  if (process.platform !== 'win32') {
    console.log('Scheduled task setup is Windows-only. Use cron on other platforms.');
    return;
  }

  const taskXml = `<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <CalendarTrigger>
      <Repetition>
        <Interval>PT${config.scheduling.intervalHours}H</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <StartBoundary>${new Date().toISOString()}</StartBoundary>
      <Enabled>true</Enabled>
    </CalendarTrigger>
  </Triggers>
  <Actions>
    <Exec>
      <Command>"${config.kopiaPath}"</Command>
      <Arguments>snapshot create --all</Arguments>
    </Exec>
  </Actions>
  <Settings>
    <RunOnlyIfNetworkAvailable>true</RunOnlyIfNetworkAvailable>
    <StartWhenAvailable>true</StartWhenAvailable>
  </Settings>
</Task>`;

  const taskFile = path.join(os.tmpdir(), 'resonance-kopia-task.xml');
  fs.writeFileSync(taskFile, taskXml);

  try {
    execSync(`schtasks /Create /TN "Resonance Kopia Backup" /XML "${taskFile}" /F`, { encoding: 'utf8' });
    console.log('Windows scheduled task created: Resonance Kopia Backup');
  } catch (e) {
    console.log(`Note: Run as Administrator to create scheduled task. ${e.message}`);
  }

  fs.unlinkSync(taskFile);
}

// ── CLI Entry Point ─────────────────────────────────────────────
if (require.main === module) {
  const args = process.argv.slice(2);
  const command = args[0];

  console.log('╔══════════════════════════════════════════════════════╗');
  console.log('║  Resonance GitHub Backup Portal — Kopia Setup       ║');
  console.log('╚══════════════════════════════════════════════════════╝\n');

  switch (command) {
    case 'init':
      DEFAULT_CONFIG.password = args[1] || 'resonance-backup-default';
      initializeRepository(DEFAULT_CONFIG);
      break;

    case 'add':
      if (args[1] && args[2]) {
        setupGitHubRepoBackup(args[1], args[2], DEFAULT_CONFIG);
      } else {
        console.log('Usage: kopia-setup.js add <repo-url> <local-path>');
      }
      break;

    case 'snapshot':
      if (args[1]) {
        createSnapshot(args[1], DEFAULT_CONFIG);
      } else {
        console.log('Usage: kopia-setup.js snapshot <path>');
      }
      break;

    case 'list':
      const result = listSnapshots(DEFAULT_CONFIG);
      console.log(result.success ? result.output : result.error);
      break;

    case 'schedule':
      setupWindowsScheduledTask(DEFAULT_CONFIG);
      break;

    default:
      console.log('Commands:');
      console.log('  init <password>              Initialize Kopia repository');
      console.log('  add <repo-url> <local-path>  Add a GitHub repo for backup');
      console.log('  snapshot <path>              Create a snapshot');
      console.log('  list                         List all snapshots');
      console.log('  schedule                     Set up Windows scheduled task');
  }
}

module.exports = {
  initializeRepository,
  configurePolicies,
  createSnapshot,
  listSnapshots,
  setupGitHubRepoBackup,
  generateAppFlowyEntry,
  setupWindowsScheduledTask,
  DEFAULT_CONFIG,
};
