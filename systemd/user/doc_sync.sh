#!/bin/bash

source /home/mike/.config/systemd/user/oc_secrets.txt

owncloudcmd /home/mike/Documenti $DOMAIN / -u $USER -p $PASSWD

if [ $? -ne 0 ]; then
    DISPLAY=:0 /usr/bin/notify-send -u critical "Failed to sync docs"
    exit 1
else
    exit 0
fi
