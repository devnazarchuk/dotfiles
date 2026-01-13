#!/usr/bin/env bash

# Dynamic Installer for Dotfiles
# Automatically installs all folders found in ./config/ to ~/.config/

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_SRC_DIR="$DOTFILES_DIR/config"
HOME_CONFIG_DIR="$HOME/.config"

echo ":: Starting Installation..."

# ensure ~/.config exists
mkdir -p "$HOME_CONFIG_DIR"

# 1. Determine Backup Suffix
suffix="_backup"
counter=0
while true; do
    conflict_found=false
    # Check if backup would conflict for any directory in config/
    for entry in "$CONFIG_SRC_DIR"/*; do
        basename=$(basename "$entry")
        target="$HOME_CONFIG_DIR/$basename"
        backup_target="${target}${suffix}"
        
        if [ -e "$backup_target" ]; then
            conflict_found=true
            break
        fi
    done
    
    if [ "$conflict_found" = true ]; then
        counter=$((counter + 1))
        suffix="_backup${counter}"
    else
        break
    fi
done
echo ":: Backup suffix selected: '$suffix'"

# 2. Install (Backup + Copy)
# Iterate over everything in config/
for entry in "$CONFIG_SRC_DIR"/*; do
    basename=$(basename "$entry")
    target="$HOME_CONFIG_DIR/$basename"

    echo ":: Processing $basename..."

    # Backup existing
    if [ -e "$target" ]; then
        echo "   Backing up: $target -> ${target}${suffix}"
        mv "$target" "${target}${suffix}"
    fi

    # Symlink (or Copy)
    # Ideally symlinking is better for dotfiles so changes propagate back to repo
    # But user asked to "copy properly", existing script did cp -r.
    # I will stick to cp -r to match previous behavior unless requested otherwise.
    echo "   Copying: $entry -> $target"
    cp -r "$entry" "$target"
done

# Handle loose files if necessary (like packages.txt, etc if they go somewhere)
# For now, we only handle config/* -> ~/.config/*

echo ":: Installation Complete!"
echo ":: Make sure to reload your window manager (Super+Shift+R)."
