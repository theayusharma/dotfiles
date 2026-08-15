#!/usr/bin/env bash

tmp_dir="/tmp/cliphist"
rm -rf "$tmp_dir"
mkdir -p "$tmp_dir"

case "$1" in
d)
    cliphist list | rofi -dmenu -p "" -replace -config ~/.config/rofi/config-cliphist.rasi | cliphist delete
    exit
    ;;
w)
    if [[ "$(echo -e "Clear\nCancel" | rofi -dmenu -config ~/.config/rofi/config-short.rasi)" == "Clear" ]]; then
        cliphist wipe
    fi
    exit
    ;;
esac

# if entry passed directly (used internally)
if [[ -n "$1" ]]; then
    cliphist decode <<<"$1" | wl-copy
    exit
fi

# gawk script for image previews
read -r -d '' prog <<EOF
/^[0-9]+\s<meta http-equiv=/ { next }
match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
    system("echo " grp[1] " | cliphist decode > $tmp_dir/" grp[1] "." grp[3])
    print \$0 "\0icon\x1f$tmp_dir/" grp[1] "." grp[3]
    next
}
1
EOF
selection=$(cliphist list | gawk "$prog" | rofi -dmenu -p "" -replace -display-columns 2 -show-icons -config ~/.config/rofi/config-cliphist.rasi)
[[ -n "$selection" ]] && cliphist decode <<<"$selection" | wl-copy

