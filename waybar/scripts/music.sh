#!/bin/sh

VISIBILITY_FILE="/tmp/waybar-stealth-mode"
if [ -f "$VISIBILITY_FILE" ]; then
	echo ""
	exit 0
fi

info=$(playerctl metadata --format '{{status}}|{{artist}}|{{title}}' 2>/dev/null)

if [ -z "$info" ]; then
	echo ""
	exit 0
fi

status=$(echo "$info" | cut -d'|' -f1)
artist=$(echo "$info" | cut -d'|' -f2)
title=$(echo "$info" | cut -d'|' -f3)

if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
	clean_text() {
		echo "$1" | sed -E 's/\.(mp3|wav|flac|m4a|ogg|wma|aac|alac|opus)$//I' |
			sed -E 's/[._ -]+(mp3|wav|flac|m4a|ogg|wma|aac|alac|opus)$//I' |
			sed -E 's/[[:space:]](mp3|wav|flac|m4a|ogg|wma|aac|alac|opus)$//I' |
			sed -E 's/^(mp3|wav|flac|m4a|ogg|wma|aac|alac|opus)$//I' |
			sed -E 's/ - YouTube$//I' |
			sed -E 's/^[._ -]+//; s/[._ -]+$//'
	}

	artist=$(clean_text "$artist")
	title=$(clean_text "$title")

	if [ -n "$artist" ] && [ "$artist" != "Unknown Artist" ] && [ -n "$title" ]; then
		echo "$artist - $title"
	elif [ -n "$title" ]; then
		echo "$title"
	elif [ -n "$artist" ] && [ "$artist" != "Unknown Artist" ]; then
		echo "$artist"
	else
		echo "Playing..."
	fi
else
	echo ""
fi
