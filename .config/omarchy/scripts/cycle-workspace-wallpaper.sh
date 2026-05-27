#!/bin/bash
set -euo pipefail

WS=$(hyprctl activeworkspace -j | jq -r '.id')
WALL_DIR="$HOME/.config/omarchy/workspace-wallpapers"
mkdir -p "$WALL_DIR"

THEME_BG_PATH="$HOME/.config/omarchy/current/theme/backgrounds"
USER_BG_PATH="$HOME/.config/omarchy/backgrounds/$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null)"

mapfile -t BGS < <(find -L "$USER_BG_PATH" "$THEME_BG_PATH" -maxdepth 1 -type f 2>/dev/null | sort)
TOTAL=${#BGS[@]}

if (( TOTAL == 0 )); then
  notify-send "Wallpaper" "No backgrounds found for theme" -t 3000
  exit 1
fi

CURRENT_LINK="$WALL_DIR/ws-${WS}"
if [[ -L "$CURRENT_LINK" ]]; then
  CURRENT_IMG=$(readlink "$CURRENT_LINK")
else
  CURRENT_IMG=""
fi

INDEX=-1
for i in "${!BGS[@]}"; do
  if [[ "${BGS[$i]}" == "$CURRENT_IMG" ]]; then
    INDEX=$i
    break
  fi
done

if (( INDEX == -1 )); then
  NEXT="${BGS[0]}"
else
  NEXT="${BGS[$(((INDEX + 1) % TOTAL))]}"
fi

ln -nsf "$NEXT" "$CURRENT_LINK"
REAL_NEXT=$(readlink -f "$NEXT")

~/.config/hypr/scripts/workspace-wallpaper.sh apply

notify-send "Wallpaper" "Workspace $WS: $(basename "$NEXT")" -t 2000
