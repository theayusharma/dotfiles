#!/bin/sh

RECORD_PID_FILE="/tmp/wf-recording.pid"
RECORD_START_FILE="/tmp/wf-recording.start"
RECORD_PAUSE_FILE="/tmp/wf-recording.paused"

if [ -f "$RECORD_PID_FILE" ] && kill -0 "$(cat "$RECORD_PID_FILE")" 2>/dev/null; then
    START_TIME=$(cat "$RECORD_START_FILE")
    NOW=$(date +%s)
    DURATION_SEC=$((NOW - START_TIME))

    MIN=$((DURATION_SEC / 60))
    SEC=$((DURATION_SEC % 60))
    TIME_STR=$(printf "%02d:%02d" $MIN $SEC)

    if [ -f "$RECORD_PAUSE_FILE" ]; then
        echo "{\"text\": \"󰏤 $TIME_STR\", \"tooltip\": \"Paused - Click to Resume\", \"class\": \"paused\"}"
    else
        echo "{\"text\": \"  $TIME_STR\", \"tooltip\": \"Recording - Right Click to Pause\", \"class\": \"recording\"}"
    fi
else
    echo "{\"text\": \"󰻂\", \"tooltip\": \"Not recording\", \"class\": \"idle\"}"
fi
