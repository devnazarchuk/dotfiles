#!/bin/bash
# ===============================================
# Install all dependencies for Arch/i3 setup
# This script installs each package only once
# ===============================================

# 🔹 Core System Tools
sudo pacman -S --needed base-devel git wget curl accountsservice

# 🔹 AUR helper
if ! command -v yay >/dev/null 2>&1; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
fi

# ===============================================
# 1️⃣ Browsers / Messengers
# ===============================================
#yay -S --needed brave-bin
#yay -S --needed telegram-desktop-bin
#yay -S --needed ticktick

# ===============================================
# 2️⃣ Hyprland / UI / Panels / Status
# ===============================================
sudo pacman -S --needed hyprland waybar swaync rofi-wayland swww \
    ttf-ubuntu-font-family ttf-jetbrains-mono-nerd kitty \
    network-manager-applet brightnessctl playerctl \
    sddm plymouth qt5-quickcontrols2 layer-shell-qt \
    hypridle hyprlock hyprpicker xdg-desktop-portal-hyprland
yay -S --needed matugen-bin hyprpolkitagent-bin

# ===============================================
# 3️⃣ Keyboard / Mouse / Input
# ===============================================
sudo pacman -S --needed libinput-gestures wmctrl xdotool

# ===============================================
# 4️⃣ Screenshots / Clipboard / OCR
# ===============================================
sudo pacman -S --needed flameshot grim slurp wl-clipboard tesseract
sudo pacman -S --needed tesseract-data-eng tesseract-data-deu tesseract-data-ukr tesseract-data-rus
yay -S --needed normcap
yay -S --needed greenclip rofi-emoji-wayland

# ===============================================
# 5️⃣ Archives / File Manager / Keyring
# ===============================================
sudo pacman -S --needed thunar file-roller unzip unrar p7zip tar gzip bzip2 xz \
    gnome-keyring libsecret gvfs noto-fonts-emoji

# ===============================================
# 6️⃣ Multimedia / Graphics
# ===============================================
sudo pacman -S --needed mpv ffmpeg libva libva-utils mesa \
    pipewire pipewire-alsa pipewire-pulse wireplumber pavucontrol \
    imv feh gimp krita evince imagemagick yt-dlp zed

# ===============================================
# 7️⃣ Shells / Utilities
# ===============================================
yay -S --needed neofetch fish anki-bin acpi upower \
    blueman librepods python-pillow

# 🔹 Notion App Icon
mkdir -p ~/.local/share/icons
wget -q https://upload.wikimedia.org/wikipedia/commons/4/45/Notion_app_logo.png -O ~/.local/share/icons/notion.png
#sudo pacman -S --needed zram-generator
#sudo sed -i 's/zram-size = 4096/zram-size = 16384/' /etc/systemd/zram-generator.conf && sudo systemctl daemon-reload && sudo systemctl restart systemd-zram-setup@zram0.service

# ===============================================
# Finish
# ===============================================
echo "All dependencies installed successfully!"
