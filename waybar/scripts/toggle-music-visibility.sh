#!/bin/sh
VISIBILITY_FILE="/tmp/waybar-stealth-mode"

if [ -f "$VISIBILITY_FILE" ]; then
	rm "$VISIBILITY_FILE"
else
	touch "$VISIBILITY_FILE"
fi
