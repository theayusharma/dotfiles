#!/bin/bash

rfkill unblock bluetooth 2>/dev/null

bluetoothctl power on >/dev/null 2>&1

for i in {1..20}; do
	bluetoothctl show | grep -q "Powered: yes" && break
	sleep 0.3
done

bluetoothctl show | grep -q "Powered: yes" || exit 0

mapfile -t devices < <(bluetoothctl devices Paired | awk '{print $2}')

for dev in "${devices[@]}"; do
	bluetoothctl trust "$dev" >/dev/null 2>&1

	if bluetoothctl connect "$dev" >/dev/null 2>&1; then
		sleep 1
		name=$(bluetoothctl info "$dev" | awk -F': ' '/Name/ {print $2}')
		batt=$(bluetoothctl info "$dev" | awk '/Battery Percentage/ {print $3}')
		if [[ $batt == 0x* ]]; then
			batt=$((16#${batt_hex#0x}))
		fi
		notify-send "Bluetooth" "Connected to ${name:-$dev}${batt:+\nBattery: $batt%}"
		exit 0
	fi
done

exit 0
