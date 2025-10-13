#!/bin/bash
if [ -f ~/.cache/PowerSavermode ]; then
    hyprctl reload
    rm ~/.cache/PowerSavermode
    notify-send "PowerSaver deactivated" "Animations and blur enabled"
    sleep 0.7
    notify-send "Smooth Catisgoal!" "120hz refreshrate enabled"
else
    hyprctl --batch "
        keyword monitor eDP-1,1920x1080@60.00hz,0x0,1;
        keyword monitor HDMI-A-1,1920x1080@60.00hz,0x-1080,1;
        keyword animations:enabled 0;
		
		keyword decoration:drop_shadow 0;
		keyword decoration:blur:enabled 0;
		keyword general:gaps_in 0;
		keyword general:gaps_out 0;
		keyword general:border_size 0;
		keyword decoration:rounding 0;
		"
    touch ~/.cache/PowerSavermode
    notify-send "PowerSaver activated" "Animations and blur disabled"
    sleep 0.7
    notify-send "Chill Catisgoal!" "60hz refreshrate enabled"
fi
