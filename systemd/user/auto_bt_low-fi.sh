#!/bin/bash

device_macs=("00:1B:66:0F:3D:F0" "30:53:C1:46:59:D4")

while true; do
  device_connected=false

  for mac in "${device_macs[@]}"; do
    dbus_path="/org/bluez/hci0/dev_${mac//:/_}"

    if busctl get-property org.bluez "$dbus_path" \
       org.bluez.Device1 Connected 2>/dev/null | grep -q "true"; then
      device_connected=true
      break
    fi
  done

  if [ "$device_connected" = true ]; then
    # ffmpeg -i "https://ibizasonica.streaming-pro.com:8000/ibizasonica" -vn -f mp3 - | cvlc -
    # cvlc https://streams.fluxfm.de/Chillhop/mp3-320/streams.fluxfm.de/
    # cvlc http://usa9.fastcast4u.com/proxy/jamz?mp=/1
    yt-dlp -f 95 -o - https://youtu.be/jfKfPfyJRdk | ffmpeg -i - -vn -f mp3 - | cvlc - || true
  fi

  sleep 5
done

exit 0

