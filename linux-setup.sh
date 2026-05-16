#!/usr/bin/env bash
# =============================================================
# Ubuntu Developer Setup
# i3wm · Ghostty · Neovim (LazyVim) · Tmux · SSH auto-load
# Usage: bash ubuntu-setup.sh
# Tested on Ubuntu 26.04
# =============================================================
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
ok() { echo -e "${GREEN}[OK]${NC}   $1"; }
section() { echo -e "\n${BLUE}── $1 ──${NC}"; }

# ── System update ─────────────────────────────────────────────
section "System Update"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget build-essential unzip \
  xclip xsel ripgrep fd-find bat eza htop jq tree \
  python3 python3-pip python3-venv
# fd and bat have different binary names on Ubuntu
[[ ! -f /usr/local/bin/fd ]] && sudo ln -s $(which fdfind) /usr/local/bin/fd 2>/dev/null || true
[[ ! -f /usr/local/bin/bat ]] && sudo ln -s $(which batcat) /usr/local/bin/bat 2>/dev/null || true
ok "System updated"

# ── Nerd Fonts ────────────────────────────────────────────────
section "Nerd Fonts"
mkdir -p ~/.local/share/fonts
cd /tmp
wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
tar -xf JetBrainsMono.tar.xz -C ~/.local/share/fonts/
fc-cache -fv >/dev/null
cd ~
ok "JetBrainsMono Nerd Font installed"

# ── i3wm ──────────────────────────────────────────────────────
section "i3wm"
sudo apt install -y i3 i3status rofi dunst picom feh
mkdir -p ~/.config/i3

cat >~/.config/i3/config <<'EOF'
# i3 config — mirrors Aerospace keybinds
# Modifier: Alt (Mod1)
set $mod Mod1

font pango:JetBrainsMono Nerd Font 10

# Auto-start
exec --no-startup-id picom --daemon
exec --no-startup-id dunst

# Gaps (built-in i3 4.22+)
gaps inner 8
gaps outer 8

# Borders
default_border pixel 2
client.focused          #8aadf4 #8aadf4 #1e2030 #8aadf4
client.unfocused        #363a4f #1e2030 #939ab7 #363a4f
client.focused_inactive #363a4f #1e2030 #939ab7 #363a4f

# Focus with vim keys
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Move window
bindsym $mod+shift+h move left
bindsym $mod+shift+j move down
bindsym $mod+shift+k move up
bindsym $mod+shift+l move right

# Workspaces
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+6 workspace number 6
bindsym $mod+7 workspace number 7
bindsym $mod+8 workspace number 8
bindsym $mod+9 workspace number 9

# Move window to workspace
bindsym $mod+shift+1 move container to workspace number 1
bindsym $mod+shift+2 move container to workspace number 2
bindsym $mod+shift+3 move container to workspace number 3
bindsym $mod+shift+4 move container to workspace number 4
bindsym $mod+shift+5 move container to workspace number 5
bindsym $mod+shift+6 move container to workspace number 6
bindsym $mod+shift+7 move container to workspace number 7
bindsym $mod+shift+8 move container to workspace number 8
bindsym $mod+shift+9 move container to workspace number 9

# Layout
bindsym $mod+f fullscreen toggle
bindsym $mod+space floating toggle
bindsym $mod+shift+space focus mode_toggle

# Splits
bindsym $mod+v split vertical
bindsym $mod+b split horizontal

# Close window
bindsym $mod+shift+q kill

# App launcher (rofi = Spotlight equivalent)
bindsym $mod+d exec rofi -show drun -show-icons

# Terminal
bindsym $mod+Return exec ghostty

# Reload / restart
bindsym $mod+shift+r restart
bindsym $mod+shift+c reload

# Resize mode
mode "resize" {
  bindsym h resize shrink width  60 px
  bindsym j resize grow   height 60 px
  bindsym k resize shrink height 60 px
  bindsym l resize grow   width  60 px
  bindsym Return mode "default"
  bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"

# Screenshots with Flameshot
bindsym Print exec flameshot gui

# Status bar
bar {
  position top
  status_command i3status
  font pango:JetBrainsMono Nerd Font 10
  colors {
    background #1e2030
    statusline #cad3f5
    separator  #363a4f
    focused_workspace  #8aadf4 #8aadf4 #1e2030
    active_workspace   #363a4f #363a4f #cad3f5
    inactive_workspace #1e2030 #1e2030 #939ab7
    urgent_workspace   #ed8796 #ed8796 #1e2030
  }
}
EOF

# i3status config
mkdir -p ~/.config/i3status
cat >~/.config/i3status/config <<'EOF'
general {
  colors = true
  interval = 2
  color_good     = "#a6da95"
  color_degraded = "#eed49f"
  color_bad      = "#ed8796"
}

order += "cpu_usage"
order += "memory"
order += "disk /"
order += "tztime local"

cpu_usage    { format = " CPU %usage" }
memory       { format = " MEM %used_mem" threshold_degraded = "10%" }
disk "/"     { format = " %avail" }
tztime local { format = " %a %d %b  %H:%M" }
EOF
ok "i3wm configured"

# ── Ghostty ───────────────────────────────────────────────────
section "Ghostty"
# Install via official package if available, else build from source
if ! command -v ghostty &>/dev/null; then
  sudo apt install -y ghostty 2>/dev/null || {
    # Fallback: install dependencies and build
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

# ── Neovim + LazyVim ──────────────────────────────────────────
section "Neovim"
# Install latest Neovim via PPA
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install -y neovim
[[ -d ~/.config/nvim ]] && mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
mkdir -p ~/.config/nvim/lua/plugins

cat >~/.config/nvim/init.lua <<'EOF'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.editor.telescope" },
    { import = "plugins" },
  },
  install = { colorscheme = { "catppuccin", "tokyonight" } },
  checker = { enabled = true, notify = false },
})
EOF

cat >~/.config/nvim/lua/plugins/plugins.lua <<'EOF'
return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000,
    opts = { flavour = "macchiato" } },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
  { "christoomey/vim-tmux-navigator",
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
    },
  },
  { "kdheepak/lazygit.nvim",
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } } },
  { "max397574/better-escape.nvim", event = "InsertEnter",
    opts = { timeout = 300, mappings = { i = { j = { k = "<Esc>" } } } } },
  { "folke/which-key.nvim", event = "VeryLazy",
    init = function()
      vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })
      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
      vim.keymap.set("v", "<", "<gv")
      vim.keymap.set("v", ">", ">gv")
      vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
      vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
      vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
      vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")
    end },
}
EOF
ok "Neovim + LazyVim configured"

# ── Tmux ──────────────────────────────────────────────────────
section "Tmux"
sudo apt install -y tmux
[[ ! -d ~/.tmux/plugins/tpm ]] &&
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

cat >~/.tmux.conf <<'EOF'
unbind C-b
set -g prefix C-a
bind C-a send-prefix

set -g default-terminal "xterm-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
set -g history-limit 50000
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -sg escape-time 0
set -g focus-events on

bind r source-file ~/.tmux.conf \; display "Reloaded!"

bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
unbind '"'
unbind %

is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
bind -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
bind -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
bind -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

bind -r Tab next-window
bind -r BTab previous-window
bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5

setw -g mode-keys vi
bind Escape copy-mode
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -selection clipboard'

set -g status on
set -g status-position top
set -g status-style "bg=#1e2030,fg=#cad3f5"
set -g status-left "#[bg=#8aadf4,fg=#1e2030,bold] #S #[bg=#1e2030,fg=#8aadf4]"
set -g status-right " %a %d %b  %H:%M "
set -g status-left-length 50
set -g status-right-length 50
setw -g window-status-format         "#[fg=#939ab7] #I:#W "
setw -g window-status-current-format "#[fg=#1e2030,bg=#c6a0f6,bold] #I:#W "
set -g pane-border-style "fg=#363a4f"
set -g pane-active-border-style "fg=#8aadf4"
set -g message-style "bg=#c6a0f6,fg=#1e2030,bold"

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'
set -g @continuum-restore 'on'

run '~/.tmux/plugins/tpm/tpm'
EOF
~/.tmux/plugins/tpm/bin/install_plugins || true
ok "Tmux configured"

# ── Node + Claude Code ────────────────────────────────────────
section "Node + Claude Code"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
nvm install --lts
npm install -g @anthropic-ai/claude-code pnpm typescript ts-node
ok "Node + Claude Code installed"

# ── SSH auto-load ─────────────────────────────────────────────
section "SSH"
cat >~/.ssh/config <<'EOF'
Host *
  AddKeysToAgent yes
  ServerAliveInterval 60
  ServerAliveCountMax 3

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/macbhabukunwar

Host gitlab.com
  HostName gitlab.com
  User git
  IdentityFile ~/.ssh/id_ed25519
EOF
chmod 600 ~/.ssh/config

# Systemd user service for SSH agent (Linux equivalent of LaunchAgent)
mkdir -p ~/.config/systemd/user
cat >~/.config/systemd/user/ssh-agent.service <<'EOF'
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
EOF
systemctl --user enable ssh-agent
systemctl --user start ssh-agent
echo 'export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"' >>~/.bashrc
ok "SSH configured"

# ── Flameshot (screenshots) ───────────────────────────────────
section "Flameshot"
sudo apt install -y flameshot
ok "Flameshot installed — Print key opens screenshot tool"

# ── lazygit ───────────────────────────────────────────────────
section "lazygit"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit /usr/local/bin
ok "lazygit installed"

# ── Done ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}All done! Next steps:${NC}"
echo "  1. Log out and select i3 on the login screen"
echo "  2. Open Ghostty → run nvim to install LazyVim plugins"
echo "  3. In tmux: Ctrl+a then Shift+I to install plugins"
echo "  4. ssh-add ~/.ssh/macbhabukunwar (one time)"
echo "  5. Run 'claude' to authenticate Claude Code"
