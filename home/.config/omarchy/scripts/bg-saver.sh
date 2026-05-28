#!/bin/bash
set -euo pipefail

TARGET="$HOME/.config/omarchy/current/background"

save_bg() {
    if [[ -L "$TARGET" ]]; then
        THEME_NAME=$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null || true)
        if [[ -n "$THEME_NAME" ]]; then
            BG=$(readlink -f "$TARGET" 2>/dev/null || true)
            if [[ -n "$BG" && -f "$BG" ]]; then
                mkdir -p "$HOME/.config/omarchy/state"
                echo "$BG" > "$HOME/.config/omarchy/state/bg_${THEME_NAME}"
            fi
        fi
    fi
}

LAST_MTIME=0
while true; do
    if [[ -L "$TARGET" ]]; then
        CUR_MTIME=$(stat -c %Y "$TARGET" 2>/dev/null || echo 0)
        if [[ "$CUR_MTIME" != "$LAST_MTIME" ]]; then
            sleep 0.5
            save_bg
            LAST_MTIME=$CUR_MTIME
        fi
    fi
    sleep 2
done
