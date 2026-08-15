#!/usr/bin/env bash

# theme-preset.sh - Save & Restore Handpicked Desktop Theme Presets

PRESET_DIR="$HOME/.config/theme-presets"
mkdir -p "$PRESET_DIR"

function save_preset() {
    local NAME="$1"
    if [ -z "$NAME" ]; then
        echo "Usage: theme-preset.sh save <preset_name>"
        exit 1
    fi

    local DEST="$PRESET_DIR/$NAME"
    mkdir -p "$DEST"

    # Save wallpaper path / file
    local WP=""
    if [ -f "$HOME/.config/waypaper/config.ini" ]; then
        WP=$(grep -E "^wallpaper\s*=" "$HOME/.config/waypaper/config.ini" | cut -d'=' -f2 | xargs)
    fi
    if [ -n "$WP" ] && [ -f "$WP" ]; then
        cp "$WP" "$DEST/wallpaper.img" 2>/dev/null || true
        echo "$WP" > "$DEST/wallpaper_path.txt"
    fi

    # Save configs
    [ -f "$HOME/.config/waybar/style.css" ] && cp "$HOME/.config/waybar/style.css" "$DEST/waybar_style.css"
    [ -f "$HOME/.config/swaync/style.css" ] && cp "$HOME/.config/swaync/style.css" "$DEST/swaync_style.css"
    [ -f "$HOME/.config/rofi/config.rasi" ] && cp "$HOME/.config/rofi/config.rasi" "$DEST/rofi_config.rasi"
    [ -f "$HOME/.config/kitty/kitty.conf" ] && cp "$HOME/.config/kitty/kitty.conf" "$DEST/kitty.conf"
    
    # Save current cache wallust palette
    if [ -d "$HOME/.cache/wallust" ]; then
        mkdir -p "$DEST/wallust_cache"
        cp -r "$HOME/.cache/wallust/"* "$DEST/wallust_cache/" 2>/dev/null || true
    fi

    notify-send "Theme Preset Manager" "Handpicked theme '$NAME' saved successfully!"
    echo "Preset '$NAME' saved to $DEST"
}

function load_preset() {
    local NAME="$1"
    if [ -z "$NAME" ]; then
        echo "Usage: theme-preset.sh load <preset_name>"
        exit 1
    fi

    local SRC="$PRESET_DIR/$NAME"
    if [ ! -d "$SRC" ]; then
        notify-send "Theme Preset Manager" "Preset '$NAME' not found!"
        echo "Preset '$NAME' does not exist."
        exit 1
    fi

    # Restore cached colors
    if [ -d "$SRC/wallust_cache" ]; then
        mkdir -p "$HOME/.cache/wallust"
        cp -r "$SRC/wallust_cache/"* "$HOME/.cache/wallust/" 2>/dev/null || true
    fi

    # Restore configs if saved
    [ -f "$SRC/waybar_style.css" ] && cp "$SRC/waybar_style.css" "$HOME/.config/waybar/style.css"
    [ -f "$SRC/swaync_style.css" ] && cp "$SRC/swaync_style.css" "$HOME/.config/swaync/style.css"
    [ -f "$SRC/rofi_config.rasi" ] && cp "$SRC/rofi_config.rasi" "$HOME/.config/rofi/config.rasi"
    [ -f "$SRC/kitty.conf" ] && cp "$SRC/kitty.conf" "$HOME/.config/kitty/kitty.conf"

    # Restore wallpaper
    local WP_PATH=""
    if [ -f "$SRC/wallpaper_path.txt" ]; then
        WP_PATH=$(cat "$SRC/wallpaper_path.txt")
    fi
    if [ ! -f "$WP_PATH" ] && [ -f "$SRC/wallpaper.img" ]; then
        WP_PATH="$SRC/wallpaper.img"
    fi

    if [ -n "$WP_PATH" ] && [ -f "$WP_PATH" ]; then
        if command -v waypaper &>/dev/null; then
            waypaper --wallpaper "$WP_PATH" 2>/dev/null || true
        elif command -v swww &>/dev/null; then
            swww img "$WP_PATH" 2>/dev/null || true
        fi
    fi

    # Reload applications
    pkill -USR2 waybar 2>/dev/null || true
    swaync-client -R 2>/dev/null || true
    swaync-client -rs 2>/dev/null || true
    hyprctl reload 2>/dev/null || true

    notify-send "Theme Preset Manager" "Theme '$NAME' loaded successfully!"
    echo "Preset '$NAME' loaded."
}

function list_presets() {
    if [ ! -d "$PRESET_DIR" ] || [ -z "$(ls -A "$PRESET_DIR")" ]; then
        echo "No presets saved yet."
        return
    fi
    ls -1 "$PRESET_DIR"
}

function rofi_menu() {
    local OPTIONS="➕ Save Current Theme\n$(list_presets)"
    local CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Theme Presets:")

    if [ -z "$CHOICE" ]; then
        exit 0
    fi

    if [ "$CHOICE" = "➕ Save Current Theme" ]; then
        local PRESET_NAME=$(rofi -dmenu -p "Enter Preset Name:")
        if [ -n "$PRESET_NAME" ]; then
            save_preset "$PRESET_NAME"
        fi
    else
        load_preset "$CHOICE"
    fi
}

case "$1" in
    save)
        save_preset "$2"
        ;;
    load)
        load_preset "$2"
        ;;
    list)
        list_presets
        ;;
    rofi)
        rofi_menu
        ;;
    *)
        echo "Usage: theme-preset.sh {save <name>|load <name>|list|rofi}"
        ;;
esac
