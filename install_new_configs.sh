#!/bin/bash

# Configuration
SOURCE_CONFIG="$HOME/dotfiles/config"
DEST_CONFIG="$HOME/.config"

echo "🔍 Checking for new configurations in $SOURCE_CONFIG..."

# Sync dotfiles/config to ~/.config
# -a: archive mode (preserves permissions, etc.)
# -u: update (only copy if source is newer or destination is missing)
# -v: verbose
rsync -auv "$SOURCE_CONFIG/" "$DEST_CONFIG/"

echo "✨ Sync complete!"

# Reload Hyprland if it's running to apply changes immediately
if pgrep -x Hyprland > /dev/null; then
    echo "🔄 Reloading Hyprland..."
    hyprctl reload
fi
