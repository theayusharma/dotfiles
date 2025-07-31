#!/bin/bash
bluetoothctl power on
sleep 0.5
LATEST_DEVICE="2C:BE:EB:DA:79:26"
LATEST_DEVICE_NAME=$(bluetoothctl info "$LATEST_DEVICE" | grep "Name" | cut -d ' ' -f2-)

if bluetoothctl connect "$LATEST_DEVICE"; then
    sleep 1
    BATTERY_HEX=$(bluetoothctl info "$LATEST_DEVICE" | grep "Battery Percentage" | awk '{print $3}')
    BATTERY_DEC=$((16#${BATTERY_HEX#0x}))
    notify-send "Connected to $LATEST_DEVICE_NAME" "Battery level: ${BATTERY_DEC:-Unknown}%"
fi
