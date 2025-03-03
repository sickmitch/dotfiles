#!/bin/bash

# Define source and destination directories
SRC=~/Documenti
DEST=~/NAS/documenti

# Run rclone bisync command
rclone bisync "$SRC" "$DEST" \
    --check-access \
    --check-filename .RCLONE \
    --recover \
    --create-empty-src-dirs \
    --conflict-resolve newer \
    --conflict-suffix "conflict" \
    --max-lock 2m \
    --no-update-modtime \
    --no-update-dir-modtime \
    --check-sync=false \
    --verbose

# Check if rclone bisync command was successful
if [ $? -ne 0 ]; then
    echo "Error: rclone bisync failed. Please check the output for details."
    exit 1
else
    echo "Sync completed successfully."
fi
