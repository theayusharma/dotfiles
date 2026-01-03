#!/bin/bash
#
# # make sure bluetooth is on
# bluetoothctl power on >/dev/null 2>&1
# sleep 0.5
#
# # get paired devices, most recent last -> reverse with tac so we try latest first
# mapfile -t devices < <(bluetoothctl paired-devices | awk '{print $2}' | tac)
#
# for dev in "${devices[@]}"; do
#     # try to connect
#     if bluetoothctl connect "$dev" >/dev/null 2>&1; then
#         sleep 1
#
#         # get device name
#         name=$(bluetoothctl info "$dev" | awk -F': ' '/Name/ {print $2}')
#
#         # get battery (hex) if available
#         batt_hex=$(bluetoothctl info "$dev" | awk '/Battery Percentage/ {print $3}')
#         if [[ $batt_hex == 0x* ]]; then
#             batt_dec=$((16#${batt_hex#0x}))
#         fi
#
#         notify-send "Connected to ${name:-$dev}" "Battery level: ${batt_dec:-Unknown}%"
#         exit 0
#     fi
# done
#
# notify-send "Bluetooth" "Could not connect to any paired device"
#

# turn bluetooth on

# unblock bluetooth (rfkill)
rfkill unblock bluetooth 2>/dev/null

# ensure bluetooth service is running
systemctl --user start bluetooth.service 2>/dev/null || systemctl start bluetooth.service

# power on adapter
bluetoothctl power on >/dev/null 2>&1

# wait until adapter exists AND is powered
for i in {1..20}; do
    bluetoothctl show | grep -q "Powered: yes" && break
    sleep 0.3
done

# if still not powered, exit silently
bluetoothctl show | grep -q "Powered: yes" || exit 0

# try paired devices
mapfile -t devices < <(bluetoothctl paired-devices | awk '{print $2}')

for dev in "${devices[@]}"; do
    bluetoothctl info "$dev" | grep -q "Connectable: yes" || continue

    if bluetoothctl connect "$dev" >/dev/null 2>&1; then
        name=$(bluetoothctl info "$dev" | awk -F': ' '/Name/ {print $2}')
        batt=$(bluetoothctl info "$dev" | awk -F': ' '/Battery Percentage/ {print $2}')
        notify-send "Bluetooth" "Connected to ${name:-$dev}\nBattery: ${batt:-Unknown}"
        exit 0
    fi
done

# silent exit — no failure spam
exit 0
