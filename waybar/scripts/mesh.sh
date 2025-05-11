#!/bin/bash

if [ "$1" = "menu" ]; then
  # Define menu options
  choice=$(echo -e "Mesh Connect\nConnect\nDisconnect\nStatus" | wofi --height=200 --width=200 --x=-50 --y=10 --location=top_right --dmenu -i -s ~/.config/wofi/wofi.css --prompt="VPN Manage")

  case $choice in
  "Mesh Connect")
    ~/.config/waybar/scripts/mesh.sh mconnect
    ;;
  "Connect")
    ~/.config/waybar/scripts/mesh.sh connect
    ;;
  "Disconnect")
    ~/.config/waybar/scripts/mesh.sh disconnect
    ;;
  "Status")
    ~/.config/waybar/scripts/mesh.sh status
    ;;
  esac
else
  # Handle the actual parameters
  case $1 in
  "mconnect")
    sudo systemctl start nordvpnd && sleep 10 && nordvpn mesh peer connect dl360 && sudo ip r a 192.168.1.0/24 via 100.99.82.46
    systemctl --user restart nfs_share && sleep 5
    if [ -d /home/mike/NAS/documenti/ ]; then
      notify-send -u critical "Status" "NAS is available"
    fi
    ;;
  "connect")
    sudo systemctl start nordvpnd && sleep 10 && nordvpn connect
    ;;
  "disconnect")
    sudo ip r d 192.168.1.0/24
    sudo umount ~/NAS && nordvpn disconnect && sudo systemctl stop nordvpnd
    ;;
  "status")
    mesh_connected=$(ip route show | grep -c "192.168.1.0/24 via 100.99.82.46")
    vpn_connected=$(nordvpn status | grep -c "Connected")

    if [ "$mesh_connected" -eq 1 ]; then
      dunstify "Status" "Connected to HOME network"
    elif [ "$vpn_connected" -eq 1 ]; then
      dunstify "Status" "Connected to VPN"
    else
      dunstify "Status" "Not connected to VPN"
    fi
    ;;
  esac
fi
