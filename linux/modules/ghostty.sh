#!/usr/bin/env bash
section "Ghostty"
if ! command -v ghostty &>/dev/null; then
  sudo apt install -y ghostty 2>/dev/null || {
    sudo apt install -y libgtk-4-dev libadwaita-1-dev
    wget -q "https://github.com/ghostty-org/ghostty/releases/latest/download/ghostty-linux-x86_64.tar.gz" -O /tmp/ghostty.tar.gz
    tar -xf /tmp/ghostty.tar.gz -C /tmp/
    sudo mv /tmp/ghostty /usr/local/bin/ghostty
  }
fi

mkdir -p ~/.config/ghostty
cat >~/.config/ghostty/config <<'EOF'
font-family = JetBrainsMono Nerd Font
font-size = 14
theme = Catppuccin Macchiato
window-padding-x = 12
window-padding-y = 10
background-opacity = 0.95
cursor-style = block
cursor-style-blink = false
shell-integration = bash
scrollback-limit = 10000
mouse-hide-while-typing = true
confirm-close-surface = false
keybind = ctrl+shift+t=new_tab
keybind = ctrl+shift+w=close_surface
keybind = ctrl+shift+d=new_split:right
keybind = ctrl+shift+minus=new_split:down
keybind = ctrl+equal=increase_font_size:1
keybind = ctrl+minus=decrease_font_size:1
EOF
ok "Ghostty configured"
