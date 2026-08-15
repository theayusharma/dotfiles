#!/bin/sh

RECORD_START_FILE="/tmp/wf-recording.start"
RECORD_PAUSE_FILE="/tmp/wf-recording.paused"
RECORD_TOTAL_TIME_FILE="/tmp/wf-recording.total"

# if no start file → not recording → output nothing
[ -f "$RECORD_START_FILE" ] || exit 0

TOTAL=$(cat "$RECORD_TOTAL_TIME_FILE" 2>/dev/null || echo 0)

if [ -f "$RECORD_PAUSE_FILE" ]; then
    DURATION_SEC=$TOTAL
    CLASS="paused"
else
    START_TIME=$(cat "$RECORD_START_FILE")
    NOW=$(date +%s)
    DURATION_SEC=$((TOTAL + NOW - START_TIME))
    CLASS="recording"
fi

printf '{"text": " %02d:%02d", "class": "%s", "tooltip": "%s"}\n' \
    $((DURATION_SEC / 60)) $((DURATION_SEC % 60)) "$CLASS" "$CLASS"
