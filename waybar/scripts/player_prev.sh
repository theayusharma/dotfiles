#!/bin/sh
# Script for Previous button: only shows when not playing
icon="󰒮"
playerctl status --follow 2>/dev/null | while read -r status; do
    if [ "$status" != "Playing" ] && [ -n "$status" ]; then
        echo "$icon"
    else
        echo ""
    fi
done
