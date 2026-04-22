#!/bin/sh

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
