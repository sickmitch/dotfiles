#!/bin/bash

# Define common PDF locations - add or modify these based on your needs
PDF_LOCATIONS=(
    "$HOME/Documenti"
    "$HOME/Scaricati"
)

# Path to the recents file
RECENTS_FILE="$HOME/.config/zathura/recents.txt"

# Ensure the recents file exists
mkdir -p "$(dirname "$RECENTS_FILE")"
touch "$RECENTS_FILE"

# Read recent files
recent_files=$(cat "$RECENTS_FILE" | sed "s|$HOME/Documenti/||g; s|$HOME/Scaricati/||g")

# Find PDF files only in specified locations and get their parent directories
pdf_folders=$(for dir in "${PDF_LOCATIONS[@]}"; do
    if [ -d "$dir" ]; then
        find "$dir" -name "*.pdf" -exec dirname {} \; 2>/dev/null | \
        sed "s|$HOME/Documenti/||g; s|$HOME/Scaricati/||g" # Remove the common prefixes
    fi
done | sort -u | grep -v "^$HOME/Documenti$" | grep -v "^$HOME/Scaricati$")

# Ensure "Recents" is the first entry and "Go Back" is the last entry
combined_list=$(echo -e "Recents\n$pdf_folders\nGo Back")

# Use wofi to show the folders and store selection
selected_folder=$(echo "$combined_list" | wofi \
    --location=center \
    --height=400 \
    --width=800 \
    -i -n \
    -s ~/.config/wofi/wofi.css \
    --show dmenu \
    --prompt "Select folder or recent file")

# If "Go Back" is selected, restart the script
if [ "$selected_folder" == "Go Back" ]; then
    exec "$0"
fi

# If a folder or recent file was selected, show PDF files in that folder with their sizes
if [ -n "$selected_folder" ]; then
    if [ "$selected_folder" == "Recents" ]; then
        # Show recent files as if they are in a folder
        selected_pdf=$(echo -e "$recent_files\nGo Back" | wofi \
            --location=center \
            --height=300 \
            --width=700 \
            -i -n \
            -s ~/.config/wofi/wofi.css \
            --show dmenu \
            --prompt "Select recent PDF file")
        
        # If "Go Back" is selected, restart the script
        if [ "$selected_pdf" == "Go Back" ]; then
            exec "$0"
        fi

        # If a PDF was selected, open it with zathura
        if [ -n "$selected_pdf" ]; then
            zathura "$HOME/Documenti/$selected_pdf" || zathura "$HOME/Scaricati/$selected_pdf"
        fi
    else
        # Reconstruct the full path for find command
        full_path="$HOME/Documenti/$selected_folder"
        if [ ! -d "$full_path" ]; then
            full_path="$HOME/Scaricati/$selected_folder"
        fi
        selected_pdf=$(find "$full_path" -maxdepth 1 -name "*.pdf" -printf "%f\n" | \
            echo -e "$(cat -)\nGo Back" | \
            wofi \
                --location=center \
                --height=300 \
                --width=700 \
                -i -n \
                -s ~/.config/wofi/wofi.css \
                --show dmenu \
                --prompt "Select PDF file")
        # If "Go Back" is selected, restart the script
        if [ "$selected_pdf" == "Go Back" ]; then
            exec "$0"
        fi

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
