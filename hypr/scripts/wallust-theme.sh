#!/usr/bin/env bash

# wallust-theme.sh - Apply wallpaper autotheme using Wallust across desktop components

WALLPAPER="$1"
if [ -z "$WALLPAPER" ]; then
    echo "Usage: wallust-theme.sh <path_to_wallpaper>"
    exit 1
fi

WALLUST_BIN=$(which wallust 2>/dev/null || echo "$HOME/.cargo/bin/wallust")

# Ensure swww-daemon is running and update active wallpaper smoothly
if command -v swww &>/dev/null; then
    if ! pgrep -x swww-daemon >/dev/null; then
        swww-daemon >/dev/null 2>&1 &
        sleep 0.5
    fi
    swww img "$WALLPAPER" 2>/dev/null || true
fi

# Run Wallust to extract color palette and generate template files
if [ -x "$WALLUST_BIN" ]; then
    "$WALLUST_BIN" run "$WALLPAPER"
fi

# Reload Waybar CSS
pkill -USR2 waybar 2>/dev/null || true

# Reload SwayNC Notification Center
swaync-client -R 2>/dev/null || true
swaync-client -rs 2>/dev/null || true

# Reload Hyprland borders/colors
hyprctl reload 2>/dev/null || true

# Update Kitty terminal colors on-the-fly
if command -v kitty &>/dev/null; then
    kitty @ set-colors -a "$HOME/.cache/wallust/colors-kitty.conf" 2>/dev/null || true
fi
