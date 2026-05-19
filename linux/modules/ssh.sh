#!/usr/bin/env bash
section "SSH"
mkdir -p ~/.ssh
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
grep -q 'SSH_AUTH_SOCK' ~/.bashrc || \
  echo 'export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"' >>~/.bashrc
ok "SSH configured"
