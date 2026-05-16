#!/usr/bin/env bash
# =============================================================
# Mac Developer Setup
# Aerospace · Ghostty · Neovim (LazyVim) · Tmux · SSH auto-load
# Usage: bash setup.sh
# =============================================================
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
ok() { echo -e "${GREEN}[OK]${NC}   $1"; }
section() { echo -e "\n${BLUE}── $1 ──${NC}"; }

# ── Homebrew ──────────────────────────────────────────────────
section "Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
grep -qF 'homebrew' ~/.bash_profile 2>/dev/null ||
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.bash_profile
ok "Homebrew ready"

# ── Fonts ─────────────────────────────────────────────────────
section "Nerd Fonts"
brew install --cask font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font
ok "Fonts installed"

# ── Aerospace ─────────────────────────────────────────────────
section "Aerospace"
brew install --cask nikitabobko/tap/aerospace
mkdir -p ~/.config/aerospace
cat >~/.config/aerospace/aerospace.toml <<'EOF'
start-at-login = true
after-startup-command = []
automatically-unhide-macos-hidden-apps = true
default-root-container-layout = 'tiles'
default-root-container-orientation = 'auto'
on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

[gaps]
inner.horizontal = 8
inner.vertical   = 8
outer.left       = 8
outer.bottom     = 8
outer.top        = 8
outer.right      = 8

[mode.main.binding]
alt-h = 'focus left'
alt-j = 'focus down'
alt-k = 'focus up'
alt-l = 'focus right'

alt-shift-h = 'move left'
alt-shift-j = 'move down'
alt-shift-k = 'move up'
alt-shift-l = 'move right'

alt-1 = 'workspace 1'
alt-2 = 'workspace 2'
alt-3 = 'workspace 3'
alt-4 = 'workspace 4'
alt-5 = 'workspace 5'
alt-6 = 'workspace 6'
alt-7 = 'workspace 7'
alt-8 = 'workspace 8'
alt-9 = 'workspace 9'

alt-shift-1 = 'move-node-to-workspace 1'
alt-shift-2 = 'move-node-to-workspace 2'
alt-shift-3 = 'move-node-to-workspace 3'
alt-shift-4 = 'move-node-to-workspace 4'
alt-shift-5 = 'move-node-to-workspace 5'
alt-shift-6 = 'move-node-to-workspace 6'
alt-shift-7 = 'move-node-to-workspace 7'
alt-shift-8 = 'move-node-to-workspace 8'
alt-shift-9 = 'move-node-to-workspace 9'

alt-tab       = 'workspace-back-and-forth'
alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

alt-f     = 'macos-native-fullscreen'
alt-space = 'layout floating tiling'

alt-minus   = 'resize smart -60'
alt-equal   = 'resize smart +60'
alt-shift-0 = 'balance-sizes'

alt-ctrl-m = 'focus-monitor 1'
alt-ctrl-b = 'focus-monitor 2'

alt-shift-comma  = 'move-node-to-monitor --wrap-around prev'
alt-shift-period = 'move-node-to-monitor --wrap-around next'

alt-shift-q = 'close'
alt-shift-r = 'reload-config'
alt-r       = 'mode resize'

[mode.resize.binding]
h     = 'resize width  -60'
j     = 'resize height +60'
k     = 'resize height -60'
l     = 'resize width  +60'
b     = 'balance-sizes'
enter = 'mode main'
esc   = 'mode main'
EOF
ok "Aerospace configured"

# ── Ghostty ───────────────────────────────────────────────────
section "Ghostty"
brew install --cask ghostty
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
shell-integration = zsh
shell-integration-features = cursor,sudo,title
scrollback-limit = 10000
mouse-hide-while-typing = true
confirm-close-surface = false
keybind = super+t=new_tab
keybind = super+w=close_surface
keybind = super+d=new_split:right
keybind = super+shift+d=new_split:down
keybind = super+z=toggle_split_zoom
keybind = super+equal=increase_font_size:1
keybind = super+minus=decrease_font_size:1
keybind = super+0=reset_font_size
EOF
ok "Ghostty configured"

# ── Neovim + LazyVim ──────────────────────────────────────────
section "Neovim"
brew install neovim node python3 # node + python3 needed for Mason LSPs
brew install neovim
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
ok "Neovim + LazyVim configured (plugins install on first launch)"

# ── Tmux ──────────────────────────────────────────────────────
section "Tmux"
brew install tmux
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
bind -T copy-mode-vi v   send -X begin-selection
bind -T copy-mode-vi y   send -X copy-pipe-and-cancel 'pbcopy'

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

# ── SSH auto-load ─────────────────────────────────────────────
section "SSH"
cat >~/.ssh/config <<'EOF'
Host *
  AddKeysToAgent yes
  UseKeychain yes
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

mkdir -p ~/Library/LaunchAgents
cat >~/Library/LaunchAgents/com.bhabuk.ssh-agent.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.bhabuk.ssh-agent</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/ssh-add</string>
    <string>--apple-load-keychain</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>LimitLoadToSessionType</key><string>Aqua</string>
</dict>
</plist>
EOF
launchctl load ~/Library/LaunchAgents/com.bhabuk.ssh-agent.plist 2>/dev/null || true
ok "SSH auto-load configured"

# ── Dock ──────────────────────────────────────────────────────
section "Hide Dock"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 1000
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock show-recents -bool false
killall Dock
ok "Dock hidden"

# ── Shottr ────────────────────────────────────────────────────
section "Shottr"
brew install --cask shottr
ok "Shottr installed — open it and set as default screenshot handler"

# ── Claude Code ───────────────────────────────────────────────
section "Claude Code"
npm install -g @anthropic-ai/claude-code
ok "Claude Code installed — run 'claude' to authenticate"

# ── Done ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}All done! Next steps:${NC}"
echo "  1. Open Aerospace → grant Accessibility permission"
echo "  2. Open Ghostty → run nvim to install LazyVim plugins"
echo "  3. In tmux: Ctrl+a then Shift+I to install plugins"
echo "  4. ssh-add --apple-use-keychain ~/.ssh/macbhabukunwar (one time)"
