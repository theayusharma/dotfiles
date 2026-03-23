#!/bin/sh

RECORD_PID_FILE="/tmp/wf-recording.pid"
RECORD_START_FILE="/tmp/wf-recording.start"
RECORD_PAUSE_FILE="/tmp/wf-recording.paused"
RECORD_TOTAL_TIME_FILE="/tmp/wf-recording.total"

if pgrep -x "wf-recorder" > /dev/null; then
    TOTAL=$(cat "$RECORD_TOTAL_TIME_FILE" 2>/dev/null || echo 0)
    
    if [ -f "$RECORD_PAUSE_FILE" ]; then
        # If paused, just show the total accumulated time
        DURATION_SEC=$TOTAL
    else
        # If running, show total + time since last resume
        START_TIME=$(cat "$RECORD_START_FILE" 2>/dev/null || date +%s)
        NOW=$(date +%s)
        DURATION_SEC=$((TOTAL + NOW - START_TIME))
    fi
    
    printf "%02d:%02d" $((DURATION_SEC / 60)) $((DURATION_SEC % 60))
else
    echo ""
fi
