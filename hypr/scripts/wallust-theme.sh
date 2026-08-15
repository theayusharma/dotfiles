#!/usr/bin/env bash

# wallust-theme.sh - Apply wallpaper autotheme using Wallust across desktop components

WALLPAPER="$1"
if [ -z "$WALLPAPER" ]; then
    echo "Usage: wallust-theme.sh <path_to_wallpaper>"
    exit 1
fi

WALLUST_BIN=$(which wallust 2>/dev/null || echo "$HOME/.cargo/bin/wallust")

# Keep static fallback background in sync so reboot/hyprpaper never reverts
cp -f "$WALLPAPER" "$HOME/.config/background.jpg" 2>/dev/null || true

# Generate Black & White lockscreen wallpaper for hyprlock
magick "$WALLPAPER" -colorspace Gray "$HOME/.config/hypr/lock_wallpaper_bw.png" 2>/dev/null || true

# Reload hyprpaper with the active wallpaper
pkill -9 hyprpaper 2>/dev/null || true
hyprpaper >/dev/null 2>&1 &

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
