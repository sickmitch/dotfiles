#!/bin/sh

focusedwsisempty=$(hyprctl workspaces | grep -A 2 "monitor $(hyprctl monitors -j | jq -r 'map(select(.focused == true)) | .[] | .name')" | grep "windows: 0")

if [[ -z $focusedwsisempty ]]; then
    openedwslist=($(hyprctl workspaces | grep "ID [0-99]" | cut -d " " -f 3 | sort -h | tr '\n' ' '))
    calculated_num=0
    for i in "${openedwslist[@]}"; do
        if (( calculated_num != 0 && i != calculated_num + 1 )); then
            if [[ $1 = "--move" ]]; then
                hyprctl dispatch movetoworkspace $((calculated_num + 1))
            elif [[ $1 = "--move-silent" ]]; then
                hyprctl dispatch movetoworkspacesilent $((calculated_num + 1))
            else
                hyprctl dispatch workspace $((calculated_num + 1))
            fi
            exit 0
        fi
        calculated_num=$i
    done  
    if [[ $1 = "--move" ]]; then
        hyprctl dispatch movetoworkspace $((calculated_num + 1))
    elif [[ $1 = "--move-silent" ]]; then
        hyprctl dispatch movetoworkspacesilent $((calculated_num + 1)) 
    else
        hyprctl dispatch workspace $((calculated_num + 1))
    fi
else
    echo "Already focusing an empty workspace..."
fi
w