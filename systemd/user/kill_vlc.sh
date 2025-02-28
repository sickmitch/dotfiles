#!/bin/bash

DEVICE="00:1B:66:0F:3D:F0"

was_connected=0

check_device() {
    bluetoothctl info "$DEVICE" | grep -q "Connected: yes"
}

while true; do
    if check_device; then
        if [ "$was_connected" -eq 0 ]; then
            was_connected=1
        fi
    else
        if [ "$was_connected" -eq 1 ]; then
            pkill vlc
            was_connected=0
        fi
    fi
    sleep 5  # Adjust polling interval
done
