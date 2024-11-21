#!/bin/bash

# Initialize state variable
bar_visible=true
# Monitor cursor position
while true; do
    # Get cursor position using hyprctl
    read Y < <( hyprctl cursorpos -j | sed -n '4p' | cut -d":" -f2)
    if [ "$Y" -le 5 ] && [ "$bar_visible" = true ]; then
        pkill -SIGUSR2 waybar
        bar_visible=false
        while [ "$Y" -le 35 ]; do
            sleep 0.5
            read Y < <( hyprctl cursorpos -j | sed -n '4p' | cut -d":" -f2)
        done
    elif [ "$Y" -gt 35 ] && [ "$bar_visible" = false ]; then
        pkill -SIGUSR1 waybar
        bar_visible=true
    fi
    sleep 0.5
done
