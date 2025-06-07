#!/bin/bash

# Script to monitor and reset i8042 controller on "Spurious ACK" error
# Intended for Lenovo IdeaPad Gaming 3 15ARH7 with Arch Linux

LOG_FILE="/var/log/i8042_reset.log"
ERROR_PATTERN="atkbd serio0: Spurious ACK on isa0060/serio0"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Function to reset i8042 controller
reset_i8042() {
    log_message "Attempting to reset i8042 controller"

    # Check if i8042 is a module
    if lsmod | grep -q "^i8042"; then
        # Unload and reload i8042 module
        modprobe -r i8042 && modprobe i8042
        if [ $? -eq 0 ]; then
            log_message "Successfully reloaded i8042 module"
        else
            log_message "Failed to reload i8042 module"
            return 1
        fi
    else
        # If i8042 is built-in, try resetting via parameters
        echo 1 > /sys/module/i8042/parameters/reset 2>/dev/null
        if [ $? -eq 0 ]; then
            log_message "Successfully reset i8042 via parameter"
        else
            log_message "Failed to reset i8042 via parameter"
            return 1
        fi
    fi
    return 0
}

# Function to monitor logs for the error
monitor_logs() {
    log_message "Starting log monitoring for Spurious ACK error"
    journalctl -f -k | grep -m 1 "$ERROR_PATTERN" | while read -r line; do
        log_message "Detected Spurious ACK error: $line"
        reset_i8042
    done
}

# Run reset before suspend (called by systemd)
if [ "$1" == "pre-suspend" ]; then
    log_message "Running pre-suspend i8042 reset"
    reset_i8042
    exit $?
fi

# Run reset after resume (called by systemd)
if [ "$1" == "post-resume" ]; then
    log_message "Running post-resume i8042 reset"
    reset_i8042
    exit $?
fi

# Default: Start monitoring logs
monitor_logs
