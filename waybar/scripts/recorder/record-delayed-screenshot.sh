#!/bin/sh

NOTIF_ID=9999

# 1. Select region
GEOM=$(slurp)
if [ -z "$GEOM" ]; then
	exit 0
fi

# 2. Show one notification at start
notify-send -r $NOTIF_ID "Screenshot" "Taking screenshot in 5 seconds..." -i camera-photo

# 3. Countdown without notifications
sleep 5

# 4. Capture and show result
if grim -g "$GEOM" - | wl-copy -t image/png; then
	notify-send -r $NOTIF_ID 'Screenshot' 'Captured to clipboard' -i camera-photo
else
	notify-send -r $NOTIF_ID 'Screenshot' 'Failed to capture' -i camera-photo
fi
