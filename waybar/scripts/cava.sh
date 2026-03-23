#!/bin/sh

if [ -f "/tmp/waybar-stealth-mode" ]; then
    echo ""
    exit 0
fi

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

i=0
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i+1))
done

config_file="/tmp/waybar_cava_config_$(id -u)"
echo "
[general]
bars = 8

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
" > $config_file

cleanup() {
    pkill -P $$ cava 2>/dev/null
    exit
}
trap cleanup EXIT

while true; do
    status=$(playerctl status 2>/dev/null)
    
    if [ "$status" = "Playing" ]; then
        cava -p "$config_file" 2>/dev/null | while read -r line; do
            if [ "$(playerctl status 2>/dev/null)" != "Playing" ]; then
                pkill -P $$ cava 2>/dev/null
                break
            fi
            echo "$line" | sed "$dict"
        done
    elif [ "$status" = "Paused" ]; then
        echo ""
        sleep 1
    else
        echo ""
        sleep 1
    fi
done
