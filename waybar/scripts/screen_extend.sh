#!/bin/bash

if [ "$1" = "status" ]; then
  if [ "$(hyprctl monitors | grep -c EXTEND)" == 0 ]; then
    dunstify "STATUS" "Extended monitor not running"
  else
    dunstify "STATUS" "Extended monitor is running"
  fi
  exit 0
fi

if [ "$(hyprctl monitors | grep -c "EXTEND")" == 0 ]; then
  hyprctl output create headless EXTEND
  weylus &
  dunstify "SCREEN EXTENDER" "Ready to extend screen"
else
  hyprctl output remove EXTEND
  pkill weylus
  pkill zathura
  dunstify "SCREEN EXTENDER" "Reverted to normal"
fi

exit 0
