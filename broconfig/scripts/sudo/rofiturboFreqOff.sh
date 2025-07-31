#!/bin/bash

declare -A MODES=(
    ["Performance"]="performance"
    ["Balance Performance"]="balance_performance"
    ["Balance Power"]="balance_power"
    ["Power Save"]="power"
)

CPU_SCRIPT="./cpu_mode.sh"

if [[ ! -f "$CPU_SCRIPT" ]]; then
    notify-send "CPU Mode" "Script not found"
    exit 1
fi

MENU_OPTIONS=""
for description in "${!MODES[@]}"; do
    MENU_OPTIONS="$MENU_OPTIONS$description\n"
done

SELECTED=$(echo -e "$MENU_OPTIONS" | rofi -dmenu -p "CPU Mode" -theme ~/.config/rofi/config-turboFreq.rasi)

if [[ -z "$SELECTED" ]]; then
    exit 0
fi

MODE_VALUE="${MODES[$SELECTED]}"

if [[ -n "$MODE_VALUE" ]]; then
    "$CPU_SCRIPT" "$MODE_VALUE"
fi
