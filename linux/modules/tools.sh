#!/usr/bin/env bash
section "Tools"

# Flameshot (screenshots)
sudo apt install -y flameshot
ok "Flameshot installed"

# arandr (display/monitor settings GUI)
sudo apt install -y arandr
ok "arandr installed"

# Bluetooth
sudo apt install -y blueman
ok "blueman installed"

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit /usr/local/bin
ok "lazygit installed"
