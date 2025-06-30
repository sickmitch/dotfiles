#!/bin/bash

if [ "$1" = "menu" ]; then
  # Define menu options
  choice=$(echo -e "Connect\nDisconnect\nStatus" | wofi --height=170 --width=200 --x=-350 --y=5 --location=top_right --dmenu -i -s ~/.config/wofi/wofi.css --prompt="VPN Manage")

  case $choice in
  "Connect")
    ~/.config/waybar/scripts/tailscale.sh connect
    ;;
  "Disconnect")
    ~/.config/waybar/scripts/tailscale.sh disconnect
    ;;
  "Status")
    ~/.config/waybar/scripts/tailscale.sh status
    ;;
  esac
else
  # Handle the actual parameters
  case $1 in
  "connect")
    tailscale up --accept-dns --accept-routes
    if sudo mount -t nfs 192.168.1.20:/share/ /home/mike/NAS/; then
      notify-send -u critical "$(echo -e "Connected from Tailnet\n NAS online")"
    else
      notify-send -u critical "Something went wrong"
    fi
    ;;
  "disconnect")
    sudo umount /home/mike/NAS
    if tailscale down; then
      notify-send -u critical "$(echo -e "Disconnected from Tailnet\n NAS offline")"
    fi
    ;;
  "status")
    body=$(tailscale status)
    if [[ "$body" == *$'\n'* ]]; then
      body="Connected to Tailnet"
    fi
    notify-send -u critical "$body"
    ;;
  esac
fi
