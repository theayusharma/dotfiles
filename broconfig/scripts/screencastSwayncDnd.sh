#!/bin/sh

socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -U - UNIX-CONNECT:"$socket" | while read -r line; do
    case "$line" in
    screencast\>\>1,*)
        swaync-client --inhibitor-add "xdg-desktop-portal-hyprland"
        ;;
    screencast\>\>0,*)
        swaync-client --inhibitor-remove "xdg-desktop-portal-hyprland"
        ;;
    esac
done
