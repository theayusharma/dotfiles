#!/bin/bash
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
        keyword monitor eDP-1, disable;\
        keyword monitor HDMI-A-1,preferred,auto,1"
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
