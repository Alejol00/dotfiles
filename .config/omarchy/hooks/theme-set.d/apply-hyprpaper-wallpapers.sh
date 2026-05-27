#!/bin/bash
# After theme change: ensure hyprpaper is running and apply per-workspace wallpapers
pkill -x swaybg 2>/dev/null || true

if ! pgrep -x hyprpaper >/dev/null; then
  uwsm-app -- hyprpaper &
  sleep 2
fi

~/.config/omarchy/scripts/apply-workspace-wallpapers.sh
