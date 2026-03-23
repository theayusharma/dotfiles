#!/bin/sh

RECORD_PID_FILE="/tmp/wf-recording.pid"
RECORD_PAUSE_FILE="/tmp/wf-recording.paused"
RECORD_TOTAL_TIME_FILE="/tmp/wf-recording.total"

if [ -f "$RECORD_PID_FILE" ]; then
	PID=$(cat "$RECORD_PID_FILE")
	if kill -0 "$PID" 2>/dev/null; then
		if [ -f "$RECORD_PAUSE_FILE" ]; then
			# RESUMING
			kill -CONT "$PID"
			rm "$RECORD_PAUSE_FILE"
			date +%s >"/tmp/wf-recording.start"
		else
			# PAUSING
			kill -STOP "$PID"
			touch "$RECORD_PAUSE_FILE"

			START_TIME=$(cat "/tmp/wf-recording.start" 2>/dev/null || date +%s)
			NOW=$(date +%s)
			DIFF=$((NOW - START_TIME))

			OLD_TOTAL=$(cat "$RECORD_TOTAL_TIME_FILE" 2>/dev/null || echo 0)
			echo "$((OLD_TOTAL + DIFF))" >"$RECORD_TOTAL_TIME_FILE"
		fi
	fi
fi
