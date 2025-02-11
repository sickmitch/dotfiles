#!/bin/bash

# SSID targets
TARGET_SSIDS=("Vodafone-MeS")

# NFS server and shares
NFS_SERVER="192.168.1.20"
NFS_SHARES=(
    "/share/:/home/mike/NAS/"
    "/share/documenti/:/home/mike/Documenti/"
)

# Check if connected to one of the target SSIDs
current_ssid=$(iwgetid -r)

if [[ " ${TARGET_SSIDS[@]} " =~ " ${current_ssid} " ]]; then
    echo "Connected to $current_ssid."

    # Loop through each share
    for share_mapping in "${NFS_SHARES[@]}"; do
        IFS=':' read -r share mount_point <<< "$share_mapping"
        
        # Check if mount point exists, if not, create it
        if [ ! -d "$mount_point" ]; then
            mkdir -p "$mount_point"
        fi

        # Check if already mounted
        if mount | grep -q "$mount_point"; then
            echo "NFS share $share already mounted at $mount_point"
        else
            # Mount the NFS share
            sudo mount -t nfs "$NFS_SERVER:$share" "$mount_point"
            if [ $? -eq 0 ]; then
                echo "NFS share $share mounted successfully at $mount_point"
            else
                echo "Failed to mount NFS share $share at $mount_point"
                DISPLAY=:0 /usr/bin/notify-send -u critical "Failed to mount NAS" #notify
            fi
        fi
    done
else
    echo "Not connected to any target SSID. No action taken."
fi

