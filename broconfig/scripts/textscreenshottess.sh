#!/bin/bash
grim -g "$(slurp)" /tmp/screenshot.png

tesseract /tmp/screenshot.png /tmp/ocr-output -l eng && cat /tmp/ocr-output.txt | wl-copy

rm /tmp/screenshot.png /tmp/ocr-output.txt

sleep 1

output=$(wl-paste | head -c 10 )
notify-send "Text extracted" "$output"
