#!/usr/bin/env bash
set -euo pipefail

# --- DETECT USER ---
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

[ -z "$TARGET_HOME" ] && { echo "Error: Home directory not found." >&2; exit 1; }

# --- COLORS ---
BOLD="\033[1m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

log_info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[OK]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }

# --- PACKAGES ---
PACMAN_PKGS=(
    # Core & System
    base base-devel linux linux-zen linux-firmware git curl wget sudo zsh
    networkmanager bluez bluez-utils blueman ufw

    # Hyprland & Environment
    hyprland hypridle hyprlock hyprpaper hyprpicker hyprpolkitagent hyprsunset
    waybar rofi swaync fuzzel dunst
    grim slurp satty wl-clipboard cliphist tesseract tesseract-data-ukr tesseract-data-eng
    intel-media-driver

    # Terminals & Shell Tools
    kitty alacritty fastfetch btop eza fzf zoxide yazi stow
    starship tmux zsh

    # Audio, Video & Theme
    pipewire pipewire-pulse wireplumber pavucontrol easyeffects cava
    mpv zathura thunar
    qt5-wayland qt6-wayland matugen nwg-look

    # Fonts & Development
    ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd ttf-nerd-fonts-symbols
    neovim zed github-cli jq ripgrep fd unzip 7zip
)

AUR_PKGS=(
    zen-browser cursor obsidian telegram-desktop anki catppuccin-cursors-mocha catppuccin-gtk-theme-mocha wlogout
    wayland-pipewire-idle-inhibit
)
# --- MODULES ---

step_yay() {
    log_info "Step 1: Updating system & setting up yay..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm base-devel git

    if ! command -v yay &> /dev/null; then
        log_info "Installing yay from AUR..."
        local build_dir
        build_dir=$(mktemp -d)

        sudo -u "$TARGET_USER" git clone https://aur.archlinux.org/yay.git "$build_dir"
        (cd "$build_dir" && sudo -u "$TARGET_USER" makepkg -s --noconfirm)

        local pkg
        pkg=$(find "$build_dir" -maxdepth 1 -name "yay-*.pkg.tar.zst" | head -n 1)
        [ -f "$pkg" ] && sudo pacman -U --noconfirm "$pkg" || { log_error "Yay build failed."; exit 1; }

        rm -rf "$build_dir"
        log_success "yay installed."
    else
        log_success "yay is already installed."
    fi
}

step_packages() {
    log_info "Step 2: Installing applications..."
    [ ${#PACMAN_PKGS[@]} -gt 0 ] && sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
    [ ${#AUR_PKGS[@]} -gt 0 ] && sudo -u "$TARGET_USER" yay -S --needed --noconfirm "${AUR_PKGS[@]}"
    log_success "Packages installed."
}

step_configs() {
    log_info "Step 3: Deploying dotfiles..."
    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local config_dest="$TARGET_HOME/.config"
    local backup_dir="$TARGET_HOME/.config_backups/backup_$(date +%Y%m%d_%H%M%S)"
    local group
    group=$(id -gn "$TARGET_USER")

    mkdir -p "$config_dest"

    if [ -d "$dotfiles_dir/.config" ]; then
        log_info "Backing up existing configs to $backup_dir..."
        mkdir -p "$backup_dir"

        for item in "$dotfiles_dir/.config/"*; do
            [ -e "$item" ] || continue
            local name
            name=$(basename "$item")
            [ -e "$config_dest/$name" ] && cp -a "$config_dest/$name" "$backup_dir/"
        done

        log_info "Copying new configurations..."
        cp -a "$dotfiles_dir/.config/." "$config_dest/"
        chown -R "$TARGET_USER:$group" "$config_dest"

        # Normalize home paths
        log_info "Normalizing paths to $TARGET_HOME..."
        local safe_home
        safe_home=$(printf '%s\n' "$TARGET_HOME" | sed -e 's/[\&]/\\&/g' -e 's/|/\\|/g')

        find "$config_dest" -type f \( -name "*.conf" -o -name "*.json" -o -name "*.toml" -o -name "*.lua" -o -name "*.sh" -o -name "*.css" -o -name "*.ini" \) \
            -exec sed -i -E "s|/home/[^/]+|$safe_home|g" {} + 2>/dev/null || true
    fi

    if [ -f "$dotfiles_dir/.zshrc" ]; then
        log_info "Deploying .zshrc..."
        [ -f "$TARGET_HOME/.zshrc" ] && cp -a "$TARGET_HOME/.zshrc" "$backup_dir/.zshrc.bak"
        cp -a "$dotfiles_dir/.zshrc" "$TARGET_HOME/"
        chown "$TARGET_USER:$group" "$TARGET_HOME/.zshrc"
    fi

    log_success "Configs deployed."
}

step_extras() {
    log_info "Step 4: Running post-install setup..."
    local zsh_path
    zsh_path=$(command -v zsh || echo '/bin/zsh')

    if [ "$(getent passwd "$TARGET_USER" | cut -d: -f7)" != "$zsh_path" ]; then
        chsh -s "$zsh_path" "$TARGET_USER" || log_warn "Failed to change default shell."
    fi

    if command -v spicetify &> /dev/null && [ -d "/opt/spotify" ]; then
        log_info "Configuring Spicetify..."
        local group
        group=$(id -gn "$TARGET_USER")
        sudo chmod a+wr /opt/spotify /opt/spotify/Apps -R
        sudo chown -R "$TARGET_USER:$group" /opt/spotify
        sudo -u "$TARGET_USER" spicetify backup apply 2>/dev/null || sudo -u "$TARGET_USER" spicetify apply 2>/dev/null || true
    fi

    log_success "Extras configured."
}

# --- CLI & MENU ---
show_help() {
    echo -e "${BOLD}Usage:${RESET} ./install.sh [FLAG]"
    echo "  -a, --all        Run all steps"
    echo "  -y, --yay        System update & yay install only"
    echo "  -p, --packages   Install packages only"
    echo "  -c, --configs    Deploy configs only"
    echo "  -e, --extras     Extras only (Shell, Spicetify)"
    echo "  -h, --help       Show help"
}

if [ $# -eq 0 ]; then
    echo -e "${BOLD}--- DOTFILES INSTALLER ---${RESET}"
    echo "1) Full Installation"
    echo "2) System Update & yay only"
    echo "3) Install Packages only"
    echo "4) Deploy Configs only"
    echo "5) Extra Setups only"
    echo "q) Quit"
    read -rp "Select option [1-5/q]: " choice
    case "$choice" in
        1) step_yay; step_packages; step_configs; step_extras ;;
        2) step_yay ;;
        3) step_packages ;;
        4) step_configs ;;
        5) step_extras ;;
        q|Q) exit 0 ;;
        *) log_error "Invalid choice!"; exit 1 ;;
    esac
else
    case "$1" in
        -a|--all) step_yay; step_packages; step_configs; step_extras ;;
        -y|--yay) step_yay ;;
        -p|--packages) step_packages ;;
        -c|--configs) step_configs ;;
        -e|--extras) step_extras ;;
        -h|--help) show_help ;;
        *) log_error "Unknown flag: $1"; show_help; exit 1 ;;
    esac
fi

log_success "Done!"
