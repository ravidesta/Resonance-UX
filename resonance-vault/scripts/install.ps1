# ╔═══════════════════════════════════════════════════════════╗
# ║  RESONANCE VAULT — Windows Install Script (PowerShell)   ║
# ╚═══════════════════════════════════════════════════════════╝

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "  ╔═══════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║   ◈  RESONANCE VAULT INSTALLER               ║" -ForegroundColor Yellow
Write-Host "  ╚═══════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "  ● Node.js $nodeVersion detected" -ForegroundColor Green
} catch {
    Write-Host "  ○ Node.js not found. Please install from https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "    Or via winget: winget install OpenJS.NodeJS.LTS" -ForegroundColor DarkGray
    exit 1
}

# Install dependencies
Write-Host "  ● Installing dependencies..." -ForegroundColor Green
Push-Location (Split-Path (Split-Path $MyInvocation.MyCommand.Path))
npm install

# Link globally
Write-Host "  ● Linking CLI globally..." -ForegroundColor Green
try {
    npm link
} catch {
    Write-Host "    (Run as Administrator to link globally)" -ForegroundColor DarkGray
}

# Check for Kopia
try {
    $kopiaVersion = kopia --version 2>$null
    Write-Host "  ● Kopia detected" -ForegroundColor Green
} catch {
    Write-Host "  ○ Kopia not found. Install for backup features:" -ForegroundColor Yellow
    Write-Host "    winget install KopiaUI" -ForegroundColor DarkGray
    Write-Host "    https://kopia.io/docs/installation/" -ForegroundColor DarkGray
}

# Initialize
Write-Host "  ● Initializing Resonance Vault..." -ForegroundColor Green
node src/cli/index.js init

Pop-Location

Write-Host ""
Write-Host "  ◈ Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Commands:" -ForegroundColor DarkGray
Write-Host "    resonance-vault init            " -ForegroundColor Yellow -NoNewline; Write-Host "Initialize system" -ForegroundColor DarkGray
Write-Host "    resonance-vault import <url>    " -ForegroundColor Yellow -NoNewline; Write-Host "Import a GitHub repo" -ForegroundColor DarkGray
Write-Host "    resonance-vault list            " -ForegroundColor Yellow -NoNewline; Write-Host "Show all portfolios" -ForegroundColor DarkGray
Write-Host "    resonance-vault sync --all      " -ForegroundColor Yellow -NoNewline; Write-Host "Sync all repos" -ForegroundColor DarkGray
Write-Host "    resonance-vault backup --all    " -ForegroundColor Yellow -NoNewline; Write-Host "Backup all repos" -ForegroundColor DarkGray
Write-Host "    resonance-vault briefing <name> " -ForegroundColor Yellow -NoNewline; Write-Host "Generate portfolio briefing" -ForegroundColor DarkGray
Write-Host "    resonance-vault calendar        " -ForegroundColor Yellow -NoNewline; Write-Host "View system ledger" -ForegroundColor DarkGray
Write-Host "    resonance-vault server          " -ForegroundColor Yellow -NoNewline; Write-Host "Start web UI" -ForegroundColor DarkGray
Write-Host ""
