#!/bin/bash
#  ____                               _           _
# / ___|  ___ _ __ ___  ___ _ __  ___| |__   ___ | |_
# \___ \ / __| '__/ _ \/ _ \ '_ \/ __| '_ \ / _ \| __|
#  ___) | (__| | |  __/  __/ | | \__ \ | | | (_) | |_
# |____/ \___|_|  \___|\___|_| |_|___/_| |_|\___/ \__|
#
# Based on https://github.com/hyprwm/contrib/blob/main/grimblast/screenshot.sh

# Config
prompt='Screenshot'
mesg="Saved to ~/Pictures/Screenshots"
screenshot_folder="$HOME/Pictures/Screenshots"
NAME="screenshot_$(date +%Y%m%d_%H%M%S).png"

# Options
option_1="Immediate"
option_2="Delayed"
option_capture_1="Capture Everything"
option_capture_2="Capture Active Display"
option_capture_3="Capture Selection"
option_time_1="5s"
option_time_2="10s"
option_time_3="20s"
option_time_4="30s"
option_time_5="60s"

save='Save'
copy_save='Copy & Save'

# UI
rofi_cmd() {
    rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 2 -width 30 -p "Take screenshot"
}

run_rofi() {
    echo -e "$option_1\n$option_2" | rofi_cmd
}

timer_cmd() {
    rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 5 -width 30 -p "Choose timer"
}

timer_exit() {
    echo -e "$option_time_1\n$option_time_2\n$option_time_3\n$option_time_4\n$option_time_5" | timer_cmd
}

type_screenshot_cmd() {
    rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 3 -width 30 -p "Type of screenshot"
}

type_screenshot_exit() {
    echo -e "$option_capture_1\n$option_capture_2\n$option_capture_3" | type_screenshot_cmd
}

copy_save_cmd() {
    rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 2 -width 30 -p "How to save"
}

copy_save_exit() {
    echo -e "$save\n$copy_save" | copy_save_cmd
}

# Selection Handlers
timer_run() {
    selected_timer="$(timer_exit)"
    case "$selected_timer" in
        "$option_time_1") countdown=5 ;;
        "$option_time_2") countdown=10 ;;
        "$option_time_3") countdown=20 ;;
        "$option_time_4") countdown=30 ;;
        "$option_time_5") countdown=60 ;;
        *) exit ;;
    esac
    "$1"
}

type_screenshot_run() {
    selected_type_screenshot="$(type_screenshot_exit)"
    case "$selected_type_screenshot" in
        "$option_capture_1") option_type_screenshot=screen ;;
        "$option_capture_2") option_type_screenshot=output ;;
        "$option_capture_3") option_type_screenshot=area ;;
        *) exit ;;
    esac
    "$1"
}

copy_save_run() {
    selected_chosen="$(copy_save_exit)"
    case "$selected_chosen" in
        "$save") option_chosen=save ;;
        "$copy_save") option_chosen=copysave ;;
        *) exit ;;
    esac
    "$1"
}

# Timed countdown
timer() {
    if [[ $countdown -gt 10 ]]; then
        notify-send -t 1000 "Taking screenshot in ${countdown} seconds"
        sleep $((countdown - 10))
        countdown=10
    fi
    while [[ $countdown -gt 0 ]]; do
        notify-send -t 1000 "Taking screenshot in ${countdown} seconds"
        countdown=$((countdown - 1))
        sleep 1
    done
}

# Actions
send_notification_with_preview() {
    notify-send -i "$1" "Screenshot saved" "$mesg at $1" -u normal
}

copy_to_clipboard() {
    if [[ -f "$1" ]]; then
        wl-copy --type image/png < "$1"
        if wl-paste --type image/png >/dev/null 2>&1; then
            notify-send "Clipboard" "Screenshot copied to clipboard"
        else
            notify-send -u critical "Error" "Failed to verify clipboard content"
            exit 1
        fi
    else
        notify-send -u critical "Error" "Failed to copy screenshot: File $1 not found"
        exit 1
    fi
}

handle_post_actions() {
    local file="$1"
    case "$option_chosen" in
        save)
            send_notification_with_preview "$file"
            ;;
        copysave)
            copy_to_clipboard "$file"
            send_notification_with_preview "$file"
            ;;
    esac
}

takescreenshot() {
    local output_file="$screenshot_folder/$NAME"
    mkdir -p "$screenshot_folder" || {
        notify-send -u critical "Error" "Failed to create directory $screenshot_folder"
        exit 1
    }

    case "$option_type_screenshot" in
        screen)
			sleep 0.5 # adding this as it was including the rofi in screenshot too
            grim "$output_file"
            ;;
        output)
			sleep 0.5 # adding this as it was including the rofi in screenshot too
            grim -o "$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')" "$output_file"
            ;;
        area)
            grim -g "$(slurp -d)" "$output_file" || {
                notify-send -u critical "Error" "Failed to capture area screenshot"
                exit 1
            }
            ;;
    esac

    if [[ -f "$output_file" ]]; then
        handle_post_actions "$output_file"
    else
        notify-send -u critical "Error" "Screenshot file $output_file not created"
        exit 1
    fi
}

takescreenshot_timer() {
    timer
    takescreenshot
}

run_cmd() {
    if [[ "$1" == '--opt1' ]]; then
        type_screenshot_run
        copy_save_run takescreenshot
    elif [[ "$1" == '--opt2' ]]; then
        timer_run type_screenshot_run
        copy_save_run takescreenshot_timer
    fi
}

# Entry
chosen="$(run_rofi)"
case "$chosen" in
    "$option_1")
        run_cmd --opt1
        ;;
    "$option_2")
        run_cmd --opt2
        ;;
esac
