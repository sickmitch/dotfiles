#!/bin/bash

printf 'script started' | systemd-cat -t check-battery #write to log when script is called

BATTINFO=$(acpi -b)
BVAL=`echo $BATTINFO | grep Discharging | wc -l`   #if the battery is discharging return 1
BCUT=`echo $BATTINFO | cut -d " " -f 5` #take out the time field of acpi -b

if [[ $BVAL == 1 ]] #check if pc is in charge
then
    if [[ $BCUT < 00:30:00 ]] ; then #time left on battery trigger
        printf 'condition is true' | systemd-cat -t check-battery #log
        DISPLAY=:0 /usr/bin/notify-send -u critical "$BATTINFO" #notify
    fi
else
    exit
fi

exit
