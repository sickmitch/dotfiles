#!/bin/bash

# Tutto ciò che và fatto prima di spegnere il sistema
# - Smonto il NAS
# - Disattivo Tailscale
# - Chiudo Chrome

# Mando una notifica per conferma che lo script è partito
if [ "$1" = "reboot" ]; then
  DISPLAY=:0 /usr/bin/notify-send -u critical "Rebooting the system" #notify
elif [ "$1" = "shutdown" ]; then
  DISPLAY=:0 /usr/bin/notify-send -u critical "Shutting down the system" #notify
fi

# Smonto il NAS
if findmnt -M NAS/; then
  sudo umount /home/mike/NAS
  sleep 3
fi

# Disattivo Tailscale
if [ "$(ip a | grep -c "100.64.224.43")" -gt 0 ]; then
  tailscale down
  sleep 3
fi

# Chiudo Chrome 
if pgrep chrome > /dev/null; then
  echo "Closing Google Chrome gracefully…"
  pkill -TERM chrome

  # Wait for Chrome to exit (max 10 seconds)
  timeout=10
  while pgrep chrome >/dev/null && [ $timeout -gt 0 ]; do
    sleep 1
    ((timeout--))
  done
fi

if [ "$1" = "reboot" ]; then
  systemctl reboot
elif [ "$1" = "shutdown" ]; then
  systemctl poweroff
fi
