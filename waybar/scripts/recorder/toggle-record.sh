#!/bin/sh

RECORD_PID_FILE="/tmp/wf-recording.pid"
RECORD_START_FILE="/tmp/wf-recording.start"
RECORD_PAUSE_FILE="/tmp/wf-recording.paused"
RECORD_TOTAL_TIME_FILE="/tmp/wf-recording.total"
# AUDIO_SOURCE="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink.monitor"
AUDIO_SOURCE="$(pactl get-default-sink 2>/dev/null)"
AUDIO_SOURCE="${AUDIO_SOURCE}.monitor"

stop_recording() {
	PID=$(cat "$RECORD_PID_FILE" 2>/dev/null)
	if [ -z "$PID" ]; then
		PID=$(pgrep -x "wf-recorder")
	fi

	if [ -n "$PID" ]; then
		# IMPORTANT: Resume if paused so it can process the INT signal
		kill -CONT "$PID" 2>/dev/null
		sleep 0.1
		kill -INT "$PID" 2>/dev/null

		# Force kill if it doesn't stop after 1 second
		(sleep 1 && kill -9 "$PID" 2>/dev/null) &

		notify-send "Recording" "Screen recording saved to ~/Videos/Recordings" -i video-x-generic
	fi
	rm -f "$RECORD_PID_FILE" "$RECORD_START_FILE" "$RECORD_PAUSE_FILE" "$RECORD_TOTAL_TIME_FILE"
}

# 1. Check if we are currently recording (alive or paused)
if pgrep -x "wf-recorder" >/dev/null; then
	stop_recording
	exit 0
fi

# 2. Otherwise, start recording
geometry="$(slurp -d)"
if [ -n "$geometry" ]; then
	mkdir -p ~/Videos/Recordings
	FILENAME="screen-record-$(date +%Y-%m-%d-%H-%M-%S).mp4"
	wf-recorder \
		-f ~/Videos/Recordings/"$FILENAME" \
		-g "$geometry" \
		--audio \
		--audio-source="$AUDIO_SOURCE" &
	echo $! >"$RECORD_PID_FILE"
	date +%s >"$RECORD_START_FILE"
	echo "0" >"$RECORD_TOTAL_TIME_FILE"
fi
