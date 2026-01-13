#!/bin/bash
# ===============================================
# Install all dependencies for Arch/i3 setup
# This script installs each package only once
# ===============================================

# 🔹 Core System Tools
sudo pacman -S --needed base-devel git wget curl

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
yay -S --needed brave-bin
yay -S --needed telegram-desktop-bin
yay -S --needed ticktick

# ===============================================
# 2️⃣ i3 / UI / Panels / Status
# ===============================================
sudo pacman -S --needed i3-wm i3status i3blocks dmenu rofi picom feh xorg-xsetroot \
    polybar dunst ttf-ubuntu-font-family ttf-jetbrains-mono-nerd kitty \
    dex xss-lock network-manager-applet brightnessctl playerctl

# ===============================================
# 3️⃣ Keyboard / Mouse / Input
# ===============================================
sudo pacman -S --needed xinput xf86-input-libinput libinput-gestures wmctrl xdotool

# ===============================================
# 4️⃣ Screenshots / Clipboard / OCR
# ===============================================
sudo pacman -S --needed flameshot maim slop xclip tesseract
sudo pacman -S --needed tesseract-data-eng tesseract-data-deu tesseract-data-ukr tesseract-data-rus
yay -S --needed gimagereader normcap
yay -S --needed greenclip rofi-emoji xcolor

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
yay -S --needed neofetch fish anki acpi upower

# ===============================================
# Finish
# ===============================================
echo "All dependencies installed successfully!"
