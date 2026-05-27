#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-image>"
    exit 1
fi

WP=$(realpath "$1")
WS=$(hyprctl activeworkspace -j | jq -r '.id')
WALL_DIR="$HOME/.config/omarchy/workspace-wallpapers"
mkdir -p "$WALL_DIR"

# Save the assignment using a symlink
ln -nsf "$WP" "$WALL_DIR/ws-${WS}"

# Save per-theme backup
THEME=$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null || echo "default")
THEME_WALL_DIR="$HOME/.config/omarchy/workspace-wallpapers-${THEME}"
mkdir -p "$THEME_WALL_DIR"
ln -nsf "$WP" "$THEME_WALL_DIR/ws-${WS}"

# Update hyprpaper configuration to preload the new image and apply it
~/.config/hypr/scripts/workspace-wallpaper.sh apply
