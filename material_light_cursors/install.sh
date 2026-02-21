#!/usr/bin/env bash
## /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script to install Material Light Cursors

THEME_NAME="material_light_cursors"
ICONS_DIR="$HOME/.icons"
DOTFILES_DIR="$HOME/dotfiles"

echo "Installing $THEME_NAME..."

# 1. Create .icons directory if it doesn't exist
mkdir -p "$ICONS_DIR"

# 2. Copy the theme to .icons
cp -rf "$DOTFILES_DIR/$THEME_NAME" "$ICONS_DIR/"

# 3. Update GSettings
gsettings set org.gnome.desktop.interface cursor-theme "$THEME_NAME"

# 4. Update Hyprland Environment Variables (User Version)
ENV_FILE="$HOME/.config/hypr/UserConfigs/ENVariables.conf"
if [ -f "$ENV_FILE" ]; then
    # Comment out old theme envs if they exist or just add new ones
    sed -i "s/^env = HYPRCURSOR_THEME,.*/# env = HYPRCURSOR_THEME,Bibata-Modern-Ice/g" "$ENV_FILE"
    
    # Since this is an X11 theme, we set XCURSOR_THEME
    if grep -q "XCURSOR_THEME" "$ENV_FILE"; then
        sed -i "s/^env = XCURSOR_THEME,.*/env = XCURSOR_THEME,$THEME_NAME/g" "$ENV_FILE"
    else
        echo "env = XCURSOR_THEME,$THEME_NAME" >> "$ENV_FILE"
    fi
    
    # Ensure HYPRCURSOR_THEME is not overriding if it doesn't have a hyprcursor version
    # Hyprland will check HYPRCURSOR_THEME first.
fi

echo "Installation complete! Please restart Hyprland or your session to apply changes."
