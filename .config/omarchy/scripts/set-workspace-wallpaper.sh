#!/bin/bash
set -euo pipefail

WS=$(hyprctl activeworkspace -j | jq -r '.id')
WALL_DIR="$HOME/.config/omarchy/workspace-wallpapers"
mkdir -p "$WALL_DIR"

if [[ -n "$1" ]]; then
  IMG=$(realpath "$1")
else
  echo "Usage: $(basename "$0") <path-to-image>"
  exit 1
fi

if [[ ! -f "$IMG" ]]; then
  notify-send "Wallpaper" "File not found: $IMG" -t 3000
  exit 1
fi

ln -nsf "$IMG" "$WALL_DIR/ws-${WS}"

REAL_IMG=$(readlink -f "$IMG")

hyprctl hyprpaper wallpaper "workspace:${WS},${REAL_IMG}"

notify-send "Wallpaper" "Set for workspace $WS" -t 2000
