#!/usr/bin/env bash

# Ghostty Dual Profile System Installer
# Complete setup for profile switching via ss (direct) and gswitch (fzf interactive)

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
GHOSTTY_DIR="$HOME/.config/ghostty"
PROFILES_DIR="$GHOSTTY_DIR/profiles"
SHADERS_DIR="$GHOSTTY_DIR/shaders"
SCRIPTS_DIR="$HOME/scripts"
CONFIG_FILE="$GHOSTTY_DIR/config"
ZSHRC="$HOME/.zshrc"

# Get the directory where this script is located (the cloned repo)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Header
echo ""
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║                                                            ║${NC}"
echo -e "${BOLD}${CYAN}║          Ghostty Dynamic Profile System Installer          ║${NC}"
echo -e "${BOLD}${CYAN}║                                                            ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print section headers
section() {
    echo ""
    echo -e "${BOLD}${MAGENTA}▶ $1${NC}"
    echo ""
}

# Function to print success
success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

# Function to print info
info() {
    echo -e "  ${BLUE}ℹ${NC} $1"
}

# Function to print warning
warning() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

# Function to print error
error() {
    echo -e "  ${RED}✗${NC} $1"
}

# Step 1: Check prerequisites
section "Step 1: Checking Prerequisites"

# Check if Homebrew is installed
if command -v brew &> /dev/null; then
    success "Homebrew is installed"

    # Check and install fzf
    if command -v fzf &> /dev/null; then
        success "fzf is already installed"
    else
        info "Installing fzf via Homebrew..."
        if brew install fzf; then
            success "fzf installed successfully"
        else
            warning "Failed to install fzf. You can install it manually later: brew install fzf"
        fi
    fi
else
    warning "Homebrew not found. Please install fzf manually if you want to use gswitch"
    info "Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
fi

# Step 2: Create directory structure
section "Step 2: Setting Up Directory Structure"

# Create Ghostty directories
mkdir -p "$GHOSTTY_DIR"
success "Created $GHOSTTY_DIR"

mkdir -p "$PROFILES_DIR"
success "Created $PROFILES_DIR"

# Create scripts directory
mkdir -p "$SCRIPTS_DIR"
success "Created $SCRIPTS_DIR"

# Step 3: Clean up old files
section "Step 3: Cleaning Up Old Configuration Files"

# Backup and remove old config files
if [[ -f "$CONFIG_FILE" ]]; then
    BACKUP_FILE="$CONFIG_FILE.pre-install-backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    success "Backed up existing config to $BACKUP_FILE"
fi

# Remove old backup files
OLD_BACKUPS=("$GHOSTTY_DIR"/config.old.bak "$GHOSTTY_DIR"/config.*.bak "$GHOSTTY_DIR"/config.backup-* "$GHOSTTY_DIR"/config.bak)
for backup in "${OLD_BACKUPS[@]}"; do
    if [[ -f "$backup" ]]; then
        rm -f "$backup"
        success "Removed old backup: $(basename "$backup")"
    fi
done

# Remove old theme and script files
OLD_FILES=("$GHOSTTY_DIR/ghostty-themes.json" "$GHOSTTY_DIR/generate-ghosttly-config.sh" "$GHOSTTY_DIR/install-ghosttly-profiles.sh" "$SCRIPTS_DIR/ss.sh.old")
for file in "${OLD_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        rm -f "$file"
        success "Removed old file: $(basename "$file")"
    fi
done

info "Cleanup complete"

# Step 4: Install profile configurations
section "Step 4: Installing Profile Configurations"

# Copy all profile files from repo to profiles directory
if [[ -d "$REPO_DIR/profiles" ]]; then
    cp -f "$REPO_DIR/profiles/"*.conf "$PROFILES_DIR/"
    PROFILE_COUNT=$(ls -1 "$PROFILES_DIR"/profile_*.conf 2>/dev/null | wc -l | tr -d ' ')
    success "Installed $PROFILE_COUNT profile configurations"
else
    error "Profile directory not found in repository"
    exit 1
fi

# Step 5: Clone shader repository
section "Step 5: Setting Up Shaders"

if [[ -d "$SHADERS_DIR" ]]; then
    info "Shaders directory already exists at $SHADERS_DIR"
    read -p "  Do you want to update it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$SHADERS_DIR"
        info "Removed old shaders directory"
    fi
fi

if [[ ! -d "$SHADERS_DIR" ]]; then
    info "Cloning ghostty-shaders repository..."
    if git clone https://github.com/hackr-sh/ghostty-shaders.git "$SHADERS_DIR" 2>/dev/null; then
        success "Shaders cloned successfully"
    else
        warning "Failed to clone shaders. Some visual effects may not work."
        info "You can clone manually: git clone https://github.com/hackr-sh/ghostty-shaders.git $SHADERS_DIR"
    fi
else
    success "Shaders directory already up to date"
fi

# Step 6: Install switching scripts
section "Step 6: Installing Profile Switching Scripts"

# Copy and make executable the ss.sh script
if [[ -f "$REPO_DIR/scripts/ss.sh" ]]; then
    cp "$REPO_DIR/scripts/ss.sh" "$SCRIPTS_DIR/ss.sh"
    chmod +x "$SCRIPTS_DIR/ss.sh"
    success "Installed ss.sh to $SCRIPTS_DIR"
else
    error "ss.sh not found in repository"
    exit 1
fi

# Copy and make executable the gswitch.sh script
if [[ -f "$REPO_DIR/scripts/gswitch.sh" ]]; then
    cp "$REPO_DIR/scripts/gswitch.sh" "$SCRIPTS_DIR/gswitch.sh"
    chmod +x "$SCRIPTS_DIR/gswitch.sh"
    success "Installed gswitch.sh to $SCRIPTS_DIR"
else
    error "gswitch.sh not found in repository"
    exit 1
fi

# Step 7: Configure shell integration
section "Step 7: Configuring Shell Integration"

# Backup .zshrc
if [[ -f "$ZSHRC" ]]; then
    cp "$ZSHRC" "$ZSHRC.backup.$(date +%Y%m%d_%H%M%S)"
    success "Backed up .zshrc"
else
    touch "$ZSHRC"
    success "Created .zshrc"
fi

# Check if aliases already exist
if grep -q "# Ghostty Profile Switcher" "$ZSHRC" 2>/dev/null; then
    info "Shell integration already configured in .zshrc"
else
    # Add to .zshrc
    cat >> "$ZSHRC" << 'EOF'

# Ghostty Profile Switcher - Added by install.sh
# Direct profile switching: ss <number>
alias ss="$HOME/scripts/ss.sh"

# Interactive fzf-based profile switching: gswitch
alias gswitch="$HOME/scripts/gswitch.sh"

# Add scripts directory to PATH if not already there
if [[ ":$PATH:" != *":$HOME/scripts:"* ]]; then
    export PATH="$HOME/scripts:$PATH"
fi
EOF
    success "Added profile switching commands to .zshrc"
fi

# Step 8: Create default base configuration
section "Step 8: Creating Default Base Configuration"

cat > "$CONFIG_FILE" << 'EOF'
# Ghostty Base Configuration
# This file is managed by the profile switching system
# Use 'ss <number>' or 'gswitch' to switch profiles

# Window configuration
window-width = 140
window-height = 40

# Font configuration
font-family = "BerkeleyMono Nerd Font"
font-size = 14
adjust-cell-height = 35%
line-height = 1.15

# Default theme - Nord
background = 2e3440
foreground = d8dee9
cursor-color = d8dee9
selection-background = 4c566a
selection-foreground = d8dee9

# Palette - Nord
palette = 0=#3b4252
palette = 1=#bf616a
palette = 2=#a3be8c
palette = 3=#ebcb8b
palette = 4=#81a1c1
palette = 5=#b48ead
palette = 6=#88c0d0
palette = 7=#e5e9f0
palette = 8=#4c566a
palette = 9=#bf616a
palette = 10=#a3be8c
palette = 11=#ebcb8b
palette = 12=#81a1c1
palette = 13=#b48ead
palette = 14=#8fbcbb
palette = 15=#eceff4

# Performance and behavior
window-theme = dark
background-opacity = 1.0
unfocused-split-opacity = 0.75
renderer = metal
scrollback-limit = 25000
mouse-scroll-multiplier = 3

# Text rendering (no wrapping for AI CLI tools)
text-wrap = false

# Keybinds
keybind = cmd+shift+r=reload_config
EOF

success "Created default configuration file"

# Step 9: Final instructions
section "Installation Complete!"

echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}${BOLD}🎉 Ghostty Profile System Installed Successfully!${NC}"
echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo ""
echo -e "  ${YELLOW}1.${NC} Reload your shell configuration:"
echo -e "     ${CYAN}source ~/.zshrc${NC}"
echo ""
echo -e "  ${YELLOW}2.${NC} View available profiles:"
echo -e "     ${CYAN}ss${NC}         ${BLUE}(shows numbered list)${NC}"
echo ""
echo -e "  ${YELLOW}3.${NC} Switch profiles using either method:"
echo -e "     ${CYAN}ss 5${NC}       ${BLUE}(direct switch to profile 5)${NC}"
echo -e "     ${CYAN}gswitch${NC}    ${BLUE}(interactive fzf menu)${NC}"
echo ""
echo -e "${BOLD}Available Profiles:${NC}"
echo -e "  ${GREEN}01${NC} Catppuccin Latte    ${GREEN}11${NC} Monokai Pro"
echo -e "  ${GREEN}02${NC} Catppuccin Mocha    ${GREEN}12${NC} Ayu Dark"
echo -e "  ${GREEN}03${NC} Nord                ${GREEN}13${NC} Material Ocean"
echo -e "  ${GREEN}04${NC} Dracula             ${GREEN}14${NC} Palenight"
echo -e "  ${GREEN}05${NC} Solarized Dark      ${GREEN}15${NC} Oceanic Next"
echo -e "  ${GREEN}06${NC} Solarized Light     ${GREEN}16${NC} GitHub Dark"
echo -e "  ${GREEN}07${NC} Gruvbox Dark        ${GREEN}17${NC} Synthwave 84"
echo -e "  ${GREEN}08${NC} Gruvbox Light       ${GREEN}18${NC} Cyberpunk"
echo -e "  ${GREEN}09${NC} Tokyo Night         ${GREEN}19${NC} Rose Pine"
echo -e "  ${GREEN}10${NC} One Dark            ${GREEN}20${NC} Everforest Dark"
echo ""
echo -e "${BOLD}Installation Locations:${NC}"
echo -e "  ${BLUE}Profiles:${NC}        $PROFILES_DIR"
echo -e "  ${BLUE}Shaders:${NC}         $SHADERS_DIR"
echo -e "  ${BLUE}Scripts:${NC}         $SCRIPTS_DIR"
echo -e "  ${BLUE}Config:${NC}          $CONFIG_FILE"
echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${MAGENTA}Enjoy your new Ghostty setup! 👻${NC}"
echo ""
