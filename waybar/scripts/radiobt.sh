#!/bin/bash

# Check the output of pgrep and wc -l
if [[ $(pgrep -f /home/mike/.config/systemd/user/auto_bt_low-fi.sh | wc -l) -eq 1 ]]; then
  if [ "$1" = "status" ]; then
    notify-send "Status" "Radio running"
    exit
  else
    systemctl --user stop bt_listener
  fi
else
  if [ "$1" = "status" ]; then
    notify-send "Status" "Radio stopped"
    exit 0
  else
    systemctl --user start bt_listener
  fi
fi

exit 0
