#!/bin/bash

CHECK=$(acpi -b | grep "Battery 0" | grep -c "Discharging")        #if the battery is discharging return 1
RES=$(acpi -b | grep "Battery 0" | cut -d " " -f 4 | sed 's/%,//') #take out battery level

if [[ $CHECK -eq 1 ]]; then                                                     #check if pc discharging
  if [[ $RES -lt 11 ]]; then                                                    #check if percentage is under 11
    DISPLAY=:0 /usr/bin/notify-send -u critical "$(acpi -b | grep "Battery 0")" #notify
  fi
else
  exit 0
fi

exit
