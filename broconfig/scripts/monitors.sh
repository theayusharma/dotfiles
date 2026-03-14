#!/bin/bash

INTERNAL=$(hyprctl monitors | grep -E '^Monitor' | awk '{print $2}' | grep -E '^eDP-' | head -1)
EXTERNAL=$(hyprctl monitors | grep -E '^Monitor' | awk '{print $2}' | grep -v '^eDP-' | head -1)

if [ -z "$INTERNAL" ]; then
	INTERNAL="eDP-1"
fi

choices=(
	"Internal 120Hz + External 72Hz"
	"Internal 60Hz + External 60Hz"
	"Only External 72Hz"
	"Only External 60Hz"
	"Only Internal 120Hz"
	"Only Internal 60Hz"
)

selected=$(printf "%s\n" "${choices[@]}" | rofi -dmenu -p "Monitor Mode")

[ -z "$selected" ] && exit

case "$selected" in
"Internal 120Hz + External 72Hz")
	if [ -z "$EXTERNAL" ]; then
		notify-send "Error" "No external monitor connected"
		exit 1
	fi
	batch_cmd="keyword monitor $INTERNAL,1920x1080@120,0x0,1; keyword monitor $EXTERNAL,1920x1080@72,0x-1080,1"
	;;
"Internal 60Hz + External 60Hz")
	if [ -z "$EXTERNAL" ]; then
		notify-send "Error" "No external monitor connected"
		exit 1
	fi
	batch_cmd="keyword monitor $INTERNAL,1920x1080@60,0x0,1; keyword monitor $EXTERNAL,1920x1080@60,0x-1080,1"
	;;
"Only External 72Hz")
	if [ -z "$EXTERNAL" ]; then
		notify-send "Error" "No external monitor connected"
		exit 1
	fi
	batch_cmd="keyword monitor $INTERNAL,disable; keyword monitor $EXTERNAL,1920x1080@72,0x0,1"
	;;
"Only External 60Hz")
	if [ -z "$EXTERNAL" ]; then
		notify-send "Error" "No external monitor connected"
		exit 1
	fi
	batch_cmd="keyword monitor $INTERNAL,disable; keyword monitor $EXTERNAL,1920x1080@60,0x0,1"
	;;
"Only Internal 120Hz")
	batch_cmd="keyword monitor $EXTERNAL,disable; keyword monitor $INTERNAL,1920x1080@120,0x0,1"
	;;
"Only Internal 60Hz")
	batch_cmd="keyword monitor $EXTERNAL,disable; keyword monitor $INTERNAL,1920x1080@60,0x0,1"
	;;
esac

hyprctl --batch "$batch_cmd"

notify-send "Monitor setup applied" "$selected"

sleep 1
res=$(hyprctl monitors | awk '
/Monitor/ {printf "\n%s: ", $2}
/^[[:space:]]+[0-9]+x[0-9]+@[0-9]+/ {
    sub(/\.[0-9]+$/, "", $1)
    print $1
}')
notify-send "Current Resolutions" "$res"
