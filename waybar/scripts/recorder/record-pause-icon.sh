#!/bin/sh
RECORD_PID_FILE="/tmp/wf-recording.pid"
RECORD_PAUSE_FILE="/tmp/wf-recording.paused"

if [ -f "$RECORD_PID_FILE" ] && kill -0 "$(cat "$RECORD_PID_FILE")" 2>/dev/null; then
    if [ -f "$RECORD_PAUSE_FILE" ]; then
        echo "󰐊" # Play/Resume icon
    else
        echo "󰏤" # Pause icon
    fi
else
    echo ""
fi
