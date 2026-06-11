#!/usr/bin/env bash
section "i3wm"
sudo apt install -y i3 i3status rofi picom feh i3lock pasystray pamixer dunst

mkdir -p ~/.config/i3
cat >~/.config/i3/config <<'EOF'
# i3 config
# Modifier: Super (Mod4 / Windows key)
set $mod Mod4

font pango:JetBrainsMono Nerd Font 10

# Auto-start
exec --no-startup-id picom --daemon
exec --no-startup-id pasystray

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

# App launcher
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

# Screenshots
bindsym Print exec flameshot gui

# Lock screen
bindsym $mod+shift+x exec i3lock -c 1e2030

# Move workspace between monitors
bindsym $mod+shift+greater move workspace to output right
bindsym $mod+shift+less move workspace to output left

# Volume + mic control
bindsym XF86AudioRaiseVolume exec ~/.local/bin/volume.sh up
bindsym XF86AudioLowerVolume exec ~/.local/bin/volume.sh down
bindsym XF86AudioMute        exec ~/.local/bin/volume.sh mute
bindsym XF86AudioMicMute     exec ~/.local/bin/volume.sh micmute

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
  output_format  = "i3bar"
  color_good     = "#a6da95"
  color_degraded = "#eed49f"
  color_bad      = "#ed8796"
}

order += "cpu_usage"
order += "memory"
order += "disk /"
order += "tztime local"

cpu_usage    { format = " CPU %usage" }
memory {
  format             = " MEM %used"
  threshold_degraded = "10%"
}
disk "/"     { format = " %avail" }
tztime local { format = " %a %d %b  %H:%M" }
EOF

# volume script
mkdir -p ~/.local/bin
cat >~/.local/bin/volume.sh <<'EOF'
#!/bin/bash
case "$1" in
  up)      pamixer -i 5 ;;
  down)    pamixer -d 5 ;;
  mute)    pamixer -t ;;
  micmute) pamixer --default-source -t ;;
esac

if [ "$1" = "micmute" ]; then
  MICMUTE=$(pamixer --default-source --get-mute)
  if [ "$MICMUTE" = "true" ]; then
    dunstify -r 9998 -t 1500 "󰍭 Mic Muted"
  else
    dunstify -r 9998 -t 1500 "󰍬 Mic Active"
  fi
else
  VOL=$(pamixer --get-volume)
  MUTE=$(pamixer --get-mute)
  if [ "$MUTE" = "true" ]; then
    dunstify -r 9999 -t 1500 "󰖁 Muted"
  elif [ "$VOL" -ge 70 ]; then
    dunstify -r 9999 -t 1500 "󰕾 Volume: ${VOL}%"
  elif [ "$VOL" -ge 40 ]; then
    dunstify -r 9999 -t 1500 "󰖀 Volume: ${VOL}%"
  else
    dunstify -r 9999 -t 1500 "󰕿 Volume: ${VOL}%"
  fi
fi
EOF
chmod +x ~/.local/bin/volume.sh
# Touchpad: natural scroll + tap to click
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf << 'EOF'
Section "InputClass"
  Identifier "touchpad"
  Driver "libinput"
  MatchIsTouchpad "on"
  Option "NaturalScrolling" "true"
  Option "Tapping" "on"
  Option "TappingButtonMap" "lrm"
EndSection
EOF
ok "i3wm configured"
