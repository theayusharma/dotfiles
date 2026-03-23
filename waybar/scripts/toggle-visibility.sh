#!/bin/bash

MODULE="$1"
STATE_FILE="/tmp/waybar-${MODULE}-hidden"

if [ -z "$MODULE" ]; then
	echo "Usage: $0 <module_name>"
	exit 1
fi

if [ -f "$STATE_FILE" ]; then
	rm "$STATE_FILE"
else
	touch "$STATE_FILE"
fi

waybarctl reload 2>/dev/null || pkill -SIGRTMIN+8 waybar 2>/dev/null
