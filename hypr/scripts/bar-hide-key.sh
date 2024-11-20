#!/bin/bash

H=true 

if [ "$H" = true ]; then
    pkill -SIGUSR1 waybar
    H=false # Cambia H in false
else
    pkill -SIGUSR2 waybar
    H=true # Cambia H in true
fi

