#!/usr/bin/env bash
section "Node + Claude Code"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
nvm install --lts
npm install -g @anthropic-ai/claude-code pnpm typescript ts-node
ok "Node + Claude Code installed"
