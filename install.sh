#!/usr/bin/env bash

# Dynamic Installer for Dotfiles
# Automatically installs all folders found in ./config/ to ~/.config/

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_SRC_DIR="$DOTFILES_DIR/config"
HOME_CONFIG_DIR="$HOME/.config"

echo ":: Starting Installation..."

# ensure ~/.config exists
mkdir -p "$HOME_CONFIG_DIR"

# 1. Cleanup Old Backups
echo ":: Checking for old backups..."
limit=3
pruned=false
to_prune_list=()

# Find unique base names that have at least one backup folder
base_names=$(find "$HOME_CONFIG_DIR" -maxdepth 1 -name "*_backup*" | sed -E 's/(.*)(_backup.*)/\1/' | xargs -n1 basename | sort -u)

for base in $base_names; do
    backups_count=$(ls -dt "$HOME_CONFIG_DIR/${base}"_backup* 2>/dev/null | wc -l)
    if [ "$backups_count" -gt "$limit" ]; then
        to_prune_list+=("$base")
    fi
done

if [ ${#to_prune_list[@]} -gt 0 ]; then
    echo ":: Found folders with more than $limit backups: ${to_prune_list[*]}"
    read -p "   Prune all to $limit recent backups? [A]ll / [M]anual / [n]o: " global_choice
    
    case "$global_choice" in
        [Aa]*)
            for base in "${to_prune_list[@]}"; do
                backups=$(ls -dt "$HOME_CONFIG_DIR/${base}"_backup* 2>/dev/null)
                to_delete=$(echo "$backups" | tail -n +$((limit + 1)))
                for item in $to_delete; do
                    echo "   Deleting old backup: $(basename "$item")"
                    rm -rf "$item"
                done
            done
            pruned=true
            ;;
        [Mm]*)
            for base in "${to_prune_list[@]}"; do
                backups=$(ls -dt "$HOME_CONFIG_DIR/${base}"_backup* 2>/dev/null)
                count=$(echo "$backups" | wc -l)
                read -p "   Keep only 3 most recent for '$base'? ($count found) [y/N] " choice
                if [[ "$choice" =~ ^[Yy]$ ]]; then
                    to_delete=$(echo "$backups" | tail -n +$((limit + 1)))
                    for item in $to_delete; do
                        echo "   Deleting old backup: $(basename "$item")"
                        rm -rf "$item"
                    done
                    pruned=true
                fi
            done
            ;;
        *)
            echo "   Skipping cleanup."
            ;;
    esac
fi
[ "$pruned" = true ] && echo ":: Pruning complete."

# 2. Determine Backup Suffix for CURRENT installation
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
echo ":: Backup suffix for this session: '$suffix'"

# 3. Install (Backup + Copy)
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
    echo "   Copying: $entry -> $target"
    cp -r "$entry" "$target"
done

echo ":: Installation Complete!"
echo ":: Make sure to reload your window manager (Super+Shift+R)."
