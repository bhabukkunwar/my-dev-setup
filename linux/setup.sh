#!/usr/bin/env bash
# =============================================================
# Ubuntu Developer Setup — Modular Installer
# Usage: bash setup.sh [module ...] or bash setup.sh (runs all)
# =============================================================
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'
ok()      { echo -e "${GREEN}[OK]${NC}   $1"; }
section() { echo -e "\n${BLUE}── $1 ──${NC}"; }
info()    { echo -e "${YELLOW}[INFO]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

ALL_MODULES=(
  system
  fonts
  i3
  ghostty
  neovim
  tmux
  node
  ssh
  tools
)

run_module() {
  local mod="$1"
  local file="$MODULES_DIR/${mod}.sh"
  if [[ ! -f "$file" ]]; then
    echo "Module not found: $mod"
    exit 1
  fi
  source "$file"
}

if [[ $# -eq 0 ]]; then
  for mod in "${ALL_MODULES[@]}"; do
    run_module "$mod"
  done
else
  for mod in "$@"; do
    run_module "$mod"
  done
fi

echo ""
echo -e "${GREEN}All done! Next steps:${NC}"
echo "  1. Log out → select i3 from login screen"
echo "  2. Open Ghostty → run nvim (LazyVim installs plugins)"
echo "  3. In tmux: Ctrl+a then Shift+I to install plugins"
echo "  4. ssh-add ~/.ssh/macbhabukunwar (one time)"
echo "  5. Run 'claude' to authenticate Claude Code"
