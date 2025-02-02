#!/bin/bash

# Define common PDF locations - add or modify these based on your needs
PDF_LOCATIONS=(
    "$HOME/Documenti"
)

# Path to the recents file
RECENTS_FILE="$HOME/.config/zathura/recents.txt"

# Ensure the recents file exists
mkdir -p "$(dirname "$RECENTS_FILE")"
touch "$RECENTS_FILE"

# Read recent files
recent_files=$(cat "$RECENTS_FILE" | sed "s|$HOME/Documenti/||g")

# Find PDF files only in specified locations and get their parent directories
pdf_folders=$(for dir in "${PDF_LOCATIONS[@]}"; do
    if [ -d "$dir" ]; then
        find "$dir" -name "*.pdf" -exec dirname {} \; 2>/dev/null | \
        sed "s|$HOME/Documenti/||g" # Remove the common prefix
    fi
done | sort -u | grep -v "^$HOME/Documenti$")

# Ensure "Recents" is the first entry
combined_list=$(echo -e "Recents\n$pdf_folders")

# Use wofi to show the folders and store selection
selected_folder=$(echo "$combined_list" | wofi \
    --location=center \
    --height=800 \
    --width=800 \
    -i \
    -s ~/.config/wofi/wofi.css \
    --show dmenu \
    --prompt "Select folder or recent file")

# If a folder or recent file was selected, show PDF files in that folder with their sizes
if [ -n "$selected_folder" ]; then
    if [ "$selected_folder" == "Recents" ]; then
        # Show recent files as if they are in a folder
        selected_pdf=$(echo "$recent_files" | wofi \
            --location=center \
            --height=800 \
            --width=800 \
            -i \
            -s ~/.config/wofi/wofi.css \
            --show dmenu \
            --prompt "Select recent PDF file")
        
        # If a PDF was selected, open it with zathura
        if [ -n "$selected_pdf" ]; then
            zathura "$HOME/Documenti/$selected_pdf"
        fi
    else
        # Reconstruct the full path for find command
        full_path="$HOME/Documenti/$selected_folder"
        selected_pdf=$(find "$full_path" -maxdepth 1 -name "*.pdf" -printf "%f\n" | \
            wofi \
                --location=center \
                --height=800 \
                --width=800 \
                -i \
                -s ~/.config/wofi/wofi.css \
                --show dmenu \
                --prompt "Select PDF file")
        
        # If a PDF was selected, open it with zathura and add to recents
        if [ -n "$selected_pdf" ]; then
            zathura "$full_path/$selected_pdf"
            # Add to recents
            echo "$selected_folder/$selected_pdf" >> "$RECENTS_FILE"
            # Keep only unique entries
            sort -u "$RECENTS_FILE" -o "$RECENTS_FILE"
        fi
    fi
fi
