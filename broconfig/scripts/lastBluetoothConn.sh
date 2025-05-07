#!/bin/bash

LATEST_DEVICE=$(bluetoothctl devices | tail -n 1 | awk '{print $2}')
LATEST_DEVICE_NAME=$(bluetoothctl info "$LATEST_DEVICE" | grep "Name" | cut -d ' ' -f2-)

if [ -z "$LATEST_DEVICE" ]; then
    echo "No Bluetooth devices found."
    exit 1
fi

if bluetoothctl connect "$LATEST_DEVICE"; then
    sleep 1
    BATTERY_HEX=$(bluetoothctl info "$LATEST_DEVICE" | grep "Battery Percentage" | awk '{print $3}')
    BATTERY_DEC=$((16#${BATTERY_HEX#0x}))
    notify-send "Connected to $LATEST_DEVICE_NAME" "Battery level: ${BATTERY_DEC:-Unknown}%"
fi
