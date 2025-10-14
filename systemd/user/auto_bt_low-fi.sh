#!/bin/bash
device_mac="00:1B:66:0F:3D:F0"

while true; do
  if bluetoothctl info "$device_mac" | grep -q "Connected: yes"; then
    yt-dlp -f 95 -o - https://youtu.be/5yx6BWlEVcY   | ffmpeg -i pipe:0 -vn -f mp3 -   | cvlc -
    # cvlc https://streams.fluxfm.de/Chillhop/mp3-320/streams.fluxfm.de/
  fi
  sleep 5
done
