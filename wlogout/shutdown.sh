#!/bin/bash

# Tutto ciò che và fatto prima di spegnere il sistema
# - Smonto il NAS
# - Disattivo Tailscale

# Mando una notifica per conferma che lo script è partito
if [ "$1" = "reboot" ]; then
  zenity --warning --text="Rebooting the system" --title="System Notice"
elif [ "$1" = "shutdown" ]; then
  zenity --warning --text="Shutting down the system" --title="System Notice"
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

if [ "$1" = "reboot" ]; then
  systemctl reboot
elif [ "$1" = "shutdown" ]; then
  systemctl poweroff
fi
