#!/bin/bash

# SSID target
TARGET_SSID="Vodafone-MeS"

# NFS server and shares
NFS_SERVER="192.168.1.21"
NFS_SHARES=(
    "/share/:/home/mike/NAS/"
    "/share/data/documenti/:/home/mike/Documenti/"
)

# Check if connected to the target SSID
current_ssid=$(iwgetid -r)

if [ "$current_ssid" == "$TARGET_SSID" ]; then
    echo "Connected to $TARGET_SSID."

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
            fi
        fi
    done
else
    echo "Not connected to $TARGET_SSID. No action taken."
fi

