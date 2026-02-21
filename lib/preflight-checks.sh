#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Pre-flight Checks #

run_preflight_checks() {
    local log="$1"
    local error_found=0

    echo "${INFO} Running pre-flight checks..."

    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        echo "${ERROR} This script should NOT be executed as root!! Exiting......." | tee -a "$log"
        return 1
    fi

    # Check for PulseAudio
    if pacman -Qq | grep -qw '^pulseaudio$'; then
        echo "$ERROR PulseAudio is detected as installed. Please uninstall it first or use pipewire." | tee -a "$log"
        error_found=1
    fi

    # Check for base-devel
    if ! pacman -Q base-devel &> /dev/null; then
        echo "$NOTE base-devel is missing. Attempting to install..."
        if ! sudo pacman -S --noconfirm base-devel; then
            echo "❌ $ERROR base-devel installation failed." | tee -a "$log"
            error_found=1
        fi
    fi

    # Check for whiptail
    if ! command -v whiptail >/dev/null; then
        echo "${NOTE} whiptail is missing. Installing..."
        sudo pacman -S --noconfirm libnewt
    fi

    if [ $error_found -eq 1 ]; then
        return 1
    fi

    echo "${OK} Pre-flight checks passed!"
    return 0
}
