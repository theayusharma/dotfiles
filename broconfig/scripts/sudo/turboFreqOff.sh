#!/bin/bash

MODE=$1

if [[ "$MODE" == "performance" ]]; then
    echo "Setting CPU to performance mode (boost on, EPP performance)"
    for i in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo performance | sudo tee $i > /dev/null
    done
    echo 1 | sudo tee /sys/devices/system/cpu/cpufreq/boost > /dev/null
    notify-send "CPU Mode" "Performance mode activated"

elif [[ "$MODE" == "powersave" ]]; then
    echo "Setting CPU to power-saving mode (boost off, EPP power)"
    for i in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo power | sudo tee $i > /dev/null
    done
    echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost > /dev/null
    notify-send "CPU Mode" "Power-saving mode activated"

else
    echo "Usage: $0 [performance | powersave]"
    notify-send "CPU Mode" "Invalid argument. Use: performance or powersave"
fi
