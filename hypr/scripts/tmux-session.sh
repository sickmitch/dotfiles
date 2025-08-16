#!/bin/bash

# Script to attach to existing tmux session MAIN or create it if it doesn't exist
TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"

# Check if tmux server is running and has session MAIN
if tmux -f "$TMUX_CONFIG" has-session -t MAIN 2>/dev/null; then
    # Session exists, attach to it
    tmux -f "$TMUX_CONFIG" attach-session -t MAIN
else
    # Session doesn't exist or no server running, create it
    tmux -f "$TMUX_CONFIG" new-session -s MAIN
fi 