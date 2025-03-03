#!/bin/bash

# Check the output of pgrep and wc -l
if [[ $(pgrep -f /home/mike/.config/systemd/user/auto_bt_low-fi.sh | wc -l) -eq 1 ]]; then
    systemctl --user stop bt_listener
else
    systemctl --user start bt_listener
fi

exit 0
