#!/bin/sh
# Helper script for context-aware left click
if pgrep -x "wf-recorder" >/dev/null; then
	# If recording, Left Click = STOP
	~/.config/waybar/scripts/recorder/toggle-record.sh
else
	# If idle, Left Click = SCREENSHOT
	grim -g "$(slurp)" - | wl-copy -t image/png && notify-send 'Screenshot' 'Copied to Clipboard' -i camera-photo
fi
