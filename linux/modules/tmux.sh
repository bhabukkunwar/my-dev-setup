#!/usr/bin/env bash
section "Tmux"
sudo apt install -y tmux
[[ ! -d ~/.tmux/plugins/tpm ]] && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

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
