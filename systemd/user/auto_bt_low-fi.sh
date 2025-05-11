#!/bin/bash
device_mac="00:1B:66:0F:3D:F0"

while true; do
  if bluetoothctl info "$device_mac" | grep -q "Connected: yes"; then
    cvlc --no-video "$(yt-dlp -f bestaudio --get-url https://youtu.be/jfKfPfyJRdk)"
  fi
  sleep 5
done
