#!/bin/bash

# Configuration
REPOSITORY=/backup/home/
BACKUP_PATH=/home/mike/
ARCHIVE_NAME="home-$(date +%Y-%m-%d_%H:%M)"

# Reset checks
BACK=0
PRUNE=0

# Create a list of mounted points under your home directory
MOUNTED_PATHS=$(findmnt -n -l -o TARGET | grep "^$BACKUP_PATH" || true)

# Build exclude patterns for mounted paths
EXCLUDE_OPTS=""
while IFS= read -r mount_point; do
    if [ ! -z "$mount_point" ]; then
        EXCLUDE_OPTS="$EXCLUDE_OPTS --exclude '$mount_point'"
    fi
done <<< "$MOUNTED_PATHS"

# Add any additional excludes you might want
EXCLUDE_OPTS="$EXCLUDE_OPTS --exclude '/home/mike/*.tmp' --exclude '/home/mike/*.temp' --exclude '/home/mike/.cache/*'"

# Create backup command
BACKUP_CMD="sudo borg create \
    --stats \
    --progress \
    --compression lz4 \
    $EXCLUDE_OPTS \
    $REPOSITORY::$ARCHIVE_NAME \
    $BACKUP_PATH"

# Prune command
PRUNE_CMD="sudo borg prune \
    -v --list
    $REPOSITORY \
    --keep-within 1d --keep-daily 7"


# Execute the backup
eval $BACKUP_CMD
if [ $? -eq 0 ]; then
    BACK=1
fi

# Prune repo
eval $PRUNE_CMD
if [ $? -eq 0 ]; then
    PRUNE=1
fi

if [ $PRUNE -eq 0 ] && [ $BACK -eq 0 ]; then
    systemd-notify --status="Failed"
elif [ $PRUNE -eq 1 ] && [ $BACK -eq 0 ]; then
    systemd-notify --status="Backup Failed"
elif [ $PRUNE -eq 0 ] && [ $BACK -eq 1 ]; then
    systemd-notify --status="Prune Failed"
elif [ $PRUNE -eq 1 ] && [ $BACK -eq 1 ]; then
    systemd-notify --status="$(date +%H:%M) - Success"
fi


