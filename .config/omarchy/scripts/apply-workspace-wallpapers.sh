#!/bin/bash
set -euo pipefail

WALL_DIR="$HOME/.config/omarchy/workspace-wallpapers"
mkdir -p "$WALL_DIR"

sleep 1

for f in "$WALL_DIR"/ws-*; do
  [[ -L "$f" ]] || continue
  ws=$(basename "$f" | sed 's/^ws-//')
  img=$(readlink "$f")
  if [[ -n "$img" && -f "$img" ]]; then
    real_img=$(readlink -f "$img")
    hyprctl hyprpaper wallpaper "workspace:${ws},${real_img}" 2>/dev/null || true
  fi
done

GLOBAL_BG=$(readlink -f "$HOME/.config/omarchy/current/background" 2>/dev/null || true)
if [[ -n "$GLOBAL_BG" && -f "$GLOBAL_BG" ]]; then
  hyprctl hyprpaper wallpaper ",${GLOBAL_BG}" 2>/dev/null || true
fi
