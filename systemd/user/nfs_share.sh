#!/bin/bash

# SSID targets
TARGET_SSIDS=("Vodafone-MeS")

# NFS server and shares
NFS_SERVER="192.168.1.20"
NFS_SHARES=(
    "/share/:/home/mike/NAS/"
)
current_ssid=$(iwgetid -r)

# Loop through each share mapping
for share_mapping in "${NFS_SHARES[@]}"; do
    IFS=':' read -r share mount_point <<< "$share_mapping"

# Check if mount point exists, if not, create it
if [ ! -d "$mount_point" ]; then
    mkdir -p "$mount_point"
fi

mount_nfs() {
    if sudo mount -t nfs "$NFS_SERVER:$share" "$mount_point"; then
        echo "NFS share $share mounted successfully at $mount_point"
    else
        echo "Failed to mount NFS share $share at $mount_point"
        DISPLAY=:0 /usr/bin/notify-send -u critical "Failed to mount NAS" #notify
        exit 2
    fi
}

if [[ " ${TARGET_SSIDS[*]} " =~ ${current_ssid} ]]; then
        mount_nfs
    else
        if sudo -u mike tailscale up --accept-dns --accept-routes; then
            echo "Tailscale up successful"
            mount_nfs
        else
            echo "Tailscale up failed"
            DISPLAY=:0 /usr/bin/notify-send -u critical "Failed to connect to Tailscale" #notify
        fi
    fi
done
