#!/bin/bash
cp ~/.config/omarchy/current/theme/waybar.css ~/.config/swaync/colors.css
swaync-client -rs >/dev/null 2>&1
