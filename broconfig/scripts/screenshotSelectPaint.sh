#!/bin/sh

tmpfile="/tmp/snap.png"

grim -g "$(slurp)" "$tmpfile" && \
# wl-copy -t image/png < "$tmpfile" && \
swappy --file "$tmpfile"
