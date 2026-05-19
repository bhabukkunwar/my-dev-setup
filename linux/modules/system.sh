#!/usr/bin/env bash
section "System Update"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget build-essential unzip \
  xclip xsel ripgrep fd-find bat eza htop jq tree \
  python3 python3-pip python3-venv

[[ ! -f /usr/local/bin/fd ]]  && sudo ln -s "$(which fdfind)" /usr/local/bin/fd   2>/dev/null || true
[[ ! -f /usr/local/bin/bat ]] && sudo ln -s "$(which batcat)" /usr/local/bin/bat  2>/dev/null || true
ok "System updated"
