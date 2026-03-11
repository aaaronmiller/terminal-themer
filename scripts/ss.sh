#!/usr/bin/env bash

# ss.sh - Direct profile switcher for Ghostty terminal
# Usage: ss <number>
# Example: ss 5

set -euo pipefail

PROFILES_DIR="$HOME/.config/ghostty/profiles"
CONFIG_FILE="$HOME/.config/ghostty/config"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display available profiles
show_profiles() {
    echo -e "${BLUE}Available Ghostty Profiles:${NC}"
    echo ""

    if [[ ! -d "$PROFILES_DIR" ]]; then
        echo -e "${RED}Error: Profiles directory not found at $PROFILES_DIR${NC}"
        exit 1
    fi

    local count=0
    for profile in "$PROFILES_DIR"/profile_*.conf; do
        if [[ -f "$profile" ]]; then
            # Extract profile number and name
            local basename=$(basename "$profile")
            local num=$(echo "$basename" | sed -n 's/profile_\([0-9]*\)_.*/\1/p')
            local name=$(echo "$basename" | sed -n 's/profile_[0-9]*_\(.*\)\.conf/\1/p' | tr '_' ' ')

            printf "  ${GREEN}%2s${NC}  %s\n" "$num" "$name"
            ((count++))
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo -e "${RED}No profiles found in $PROFILES_DIR${NC}"
        exit 1
    fi

    echo ""
    echo -e "${YELLOW}Usage: ss <number>${NC}"
    echo -e "Example: ${YELLOW}ss 5${NC} to switch to profile 5"
}

# Function to reload Ghostty using AppleScript
reload_ghostty() {
    osascript -e 'tell application "System Events"' \
              -e 'tell process "ghostty"' \
              -e 'keystroke "r" using {command down, shift down}' \
              -e 'end tell' \
              -e 'end tell' 2>/dev/null || true
}

# Main logic
if [[ $# -eq 0 ]]; then
    show_profiles
    exit 0
fi

PROFILE_NUM="$1"

# Pad the profile number with leading zero if needed
PROFILE_NUM_PADDED=$(printf "%02d" "$PROFILE_NUM")

# Find the profile file
PROFILE_FILE=$(find "$PROFILES_DIR" -name "profile_${PROFILE_NUM_PADDED}_*.conf" -print -quit)

if [[ -z "$PROFILE_FILE" ]]; then
    echo -e "${RED}Error: Profile $PROFILE_NUM not found${NC}"
    echo ""
    show_profiles
    exit 1
fi

# Extract the profile name for display
PROFILE_NAME=$(basename "$PROFILE_FILE" | sed -n 's/profile_[0-9]*_\(.*\)\.conf/\1/p' | tr '_' ' ')

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
