#!/bin/bash

# PID file to prevent multiple instances
PIDFILE="/tmp/bar-hide-hover.pid"

# Function to cleanup on exit
cleanup() {
    rm -f "$PIDFILE"
    exit 0
}

# Check if another instance is already running
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Another instance of bar-hide-hover.sh is already running (PID: $OLD_PID)"
        exit 1
    else
        # Remove stale PID file
        rm -f "$PIDFILE"
    fi
fi

# Create PID file
echo $$ > "$PIDFILE"

# Set up signal handlers for cleanup
trap cleanup SIGTERM SIGINT EXIT

bar_visible=true # Start with the bar hidden
sleep 5 && pkill -SIGUSR1 waybar && bar_visible=false  # Hide the bar on startup

# Function to get cursor Y position safely
get_cursor_y() {
    local y_pos
    local hyprctl_output
    
    # Get hyprctl output and check if command succeeded
    if ! hyprctl_output=$(hyprctl cursorpos -j 2>/dev/null); then
        echo "0"  # Return 0 if hyprctl fails
        return
    fi
    
    # Extract Y coordinate
    y_pos=$(echo "$hyprctl_output" | grep '"y"' | cut -d":" -f2 | tr -d ' ,}')
    
    # Check if y_pos is a valid integer
    if [[ "$y_pos" =~ ^[0-9]+$ ]]; then
        echo "$y_pos"
    else
        echo "0"  # Default to 0 if parsing fails
    fi
}

# Monitor cursor position
while true; do
    # Get cursor position using hyprctl
    Y=$(get_cursor_y)
    
    if [ "$Y" -le 5 ] && [ "$bar_visible" = false ]; then
        pkill -SIGUSR1 waybar
        bar_visible=true
        while [ "$Y" -le 35 ]; do
            sleep 0.5
            Y=$(get_cursor_y)
        done
    elif [ "$Y" -gt 35 ] && [ "$bar_visible" = true ]; then
        pkill -SIGUSR1 waybar
        bar_visible=false
    fi
    sleep 0.5
done

