#!/usr/bin/env bash
# gswitch.sh — Interactive fzf theme switcher for Ghostty
# Reads themes from themes.json and delegates assembly to ss.sh

set -euo pipefail

THEMES_JSON="$HOME/code/terminal-themer/themes.json"
COMPONENTS_DIR="$HOME/.config/ghostty/components"
SS_SCRIPT="$HOME/scripts/ss.sh"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

# Check dependencies
if ! command -v fzf &>/dev/null; then
    echo -e "${RED}Error: fzf is not installed${NC}"
    [[ "$OSTYPE" == "darwin"* ]] && echo -e "Install: ${YELLOW}brew install fzf${NC}" \
        || echo -e "Install: ${YELLOW}sudo dnf install fzf${NC}  or  ${YELLOW}sudo apt install fzf${NC}"
    exit 1
fi

[[ ! -f "$THEMES_JSON" ]] && { echo -e "${RED}themes.json not found at $THEMES_JSON${NC}"; exit 1; }
[[ ! -f "$SS_SCRIPT"   ]] && { echo -e "${RED}ss.sh not found at $SS_SCRIPT${NC}"; exit 1; }

# Build fzf entries from themes.json: "ID  Name  |  effects  |  font"
ENTRIES=$(python3 - "$THEMES_JSON" << 'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
for t in data['themes']:
    print(f"{t['id']:2}  {t['name']:<22}  |  {t['effects']:<20}  |  {t['font']}")
PYEOF
)

# Preview: show assembled component files for the selected theme
preview_cmd='
id=$(echo {} | awk "{print \$1}");
python3 - "'"$THEMES_JSON"'" "$id" << PYEOF
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
for t in data["themes"]:
    if str(t["id"]) == sys.argv[2]:
        print("Theme:   " + t["name"])
        print("Colors:  " + t["colors"])
        print("Font:    " + t["font"])
        print("Effects: " + t["effects"])
        print("Prompt:  " + t["prompt"])
        print("")
        break
PYEOF
colors=$(python3 -c "
import json
with open(\"'"$THEMES_JSON"'\") as f: d=json.load(f)
for t in d[\"themes\"]:
    if str(t[\"id\"]) == \"$id\":
        print(t[\"colors\"])
" 2>/dev/null)
[[ -f "'"$COMPONENTS_DIR"'/colors/${colors}.conf" ]] && cat "'"$COMPONENTS_DIR"'/colors/${colors}.conf"
'

SELECTED=$(echo "$ENTRIES" | fzf \
    --prompt="  Theme: " \
    --height=80% \
    --layout=reverse \
    --border=rounded \
    --preview="$preview_cmd" \
    --preview-window=right:45%:wrap \
    --header="  ↑↓ Navigate  |  Enter: Apply  |  Esc: Cancel  |  Tab: Preview" \
    --color="fg:#d0d0d0,fg+:#ffffff,bg:#0d0d0d,bg+:#1a1a1a,border:#333333" \
    --color="hl:#5fd7ff,hl+:#00afff,info:#585b70,marker:#a6e3a1" \
    --color="prompt:#89b4fa,spinner:#f38ba8,pointer:#cba6f7,header:#6c7086" \
    --pointer="▶" \
    --marker="✓" \
    --ansi)

[[ -z "$SELECTED" ]] && { echo -e "${YELLOW}Cancelled${NC}"; exit 0; }

THEME_ID=$(echo "$SELECTED" | awk '{print $1}' | tr -d ' ')
bash "$SS_SCRIPT" "$THEME_ID"
