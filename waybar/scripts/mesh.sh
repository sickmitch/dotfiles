#!/bin/bash

if [ "$1" = "menu" ]; then
    # Define menu options
    choice=$(echo -e "Mesh Connect\nConnect\nDisconnect\nStatus" | wofi --location=top_right --height=260 --width=200 --yoffset=10 --xoffset=-40 --dmenu -i -s ~/.config/wofi/wofi.css --prompt="VPN Manage")
    
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
            sudo systemctl start nordvpnd && sleep 2 && nordvpn mesh peer connect hpe && sudo ip r a 192.168.1.0/24 via 100.117.63.130
            ;;
        "connect")
            sudo systemctl start nordvpnd && sleep 2 && nordvpn connect
            ;;
        "disconnect")
            if [ "$2" = "mesh" ]; then
                sudo ip r d 192.168.1.0/24
            fi
            nordvpn disconnect && sudo systemctl stop nordvpnd
            ;;
        "status")
            mesh_connected=$(ip route show | grep -c "192.168.1.0/24 via 100.117.63.130")
            vpn_connected=$(nordvpn status | grep -c "Connected")
            
            if [ "$mesh_connected" -eq 1 ]; then
                notify-send "Mesh Status" "Connected to HPE network"
            elif [ "$vpn_connected" -eq 1 ]; then
                notify-send "VPN Status" "Connected to VPN"
            else
                notify-send "Status" "Not connected to VPN"
            fi
            ;;
    esac
fi
