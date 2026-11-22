#!/usr/bin/env bash
# ss.sh — Ghostty theme switcher
#
# Usage:
#   ss                             list all themes
#   ss <number>                    switch to theme by number (assembles from components)
#   ss --colors <name>             override color component only
#   ss --font <name>               override font component only
#   ss --effects <name>            override effects component only
#   ss --prompt <name>             switch Starship prompt only
#   ss --list-colors               list available color components
#   ss --list-fonts                list available font components
#   ss --list-effects              list available effects components
#   ss --list-prompts              list available prompt components
#   ss --current                   show what components are active

set -euo pipefail

GHOSTTY_DIR="$HOME/.config/ghostty"
PROFILES_DIR="$GHOSTTY_DIR/profiles"
COMPONENTS_DIR="$GHOSTTY_DIR/components"
CONFIG_FILE="$GHOSTTY_DIR/config"
STARSHIP_CONFIG="$HOME/.config/starship.toml"
THEMES_JSON="$HOME/code/terminal-themer/themes.json"
STATE_FILE="$GHOSTTY_DIR/.active-components"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

reload_ghostty() {
    if pkill -USR2 ghostty 2>/dev/null; then return 0; fi
    osascript -e 'tell application "System Events" to tell process "ghostty" to keystroke "r" using {command down, shift down}' 2>/dev/null || true
}

assemble_config() {
    local colors=$1 font=$2 effects=$3
    local colors_file="$COMPONENTS_DIR/colors/${colors}.conf"
    local font_file="$COMPONENTS_DIR/fonts/${font}.conf"
    local effects_file="$COMPONENTS_DIR/effects/${effects}.conf"

    for f in "$colors_file" "$font_file" "$effects_file"; do
        if [[ ! -f "$f" ]]; then
            echo -e "${RED}Error: component not found: $f${NC}"
            echo -e "Run ${YELLOW}ss --list-colors${NC} / ${YELLOW}ss --list-fonts${NC} / ${YELLOW}ss --list-effects${NC} to see available options."
            exit 1
        fi
    done

    cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%s)" 2>/dev/null || true

    {
        echo "# Assembled by ss — $(date)"
        echo "# colors: $colors | font: $font | effects: $effects"
        echo ""
        cat "$COMPONENTS_DIR/base.conf"
        echo ""
        cat "$colors_file"
        echo ""
        cat "$font_file"
        echo ""
        cat "$effects_file"
    } > "$CONFIG_FILE"

    echo "$colors $font $effects" > "$STATE_FILE"
}

apply_prompt() {
    local prompt_name=$1
    local prompt_file="$COMPONENTS_DIR/prompts/${prompt_name}.toml"

    [[ ! -f "$prompt_file" ]] && return 0  # silently skip if not found
    [[ ! -f "$STARSHIP_CONFIG"  ]] && return 0

    cp "$STARSHIP_CONFIG" "$STARSHIP_CONFIG.backup.$(date +%s)" 2>/dev/null || true

    # Replace the palette line in starship.toml
    if grep -q "^palette = " "$STARSHIP_CONFIG" 2>/dev/null; then
        sed -i "s|^palette = .*|palette = '$prompt_name'|" "$STARSHIP_CONFIG"
    fi

    # Upsert the palette definition block
    local palette_block
    palette_block=$(grep -A 20 "^\[palettes\.$prompt_name\]" "$prompt_file" 2>/dev/null || true)
    if [[ -n "$palette_block" ]]; then
        # Remove old block for this palette if it exists, then append new one
        python3 - "$STARSHIP_CONFIG" "$prompt_name" "$prompt_file" << 'PYEOF'
import sys, re
config_path, palette_name, palette_file = sys.argv[1], sys.argv[2], sys.argv[3]

with open(config_path) as f:
    content = f.read()

with open(palette_file) as f:
    palette_src = f.read()

# Extract just the [palettes.name] block from source
m = re.search(r'(\[palettes\.' + re.escape(palette_name) + r'\][^\[]*)', palette_src, re.DOTALL)
if not m:
    sys.exit(0)
new_block = m.group(1).strip()

# Remove existing block from config
content = re.sub(r'\[palettes\.' + re.escape(palette_name) + r'\][^\[]*', '', content, flags=re.DOTALL)
content = content.rstrip() + '\n\n' + new_block + '\n'

with open(config_path, 'w') as f:
    f.write(content)
PYEOF
    fi
}

get_theme_component() {
    local id=$1 field=$2
    python3 -c "
import json, sys
with open('$THEMES_JSON') as f:
    data = json.load(f)
for t in data['themes']:
    if t['id'] == $id:
        print(t.get('$field',''))
        sys.exit(0)
sys.exit(1)
" 2>/dev/null || echo ""
}

show_profiles() {
    echo -e "${BOLD}${BLUE}Ghostty Themes${NC}"
    echo ""
    python3 - "$THEMES_JSON" << 'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
for t in data['themes']:
    print(f"  \033[32m{t['id']:2}\033[0m  {t['name']:<22} \033[36m{t['effects']:<20}\033[0m {t['font']}")
PYEOF
    echo ""
    echo -e "  ${YELLOW}ss <n>${NC}                    switch to theme"
    echo -e "  ${YELLOW}ss --colors X${NC}             swap color palette only"
    echo -e "  ${YELLOW}ss --effects X${NC}            swap shader effects only"
    echo -e "  ${YELLOW}ss --font X${NC}               swap font only"
    echo -e "  ${YELLOW}ss --prompt X${NC}             swap Starship prompt only"
    echo -e "  ${YELLOW}gswitch${NC}                   interactive fuzzy picker"
}

list_components() {
    local dir=$1 label=$2 ext=$3
    echo -e "${BOLD}${BLUE}Available $label components:${NC}"
    ls "$COMPONENTS_DIR/$dir/"*."$ext" 2>/dev/null | \
        xargs -I{} basename {} ."$ext" | \
        sort | awk '{printf "  \033[32m%-30s\033[0m\n", $0}'
}

show_current() {
    if [[ -f "$STATE_FILE" ]]; then
        read -r colors font effects < "$STATE_FILE"
        echo -e "${BOLD}Active components:${NC}"
        echo -e "  colors:  ${GREEN}$colors${NC}"
        echo -e "  font:    ${GREEN}$font${NC}"
        echo -e "  effects: ${GREEN}$effects${NC}"
    else
        echo -e "${YELLOW}No component state found. Run ss <number> to set a theme.${NC}"
    fi
}

# ── Parse arguments ───────────────────────────────────────────────────────────

[[ $# -eq 0 ]] && { show_profiles; exit 0; }

OVERRIDE_COLORS="" OVERRIDE_FONT="" OVERRIDE_EFFECTS="" OVERRIDE_PROMPT=""
PROFILE_NUM=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --list-colors)   list_components "colors"  "color"   "conf"; exit 0 ;;
        --list-fonts)    list_components "fonts"   "font"    "conf"; exit 0 ;;
        --list-effects)  list_components "effects" "effects" "conf"; exit 0 ;;
        --list-prompts)  list_components "prompts" "prompt"  "toml"; exit 0 ;;
        --current)       show_current; exit 0 ;;
        --colors)  OVERRIDE_COLORS="$2";  shift 2 ;;
        --font)    OVERRIDE_FONT="$2";    shift 2 ;;
        --effects) OVERRIDE_EFFECTS="$2"; shift 2 ;;
        --prompt)  OVERRIDE_PROMPT="$2";  shift 2 ;;
        [0-9]*)    PROFILE_NUM="$1";      shift ;;
        *) echo -e "${RED}Unknown option: $1${NC}"; exit 1 ;;
    esac
done

# ── Prompt-only mode ──────────────────────────────────────────────────────────
if [[ -z "$PROFILE_NUM" && -z "$OVERRIDE_COLORS" && -z "$OVERRIDE_FONT" && -z "$OVERRIDE_EFFECTS" && -n "$OVERRIDE_PROMPT" ]]; then
    apply_prompt "$OVERRIDE_PROMPT"
    echo -e "${GREEN}✓${NC} Prompt switched to ${BLUE}$OVERRIDE_PROMPT${NC}"
    exit 0
fi

# ── Resolve base components ───────────────────────────────────────────────────
if [[ -n "$PROFILE_NUM" ]]; then
    COLORS=$(get_theme_component "$PROFILE_NUM" "colors")
    FONT=$(get_theme_component   "$PROFILE_NUM" "font")
    EFFECTS=$(get_theme_component "$PROFILE_NUM" "effects")
    PROMPT=$(get_theme_component "$PROFILE_NUM" "prompt")
    NAME=$(get_theme_component   "$PROFILE_NUM" "name")

    [[ -z "$COLORS" ]] && { echo -e "${RED}Theme $PROFILE_NUM not found${NC}"; show_profiles; exit 1; }
else
    # Component override without a profile number — load current state as base
    if [[ -f "$STATE_FILE" ]]; then
        read -r COLORS FONT EFFECTS < "$STATE_FILE"
        PROMPT=""
    else
        echo -e "${RED}No active theme. Run ss <number> first.${NC}"; exit 1
    fi
fi

# Apply any overrides
[[ -n "$OVERRIDE_COLORS"  ]] && COLORS="$OVERRIDE_COLORS"
[[ -n "$OVERRIDE_FONT"    ]] && FONT="$OVERRIDE_FONT"
[[ -n "$OVERRIDE_EFFECTS" ]] && EFFECTS="$OVERRIDE_EFFECTS"
[[ -n "$OVERRIDE_PROMPT"  ]] && PROMPT="$OVERRIDE_PROMPT"

# ── Assemble and apply ────────────────────────────────────────────────────────
assemble_config "$COLORS" "$FONT" "$EFFECTS"

if [[ -n "${NAME:-}" ]]; then
    echo -e "${GREEN}✓${NC} Switched to ${BOLD}$NAME${NC} (colors=${CYAN}$COLORS${NC} font=${CYAN}$FONT${NC} effects=${CYAN}$EFFECTS${NC})"
else
    echo -e "${GREEN}✓${NC} Applied components: colors=${CYAN}$COLORS${NC} font=${CYAN}$FONT${NC} effects=${CYAN}$EFFECTS${NC}"
fi

[[ -n "${PROMPT:-}" ]] && apply_prompt "$PROMPT" && echo -e "${GREEN}✓${NC} Prompt: ${CYAN}$PROMPT${NC}"

reload_ghostty
echo -e "${GREEN}✓${NC} Config reloaded"
