#!/bin/bash

# SSID target
TARGET_SSID="MeS"

# NFS server and share
NFS_SERVER="192.168.1.22"
NFS_SHARE="/"
MOUNT_POINT="/home/mike/NAS/"

# Check if connected to the target SSID
current_ssid=$(iwgetid -r)

if [ "$current_ssid" == "$TARGET_SSID" ]; then
    echo "Connected to $TARGET_SSID."

    # Check if mount point exists, if not, create it
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
    fi

    # Check if already mounted
    if mount | grep -q "$MOUNT_POINT"; then
        echo "NFS share already mounted."
    else
        # Mount the NFS share
        sudo mount -t nfs "$NFS_SERVER:$NFS_SHARE" "$MOUNT_POINT"
        
        if [ $? -eq 0 ]; then
            echo "NFS share mounted successfully."
        else
            echo "Failed to mount NFS share."
        fi
    fi
else
    echo "Not connected to $TARGET_SSID. No action taken."
fi

