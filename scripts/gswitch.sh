#!/usr/bin/env bash

# gswitch.sh - Interactive fzf-based profile switcher for Ghostty terminal
# Usage: gswitch

set -euo pipefail

PROFILES_DIR="$HOME/.config/ghostty/profiles"
CONFIG_FILE="$HOME/.config/ghostty/config"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo -e "${RED}Error: fzf is not installed${NC}"
    echo -e "Please install fzf first: ${YELLOW}brew install fzf${NC}"
    exit 1
fi

# Check if profiles directory exists
if [[ ! -d "$PROFILES_DIR" ]]; then
    echo -e "${RED}Error: Profiles directory not found at $PROFILES_DIR${NC}"
    exit 1
fi

# Function to reload Ghostty using AppleScript
reload_ghostty() {
    osascript -e 'tell application "System Events"' \
              -e 'tell process "ghostty"' \
              -e 'keystroke "r" using {command down, shift down}' \
              -e 'end tell' \
              -e 'end tell' 2>/dev/null || true
}

# Build the profile list for fzf
declare -a profile_list
declare -A profile_map

for profile in "$PROFILES_DIR"/profile_*.conf; do
    if [[ -f "$profile" ]]; then
        local basename=$(basename "$profile")
        local num=$(echo "$basename" | sed -n 's/profile_\([0-9]*\)_.*/\1/p')
        local name=$(echo "$basename" | sed -n 's/profile_[0-9]*_\(.*\)\.conf/\1/p' | tr '_' ' ')

        # Create display string
        local display=$(printf "%2s  %s" "$num" "$name")
        profile_list+=("$display")
        profile_map["$display"]="$profile"
    fi
done

# Check if we have any profiles
if [[ ${#profile_list[@]} -eq 0 ]]; then
    echo -e "${RED}No profiles found in $PROFILES_DIR${NC}"
    exit 1
fi

# Show the fzf selector with preview
SELECTED=$(printf '%s\n' "${profile_list[@]}" | \
    fzf --prompt="Select Ghostty Profile: " \
        --height=60% \
        --layout=reverse \
        --border \
        --preview="cat ${PROFILES_DIR}/profile_{1}_*.conf 2>/dev/null | head -30" \
        --preview-window=right:60%:wrap \
        --header="↑↓ Navigate | Enter: Select | Esc: Cancel" \
        --color="fg:#d0d0d0,fg+:#ffffff,bg:#1a1a1a,bg+:#2a2a2a" \
        --color="hl:#5fd7ff,hl+:#00afff,info:#afaf87,marker:#87ff00" \
        --color="prompt:#87af00,spinner:#af87ff,pointer:#ff5f87,header:#87afaf" \
        --pointer="▶" \
        --marker="✓")

# Check if user cancelled
if [[ -z "$SELECTED" ]]; then
    echo -e "${YELLOW}Selection cancelled${NC}"
    exit 0
fi

# Get the profile file path
PROFILE_FILE="${profile_map[$SELECTED]}"

if [[ -z "$PROFILE_FILE" ]] || [[ ! -f "$PROFILE_FILE" ]]; then
    echo -e "${RED}Error: Selected profile not found${NC}"
    exit 1
fi

# Extract profile info for display
PROFILE_NUM=$(echo "$SELECTED" | awk '{print $1}')
PROFILE_NAME=$(echo "$SELECTED" | sed 's/^[0-9]*  //')

# Backup current config if it exists
if [[ -f "$CONFIG_FILE" ]]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%s)" 2>/dev/null || true
fi

# Copy the profile to config
if cp "$PROFILE_FILE" "$CONFIG_FILE"; then
    echo -e "${GREEN}✓${NC} Switched to profile ${GREEN}$PROFILE_NUM${NC}: ${BLUE}$PROFILE_NAME${NC}"

    # Reload Ghostty
    reload_ghostty
    echo -e "${GREEN}✓${NC} Configuration reloaded"
else
    echo -e "${RED}Error: Failed to copy profile to $CONFIG_FILE${NC}"
    exit 1
fi
