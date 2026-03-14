#!/bin/bash

INTERNAL_MONITOR=$(hyprctl monitors | grep -E '^Monitor' | awk '{print $2}' | grep -E '^eDP-' | head -1)
EXTERNAL_MONITOR=$(hyprctl monitors | grep -E '^Monitor' | awk '{print $2}' | grep -v '^eDP-' | head -1)

if [ -z "$EXTERNAL_MONITOR" ]; then
	notify-send "onlyExternalMonitor" "No external monitor detected"
	exit 0
fi

if [ -z "$INTERNAL_MONITOR" ]; then
	INTERNAL_MONITOR="eDP-1"
fi

if [ -f ~/.cache/onlyExternalMonitor ]; then
	hyprctl reload
	rm ~/.cache/onlyExternalMonitor
	notify-send "onlyExternalMonitor mode" "disabled"
	resolution=$(hyprctl monitors | grep -E 'Monitor|^[[:space:]]+[0-9]+x[0-9]+@[0-9]+' | awk '
/Monitor/ {printf "\n%s: ", $2}
/^[[:space:]]+[0-9]+x[0-9]+@[0-9]+/ {
    sub(/\.[0-9]+$/, "", $1)  # Remove everything after the decimal
    print $1
}')

	notify-send "resolution" "${resolution}"
else
	hyprctl --batch "\
        keyword monitor $INTERNAL_MONITOR, disable;\
        keyword monitor $EXTERNAL_MONITOR,preferred,auto,1"
	touch ~/.cache/onlyExternalMonitor
	notify-send "onlyExternalMonitor mode" "enabled"
	sleep 1
	resolution=$(hyprctl monitors | grep -E 'Monitor|^[[:space:]]+[0-9]+x[0-9]+@[0-9]+' | awk '
/Monitor/ {printf "\n%s: ", $2}
/^[[:space:]]+[0-9]+x[0-9]+@[0-9]+/ {
    sub(/\.[0-9]+$/, "", $1)  # Remove everything after the decimal
    print $1
}')

	notify-send "resolution" "${resolution}"
fi
