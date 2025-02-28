#!/bin/bash

CHECK=`acpi -b | grep "Battery 0" |  grep "Discharging" | wc -l`   #if the battery is discharging return 1
RES=`acpi -b | grep "Battery 0" | cut -d " " -f 5` #take out the time field of acpi -b

if [[ $CHECK == 1 ]] #check if pc is in charge
then
  if [[ $RES < 00:30:00 ]] ; then #time left on battery trigger
      DISPLAY=:0 /usr/bin/notify-send -u critical "$(acpi -b | grep "Battery 0")" #notify
  fi
else
  exit 2
fi

exit
