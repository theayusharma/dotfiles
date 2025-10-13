#!/bin/bash
#   ____                                          _      
#  / ___| __ _ _ __ ___   ___ _ __ ___   ___   __| | ___ 
# | |  _ / _` | '_ ` _ \ / _ \ '_ ` _ \ / _ \ / _` |/ _ \
# | |_| | (_| | | | | | |  __/ | | | | | (_) | (_| |  __/
#  \____|\__,_|_| |_| |_|\___|_| |_| |_|\___/ \__,_|\___|
#
#

#!/bin/bash

FAST=~/.config/broconfig/moodFast.conf
SLOW=~/.config/broconfig/moodChill.conf
CURRENT=~/.config/broconfig/moodFast.conf

if cmp -s "$FAST" "$CURRENT"; then
    cp "$SLOW" "$CURRENT"
    notify-send "Hyprland" "Switched to slow animations"
else
    cp "$FAST" "$CURRENT"
    notify-send "Hyprland" "Switched to fast animations"
fi

hyprctl reload
