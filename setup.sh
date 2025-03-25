#!/bin/bash

# OMORI Dotfiles Installer for Arch Linux
# This script automatically downloads and installs OMORI-themed dotfiles
# Only for Arch Linux installations

# Exit on error
set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# GitHub repository URL
REPO_URL="https://github.com/omori-dotfiles/omori-dotfiles"
ARCHIVE_URL="https://github.com/omori-dotfiles/omori-dotfiles/archive/refs/heads/main.zip"

# Welcome message
clear
echo -e "${WHITE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${WHITE}║                                                          ║${NC}"
echo -e "${WHITE}║        ${MAGENTA}WELCOME TO WHITE SPACE.${WHITE}                           ║${NC}"
echo -e "${WHITE}║        ${CYAN}OMORI DOTFILES INSTALLER${WHITE}                           ║${NC}"
echo -e "${WHITE}║                                                          ║${NC}"
echo -e "${WHITE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}This script will install and configure all necessary components for the OMORI-themed dotfiles.${NC}"
echo -e "${YELLOW}It's designed ONLY for a clean Arch Linux installation.${NC}"
echo ""
echo -e "${RED}Note: This script will make changes to your system.${NC}"
echo -e "${RED}It's recommended to run this on a fresh Arch installation.${NC}"
echo ""

# Check if running on Arch Linux
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "arch" ]; then
        echo -e "${RED}This script is only for Arch Linux.${NC}"
        echo -e "${RED}Detected OS: $PRETTY_NAME${NC}"
        exit 1
    fi
else
    echo -e "${RED}Cannot determine OS. This script is only for Arch Linux.${NC}"
    exit 1
fi

# Ask for confirmation
read -p "Do you want to continue? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation aborted.${NC}"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install package if not already installed
install_package() {
    if ! pacman -Q "$1" >/dev/null 2>&1; then
        echo -e "${BLUE}Installing $1...${NC}"
        sudo pacman -S --noconfirm "$1"
    else
        echo -e "${GREEN}$1 is already installed.${NC}"
    fi
}

# Function to install AUR package
install_aur_package() {
    if ! pacman -Q "$1" >/dev/null 2>&1; then
        echo -e "${BLUE}Installing $1 from AUR...${NC}"
        yay -S --noconfirm "$1"
    else
        echo -e "${GREEN}$1 is already installed.${NC}"
    fi
}

# Function to create directory if it doesn't exist
create_dir() {
    if [ ! -d "$1" ]; then
        echo -e "${BLUE}Creating directory $1...${NC}"
        mkdir -p "$1"
    fi
}

# Function to create symlink
create_symlink() {
    if [ -e "$2" ]; then
        # Backup the existing file
        mv "$2" "$2.backup.$(date +%Y%m%d%H%M%S)"
        echo -e "${YELLOW}Backed up existing $2${NC}"
    fi
    
    echo -e "${BLUE}Creating symlink from $1 to $2...${NC}"
    ln -sf "$1" "$2"
}

# Update system
echo -e "${CYAN}==== Updating system ====${NC}"
sudo pacman -Syu --noconfirm

# Install initial required packages
echo -e "${CYAN}==== Installing initial requirements ====${NC}"
for pkg in git base-devel unzip curl; do
    install_package "$pkg"
done

# Install yay (AUR helper) if not installed
if ! command_exists yay; then
    echo -e "${CYAN}==== Installing yay AUR helper ====${NC}"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd - > /dev/null
    echo -e "${GREEN}Yay installed successfully.${NC}"
else
    echo -e "${GREEN}Yay is already installed.${NC}"
fi

# Download dotfiles
echo -e "${CYAN}==== Downloading OMORI dotfiles ====${NC}"
TMP_DIR=$(mktemp -d)
echo -e "${BLUE}Downloading from $ARCHIVE_URL...${NC}"
curl -L "$ARCHIVE_URL" -o "$TMP_DIR/omori-dotfiles.zip"
unzip -q "$TMP_DIR/omori-dotfiles.zip" -d "$TMP_DIR"
DOTFILES_DIR="$TMP_DIR/omori-dotfiles-main"
echo -e "${GREEN}Dotfiles downloaded and extracted successfully.${NC}"

# Install required packages
echo -e "${CYAN}==== Installing required packages ====${NC}"

# Core packages
PACKAGES=(
    "hyprland"        # Window manager
    "alacritty"       # Terminal
    "thunar"          # File manager
    "rofi"            # Application launcher
    "waybar"          # Status bar
    "starship"        # Shell prompt
    "lazygit"         # Git interface
    "wlogout"         # Logout screen
    "hyprpaper"       # Wallpaper manager
    "firefox-developer-edition" # Browser
    "grim"            # Screenshot utility
    "slurp"           # Area selection for screenshots
    "xdg-desktop-portal-hyprland" # XDG portal for Hyprland
    "polkit-gnome"    # Authentication agent
    "nm-connection-editor" # Network manager GUI
    "network-manager-applet" # Network manager tray icon
    "pavucontrol"     # Audio control
    "ttf-ubuntu-nerd" # Font
    "ttf-monofur-nerd" # Font
    "ttf-font-awesome" # Icons
    "otf-font-awesome" # Icons
)

for pkg in "${PACKAGES[@]}"; do
    install_package "$pkg"
done

# AUR packages
AUR_PACKAGES=(
    "spicetify-cli"    # Spotify customization
    "spotify"          # Spotify
    "spotify-player"   # Spotify TUI player
)

for pkg in "${AUR_PACKAGES[@]}"; do
    install_aur_package "$pkg"
done

# Install OMORI_GAME font
echo -e "${CYAN}==== Installing OMORI_GAME font ====${NC}"
create_dir "$HOME/.local/share/fonts"
cp "$DOTFILES_DIR/OMORI_GAME.ttf" "$HOME/.local/share/fonts/"
fc-cache -f

# Create config directories
echo -e "${CYAN}==== Creating config directories ====${NC}"
CONFIG_DIRS=(
    "$HOME/.config/alacritty"
    "$HOME/.config/hypr"
    "$HOME/.config/lazygit"
    "$HOME/.config/rofi"
    "$HOME/.config/spicetify/Themes"
    "$HOME/.config/spotify-player"
    "$HOME/.config/waybar"
    "$HOME/.config/wlogout"
)

for dir in "${CONFIG_DIRS[@]}"; do
    create_dir "$dir"
done

# Create Spicetify theme directory
create_dir "$HOME/.config/spicetify/Themes/StarryNight/images"

# Create symlinks
echo -e "${CYAN}==== Creating symlinks ====${NC}"

# Alacritty
create_symlink "$DOTFILES_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# Hyprland
create_symlink "$DOTFILES_DIR/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
create_symlink "$DOTFILES_DIR/hypr/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"

# Lazygit
create_symlink "$DOTFILES_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"

# Rofi
create_symlink "$DOTFILES_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
create_symlink "$DOTFILES_DIR/rofi/omori.rasi" "$HOME/.config/rofi/omori.rasi"
create_symlink "$DOTFILES_DIR/rofi/iggy.rasi" "$HOME/.config/rofi/iggy.rasi"

# Copy Rofi images
cp "$DOTFILES_DIR/rofi/selected.png" "$HOME/.config/rofi/"
cp "$DOTFILES_DIR/rofi/selected_mode.png" "$HOME/.config/rofi/"
cp "$DOTFILES_DIR/rofi/selected_mode_b&w.png" "$HOME/.config/rofi/"
cp "$DOTFILES_DIR/rofi/hand.png" "$HOME/.config/rofi/" 2>/dev/null || true

# Spicetify
create_symlink "$DOTFILES_DIR/spicetify/Themes/StarryNight/color.ini" "$HOME/.config/spicetify/Themes/StarryNight/color.ini"
create_symlink "$DOTFILES_DIR/spicetify/Themes/StarryNight/theme.js" "$HOME/.config/spicetify/Themes/StarryNight/theme.js"
create_symlink "$DOTFILES_DIR/spicetify/Themes/StarryNight/user.css" "$HOME/.config/spicetify/Themes/StarryNight/user.css"
create_symlink "$DOTFILES_DIR/spicetify/Themes/StarryNight/README.md" "$HOME/.config/spicetify/Themes/StarryNight/README.md"

# Copy Spicetify images
if [ -d "$DOTFILES_DIR/spicetify/Themes/StarryNight/images" ]; then
    cp -r "$DOTFILES_DIR/spicetify/Themes/StarryNight/images"/* "$HOME/.config/spicetify/Themes/StarryNight/images/"
fi

# Spotify-player
create_symlink "$DOTFILES_DIR/spotify-player/app.toml" "$HOME/.config/spotify-player/app.toml"
create_symlink "$DOTFILES_DIR/spotify-player/theme.toml" "$HOME/.config/spotify-player/theme.toml"

# Waybar
create_symlink "$DOTFILES_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config"
create_symlink "$DOTFILES_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"

# Wlogout
create_symlink "$DOTFILES_DIR/wlogout/layout" "$HOME/.config/wlogout/layout"
create_symlink "$DOTFILES_DIR/wlogout/style.css" "$HOME/.config/wlogout/style.css"

# Copy Wlogout images
if [ -f "$DOTFILES_DIR/wlogout/selected_wlogout.png" ]; then
    cp "$DOTFILES_DIR/wlogout/selected_wlogout.png" "$HOME/.config/wlogout/"
fi

# Home directory dotfiles
if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    create_symlink "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
fi

if [ -f "$DOTFILES_DIR/.inputrc" ]; then
    create_symlink "$DOTFILES_DIR/.inputrc" "$HOME/.inputrc"
fi

create_symlink "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

# Ask for wallpaper
echo -e "${CYAN}==== Setting up wallpaper ====${NC}"
echo -e "${YELLOW}Would you like to download a default wallpaper? (y/n)${NC}"
read -r download_wallpaper

if [[ $download_wallpaper =~ ^[Yy]$ ]]; then
    create_dir "$HOME/Pictures/Wallpapers"
    echo -e "${BLUE}Downloading default OMORI wallpaper...${NC}"
    # This URL should be updated with a permanent link to your wallpaper
    WALLPAPER_URL="https://raw.githubusercontent.com/omori-dotfiles/omori-dotfiles/main/wallpapers/omori_wallpaper.png"
    curl -L "$WALLPAPER_URL" -o "$HOME/Pictures/Wallpapers/omori_wallpaper.png"
    
    # Update hyprpaper.conf
    sed -i "s|preload = # set wallpaper path here|preload = $HOME/Pictures/Wallpapers/omori_wallpaper.png|g" "$HOME/.config/hypr/hyprpaper.conf"
    sed -i "s|wallpaper = ,# set wallpaper path here|wallpaper = ,$HOME/Pictures/Wallpapers/omori_wallpaper.png|g" "$HOME/.config/hypr/hyprpaper.conf"
    
    echo -e "${GREEN}Wallpaper set successfully.${NC}"
else
    echo -e "${YELLOW}Please enter the path to your wallpaper image:${NC}"
    echo -e "${YELLOW}(Leave empty to skip wallpaper setup)${NC}"
    read -r wallpaper_path

    if [ -n "$wallpaper_path" ] && [ -f "$wallpaper_path" ]; then
        # Create wallpapers directory
        create_dir "$HOME/Pictures/Wallpapers"
        
        # Copy wallpaper
        cp "$wallpaper_path" "$HOME/Pictures/Wallpapers/omori_wallpaper.png"
        
        # Update hyprpaper.conf
        sed -i "s|preload = # set wallpaper path here|preload = $HOME/Pictures/Wallpapers/omori_wallpaper.png|g" "$HOME/.config/hypr/hyprpaper.conf"
        sed -i "s|wallpaper = ,# set wallpaper path here|wallpaper = ,$HOME/Pictures/Wallpapers/omori_wallpaper.png|g" "$HOME/.config/hypr/hyprpaper.conf"
        
        echo -e "${GREEN}Wallpaper set successfully.${NC}"
    else
        echo -e "${YELLOW}Skipping wallpaper setup.${NC}"
    fi
fi

# Configure Spicetify
echo -e "${CYAN}==== Configuring Spicetify ====${NC}"
if command_exists spicetify; then
    # Apply Spotify permissions
    sudo chmod a+wr /opt/spotify
    sudo chmod a+wr /opt/spotify/Apps -R
    
    # Configure Spicetify
    spicetify config current_theme StarryNight
    spicetify backup apply
    
    echo -e "${GREEN}Spicetify configured successfully.${NC}"
else
    echo -e "${RED}Spicetify not found. Please install it manually.${NC}"
fi

# Cleanup
echo -e "${CYAN}==== Cleaning up ====${NC}"
rm -rf "$TMP_DIR"
echo -e "${GREEN}Cleanup completed.${NC}"

# Setup completed message
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}║           ${WHITE}OMORI DOTFILES SETUP COMPLETED${GREEN}               ║${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Please log out and log back in to start using Hyprland${NC}"
echo -e "${YELLOW}or run 'Hyprland' from your TTY to start it now.${NC}"
echo ""
echo -e "${WHITE}Welcome to White Space.${NC}"
echo -e "${WHITE}You have been living here for as long as you can remember.${NC}"
echo ""
echo -e "${CYAN}Repository: ${WHITE}$REPO_URL${NC}"
echo ""