#!/usr/bin/env bash
section "Nerd Fonts"
mkdir -p ~/.local/share/fonts
wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" -O /tmp/JetBrainsMono.tar.xz
tar -xf /tmp/JetBrainsMono.tar.xz -C ~/.local/share/fonts/
fc-cache -fv >/dev/null
ok "JetBrainsMono Nerd Font installed"
