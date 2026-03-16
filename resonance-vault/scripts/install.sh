#!/bin/bash
# ╔═══════════════════════════════════════════════════════════╗
# ║  RESONANCE VAULT — Linux Install Script                  ║
# ╚═══════════════════════════════════════════════════════════╝

set -e

GREEN='\033[0;32m'
GOLD='\033[0;33m'
DIM='\033[0;90m'
NC='\033[0m'

echo ""
echo -e "${GREEN}  ╔═══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}  ║${GOLD}   ◈  RESONANCE VAULT INSTALLER               ${GREEN}║${NC}"
echo -e "${GREEN}  ╚═══════════════════════════════════════════════╝${NC}"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${GOLD}  Node.js not found. Installing via nvm...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

echo -e "${GREEN}  ●${NC} Node.js $(node --version) detected"

# Install dependencies
echo -e "${GREEN}  ●${NC} Installing dependencies..."
cd "$(dirname "$0")/.."
npm install

# Make CLI executable
chmod +x src/cli/index.js

# Link globally (optional)
echo -e "${GREEN}  ●${NC} Linking CLI globally..."
npm link 2>/dev/null || echo -e "${DIM}    (Run with sudo to link globally)${NC}"

# Check for Kopia
if command -v kopia &> /dev/null; then
    echo -e "${GREEN}  ●${NC} Kopia $(kopia --version 2>/dev/null | head -1) detected"
else
    echo -e "${GOLD}  ○${NC} Kopia not found. Install for backup features:"
    echo -e "${DIM}    https://kopia.io/docs/installation/${NC}"
fi

# Initialize
echo -e "${GREEN}  ●${NC} Initializing Resonance Vault..."
node src/cli/index.js init

echo ""
echo -e "${GREEN}  ◈ Installation complete!${NC}"
echo -e "${DIM}  Commands:${NC}"
echo -e "${GOLD}    resonance-vault init${NC}            ${DIM}Initialize system${NC}"
echo -e "${GOLD}    resonance-vault import <url>${NC}    ${DIM}Import a GitHub repo${NC}"
echo -e "${GOLD}    resonance-vault list${NC}            ${DIM}Show all portfolios${NC}"
echo -e "${GOLD}    resonance-vault sync --all${NC}      ${DIM}Sync all repos${NC}"
echo -e "${GOLD}    resonance-vault backup --all${NC}    ${DIM}Backup all repos${NC}"
echo -e "${GOLD}    resonance-vault briefing <name>${NC} ${DIM}Generate portfolio briefing${NC}"
echo -e "${GOLD}    resonance-vault calendar${NC}        ${DIM}View system ledger${NC}"
echo -e "${GOLD}    resonance-vault server${NC}          ${DIM}Start web UI${NC}"
echo ""
