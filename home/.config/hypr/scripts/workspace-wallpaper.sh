#!/bin/bash
# Re-written to strictly use hyprpaper natively

WALL_DIR="$HOME/.config/omarchy/workspace-wallpapers"

# Load theme workspace wallpapers if they exist
evaluate_vars() {
    THEME=$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null || echo "default")
    THEME_WALL_DIR="$HOME/.config/omarchy/workspace-wallpapers-${THEME}"
    if [ -d "$THEME_WALL_DIR" ] && [ "$(ls -A "$THEME_WALL_DIR" 2>/dev/null)" ]; then
        WALL_DIR="$THEME_WALL_DIR"
    else
        shopt -s nullglob
        THEME_BGS=()
        for f in "$HOME/.config/omarchy/current/theme/backgrounds/"*; do
            if [ -f "$f" ]; then
                THEME_BGS+=("$f")
            fi
        done
        shopt -u nullglob
        if [ ${#THEME_BGS[@]} -gt 0 ]; then
            mkdir -p "$THEME_WALL_DIR"
            num_bgs=${#THEME_BGS[@]}
            for i in {1..10}; do
                bg_idx=$(( (i - 1) % num_bgs ))
                ln -sf "${THEME_BGS[$bg_idx]}" "$THEME_WALL_DIR/ws-$i"
            done
            WALL_DIR="$THEME_WALL_DIR"
        fi
    fi

    GLOBAL_BG=$(readlink -f "$HOME/.config/omarchy/current/background" 2>/dev/null || true)

    if [ -e "$WALL_DIR/ws-1" ]; then
        ln -sf "$(readlink -f "$WALL_DIR/ws-1")" "$HOME/.config/omarchy/current/lockscreen-background"
    elif [ -n "$GLOBAL_BG" ]; then
        ln -sf "$GLOBAL_BG" "$HOME/.config/omarchy/current/lockscreen-background"
    fi
}

evaluate_vars

CONF="/tmp/hyprpaper-dynamic.conf"

setup_hyprpaper() {
    # Generate dynamic hyprpaper config to preload images
    echo "ipc = on" > "$CONF"
    echo "splash = false" >> "$CONF"

    if [[ -n "$GLOBAL_BG" && -f "$GLOBAL_BG" ]]; then
        echo "preload = $GLOBAL_BG" >> "$CONF"
        echo "wallpaper = ,$GLOBAL_BG" >> "$CONF"
    fi

    for f in "$WALL_DIR"/ws-*; do
        [[ -L "$f" || -f "$f" ]] || continue
        wp=$(readlink -f "$f")
        if [[ -n "$wp" && -f "$wp" ]]; then
            echo "preload = $wp" >> "$CONF"
        fi
    done

    # Restart hyprpaper with the dynamically generated config
    killall hyprpaper 2>/dev/null
    sleep 0.5
    setsid uwsm-app -- hyprpaper -c "$CONF" >/dev/null 2>&1 &
    sleep 1
}

# Function to apply wallpaper based on active workspace per monitor
apply_all_visible() {
    evaluate_vars
    hyprctl monitors -j | jq -r '.[] | "\(.name) \(.activeWorkspace.id)"' | while read -r mon ws; do
        wp_link="$WALL_DIR/ws-${ws}"
        if [ -L "$wp_link" ] || [ -f "$wp_link" ]; then
            wp=$(readlink -f "$wp_link")
            if [ -n "$wp" ]; then
                hyprctl hyprpaper wallpaper "$mon,$wp" 2>/dev/null
            fi
        elif [[ -n "$GLOBAL_BG" && -f "$GLOBAL_BG" ]]; then
            hyprctl hyprpaper wallpaper "$mon,$GLOBAL_BG" 2>/dev/null
        fi
    done
}

if [ "${1:-}" == "apply" ]; then
    setup_hyprpaper
    apply_all_visible
    exit 0
fi

# Apply immediately and start listening
setup_hyprpaper
apply_all_visible

# Listen for workspace changes and apply
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    case "$line" in
        "workspacev2>>"*|"workspace>>"*|"focusedmon>>"*|"moveworkspacev2>>"*)
            apply_all_visible
            ;;
    esac
done
