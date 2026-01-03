#!/bin/bash

# make sure bluetooth is on
bluetoothctl power on >/dev/null 2>&1
sleep 0.5

# get paired devices, most recent last -> reverse with tac so we try latest first
mapfile -t devices < <(bluetoothctl paired-devices | awk '{print $2}' | tac)

for dev in "${devices[@]}"; do
    # try to connect
    if bluetoothctl connect "$dev" >/dev/null 2>&1; then
        sleep 1

        # get device name
        name=$(bluetoothctl info "$dev" | awk -F': ' '/Name/ {print $2}')

        # get battery (hex) if available
        batt_hex=$(bluetoothctl info "$dev" | awk '/Battery Percentage/ {print $3}')
        if [[ $batt_hex == 0x* ]]; then
            batt_dec=$((16#${batt_hex#0x}))
        fi

        notify-send "Connected to ${name:-$dev}" "Battery level: ${batt_dec:-Unknown}%"
        exit 0
    fi
done

notify-send "Bluetooth" "Could not connect to any paired device"

