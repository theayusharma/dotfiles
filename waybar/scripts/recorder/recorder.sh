#!/bin/sh

RECORD_PID_FILE="/tmp/wf-recording.pid"
RECORD_START_FILE="/tmp/wf-recording.start"
RECORD_PAUSE_FILE="/tmp/wf-recording.paused"
RECORD_TOTAL_TIME_FILE="/tmp/wf-recording.total"

# Check if wf-recorder is running
if pgrep -x "wf-recorder" >/dev/null 2>&1; then
	TOTAL=$(cat "$RECORD_TOTAL_TIME_FILE" 2>/dev/null || echo 0)

	if [ -f "$RECORD_PAUSE_FILE" ]; then
		DURATION_SEC=$TOTAL
		CLASS="paused"
	else
		START_TIME=$(cat "$RECORD_START_FILE" 2>/dev/null || date +%s)
		NOW=$(date +%s)
		DURATION_SEC=$((TOTAL + NOW - START_TIME))
		CLASS="recording"
	fi

	TIMER=$(printf "%02d:%02d" $((DURATION_SEC / 60)) $((DURATION_SEC % 60)))
	echo "{\"text\": \" $TIMER\", \"class\": \"$CLASS\", \"tooltip\": \"$CLASS\"}"
fi
