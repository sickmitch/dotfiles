#!/bin/bash

# Configuration
REPOSITORY=/backup/home/
BACKUP_PATH=/home/mike/
ARCHIVE_NAME="home-$(date +%Y-%m-%d_%H:%M)"

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

# Prune repo
eval $PRUNE_CMD
