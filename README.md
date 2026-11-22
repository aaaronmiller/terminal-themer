# Ghostty Terminal Themer

A cross-platform theme management system for the [Ghostty terminal emulator](https://ghostty.org). Switch between 21 hand-crafted profiles — each built from independently swappable **color palettes**, **fonts**, **shader stacks**, and **Starship prompts** — instantly, without restarting your terminal.

Includes a **Claude Code skill** (`/new-theme`) that generates new themes from a concept or mood using color theory algorithms, intelligent multi-shader layering, italic font cross-pairing, and background image composition.

---

## Features

- **21 Curated Profiles** — color palettes, matched fonts, layered shader effects, and Starship prompt palettes
- **Modular Component System** — colors, fonts, effects, and prompts are independent and freely mixable
- **Instant Live Reload** — theme switches apply immediately via `SIGUSR2`; no terminal restart required
- **Multi-Shader Layering** — 2–3 GLSL shaders composited per profile (background ambiance → screen polish → cursor FX)
- **Dual Switch Methods**:
  - `ss <number>` — direct switch by profile number
  - `gswitch` — interactive fzf fuzzy-finder with live preview
- **Component Mixing** — swap any single element while keeping the rest (`ss --colors nord --effects galaxy`)
- **Cross-Platform** — Linux (Fedora, Debian/Ubuntu) and macOS; auto-detects OS at install
- **Claude Code `/new-theme` Skill** — AI-assisted theme generation with full component output
- **Safe Backups** — timestamped config backup before every switch

---

## Profiles

| # | Theme | Style | Shader Stack |
|---|-------|-------|-------------|
| 01 | Catppuccin Latte | Light, pastel | — |
| 02 | Catppuccin Mocha | Cozy dark | animated-gradient |
| 03 | Nord | Arctic blue | — |
| 04 | Dracula | Vibrant dark | galaxy |
| 05 | Solarized Dark | Precision dark | — |
| 06 | Solarized Light | Precision light | — |
| 07 | Gruvbox Dark | Retro warm | bettercrt |
| 08 | Gruvbox Light | Retro warm light | — |
| 09 | Tokyo Night | Night city | bloom |
| 10 | One Dark | Classic Atom | — |
| 11 | Monokai Pro | Professional dark | glitchy |
| 12 | Ayu Dark | Elegant dark | starfield |
| 13 | Material Ocean | Material design | water |
| 14 | Palenight | Soft purple | — |
| 15 | Oceanic Next | Deep blue | underwater |
| 16 | GitHub Dark | Official GitHub | — |
| 17 | Synthwave 84 | 80s neon | retro-terminal |
| 18 | Cyberpunk | Neon dystopia | inside-the-matrix |
| 19 | Rose Pine | Organic aurora | animated-gradient |
| 20 | Everforest Dark | Forest green | smoke-and-ghost |
| **21** | **Obsidian Galaxy** | **Void + galaxy shader** | **galaxy** |

*Theme 21: Catppuccin Mocha palette, void-black background, galaxy shader, JetBrainsMono — designed for AI CLI output and long sessions.*

---

## Installation

### Prerequisites

- [Ghostty terminal](https://ghostty.org)
- `git`
- `fzf` (auto-installed by `install.sh` if not present)
  - Linux: `sudo dnf install fzf` / `sudo apt install fzf`
  - macOS: `brew install fzf`

### Quick Install

```bash
git clone https://github.com/yourusername/terminal-themer.git ~/code/terminal-themer
cd ~/code/terminal-themer
./install.sh
source ~/.zshrc
```

The installer:
- Detects your OS (Linux / macOS) and installs `fzf` with the right package manager
- Backs up your existing `~/.config/ghostty/config`
- Installs all 21 profiles to `~/.config/ghostty/profiles/`
- Installs the component library to `~/.config/ghostty/components/`
- Clones the [ghostty-shaders](https://github.com/hackr-sh/ghostty-shaders) repo
- Installs `ss` and `gswitch` to `~/scripts/`
- Adds shell aliases to `~/.zshrc`

---

## Usage

### Switch by number

```bash
ss        # list all profiles
ss 9      # switch to Tokyo Night
ss 21     # switch to Obsidian Galaxy
```

### Interactive fuzzy finder

```bash
gswitch   # browse with fzf, live preview, fuzzy search
```

Both methods assemble a config from components, write it to `~/.config/ghostty/config`, and send `SIGUSR2` to the running Ghostty process — the theme applies instantly in your current window.

### Mix and match components

You can override any single component while keeping the rest of your current theme:

```bash
# Swap color palette only
ss --colors tokyo_night

# Swap shader effects only
ss --effects galaxy

# Swap font only
ss --font victor-mono-13

# Swap Starship prompt palette only
ss --prompt rose-pine

# Combine multiple overrides
ss --colors catppuccin_mocha --effects cosmic-fire

# Switch a full theme then tweak effects
ss 9 && ss --effects retro-crt
```

### Discover available components

```bash
ss --list-colors     # all color palettes
ss --list-fonts      # all font configurations
ss --list-effects    # all shader effect stacks
ss --list-prompts    # all Starship prompt palettes
ss --current         # show what's active right now
```

---

## Modular Component System

Every theme is assembled from four independent component layers stored in `~/.config/ghostty/components/`:

```
components/
├── base.conf          ← shared settings (window, keybinds, scrollback)
├── colors/            ← 21 color palettes (background, foreground, ANSI 0–15)
│   ├── catppuccin_mocha.conf
│   ├── tokyo_night.conf
│   ├── nord.conf
│   └── ...
├── fonts/             ← 14 font configurations (family, size, line height, italic pairing)
│   ├── jetbrains-mono-nf-12.conf
│   ├── victor-mono-13.conf
│   ├── cascadia-code-13.conf   ← pairs with VictorMono italic
│   └── ...
├── effects/           ← 17 shader stacks (1–3 GLSL shaders composited)
│   ├── none.conf
│   ├── galaxy.conf
│   ├── bloom.conf
│   ├── cosmic-fire.conf        ← galaxy + bloom + cursor_blaze
│   ├── retro-crt.conf          ← tft + bettercrt + bloom
│   ├── underwater.conf         ← underwater + smoke-and-ghost + bloom
│   └── ...
└── prompts/           ← 21 Starship palette definitions
    ├── tokyo-night.toml
    ├── catppuccin-mocha.toml
    └── ...
```

When you run `ss 9`, the script:

1. Reads `themes.json` to find Tokyo Night's components: `colors=tokyo_night`, `font=victor-mono-13`, `effects=bloom`, `prompt=tokyo-night`
2. Concatenates `base.conf + colors/tokyo_night.conf + fonts/victor-mono-13.conf + effects/bloom.conf` into `~/.config/ghostty/config`
3. Applies the Starship prompt palette to `~/.config/starship.toml`
4. Sends `SIGUSR2` to reload Ghostty live

The active component state is saved to `~/.config/ghostty/.active-components`, which allows partial overrides (`ss --effects galaxy` reads this to know what colors and font to keep).

### Multi-Shader Layering

Effect components can stack 2–3 GLSL shaders. Each shader receives the previous output as `iChannel0` — order is intentional:

```
galaxy.glsl → bloom.glsl → cursor_blaze.glsl
   [bg FX]  →  [glow]   →   [cursor trail]
```

All effects use `background-opacity-cells = false` so opacity applies to the canvas only, keeping text crisp through heavy shader stacks.

---

## Creating New Themes with Claude Code

This repo includes a Claude Code skill that designs new themes from scratch using:

- **Color theory** — complementary, triadic, analogous, split-complementary, or monochromatic; derives all 16 ANSI palette colors algorithmically from a seed hue
- **Shader layer stacks** — 2–3 GLSL shaders composited in order, with opacity/performance modeling
- **Typography** — font selection by personality, with optional cursive italic cross-pairing (`font-family-italic`)
- **Background image** — mirroring or contrasting strategy with AI image generation prompt included
- **Syntax highlight validation** — checks all 6 critical color pairs before finalizing
- **Full component output** — generates all 4 component files + assembled profile + updates `themes.json`

### Setup (one time)

Copy the skill to your global Claude commands:

```bash
cp .claude/commands/new-theme.md ~/.claude/commands/new-theme.md
```

Or keep it project-local — it's already in `.claude/commands/` and will load automatically when Claude Code is opened in this directory.

### Usage

```
/new-theme bioluminescent deep sea
/new-theme brutalist concrete noir
/new-theme sakura at dusk
/new-theme tokyo midnight rain
```

Claude works through 8 steps: color derivation → shader stack → typography → background image → generate all component files → register in `themes.json` → offer to switch live → present a design brief.

### What it produces

```
┌─────────────────────────────────────────────────────────┐
│  THEME: Bioluminescent Deep Sea                         │
│  Concept: Cold abyssal dark with glowing teal accents   │
├─────────────────────────────────────────────────────────┤
│  COLOR THEORY                                           │
│  Approach: Split-complementary (195°, 165°, 345°)       │
│  Seed: 195° teal — background #080f12, fg #dff2f0       │
├─────────────────────────────────────────────────────────┤
│  SHADERS                                                │
│  L1: underwater — caustic light through water           │
│  L2: smoke-and-ghost — drifting bioluminescent mist     │
│  L3: bloom — diffuses glow into surrounding text        │
├─────────────────────────────────────────────────────────┤
│  TYPOGRAPHY                                             │
│  Regular: Iosevka Nerd Font 12pt / 32%                  │
│  Italic:  VictorMono Nerd Font — fluid, organic feel    │
│  Cursor:  block_hollow / opacity 0.85                   │
└─────────────────────────────────────────────────────────┘
```

Files generated:

```
~/.config/ghostty/components/colors/bioluminescent_deep_sea.conf
~/.config/ghostty/components/fonts/iosevka-nf-12.conf
~/.config/ghostty/components/effects/bioluminescent-deep-sea.conf
~/.config/ghostty/components/prompts/bioluminescent-deep-sea.toml
~/.config/ghostty/profiles/profile_22_Bioluminescent_Deep_Sea.conf
themes.json  ← manifest updated
```

---

## How It Works

### Architecture

```
~/code/terminal-themer/           ← this repo
├── themes.json                   ← component manifest for all themes
├── profiles/                     ← 21 assembled .conf files (source of truth)
├── components/                   ← component source files (synced to ~/.config)
│   ├── base.conf
│   ├── colors/
│   ├── fonts/
│   ├── effects/
│   └── prompts/
├── scripts/
│   ├── ss.sh                     ← direct switcher + component mixer
│   └── gswitch.sh                ← fzf interactive switcher
├── install.sh
└── .claude/commands/new-theme.md ← Claude Code skill

~/.config/ghostty/               ← active Ghostty config
├── config                        ← assembled by ss (do not edit directly)
├── components/                   ← installed copy of component library
│   ├── base.conf
│   ├── colors/
│   ├── fonts/
│   ├── effects/
│   └── prompts/
├── profiles/                     ← installed profile .conf files
├── shaders/                      ← GLSL shader library (ghostty-shaders repo)
└── .active-components            ← current color/font/effects state

~/scripts/
├── ss.sh                         ← aliased as `ss`
└── gswitch.sh                    ← aliased as `gswitch`
```

### themes.json

Each theme is a component manifest:

```json
{
  "id": 9,
  "name": "Tokyo Night",
  "colors": "tokyo_night",
  "font": "victor-mono-13",
  "effects": "bloom",
  "prompt": "tokyo-night"
}
```

This drives both `ss <number>` (component lookup) and `gswitch` (fzf display + preview).

---

## Customization

### Mix components on the fly

```bash
# Try a different shader on your current theme
ss --effects cosmic-fire

# Use Nord colors with Tokyo Night font and galaxy shader
ss --colors nord --font victor-mono-13 --effects galaxy

# See what's active, then tweak
ss --current
ss --font berkeley-mono-14
```

### Create a new profile manually

```bash
# Copy an existing color component as a starting point
cp ~/.config/ghostty/components/colors/nord.conf \
   ~/.config/ghostty/components/colors/my_palette.conf
# Edit my_palette.conf, then apply:
ss --colors my_palette
```

### Use the `/new-theme` skill

For a fully designed theme with color theory, shader layering, and typography, see [Creating New Themes with Claude Code](#creating-new-themes-with-claude-code).

---

## Troubleshooting

**`ss: command not found`**
```bash
source ~/.zshrc
```

**`fzf: command not found`**
```bash
# Fedora/RHEL
sudo dnf install fzf
# Debian/Ubuntu
sudo apt install fzf
# macOS
brew install fzf
```

**Theme switches but doesn't reload**

Ghostty catches `SIGUSR2` for config reload. If it doesn't apply:
```bash
pkill -USR2 ghostty
# or press Super+Shift+R (Linux) / Cmd+Shift+R (macOS) in Ghostty
```

**`ss --current` shows nothing**

Run `ss <number>` at least once to initialize the component state file.

**Shader not working**

Verify the shader file exists:
```bash
ls ~/.config/ghostty/shaders/
```

If the shaders directory is missing:
```bash
git clone https://github.com/hackr-sh/ghostty-shaders.git ~/.config/ghostty/shaders
```

**Component file not found**

If `ss` reports a missing component, reinstall the component library:
```bash
cp -rf ~/code/terminal-themer/components ~/.config/ghostty/
```

---

## Credits

- **Ghostty** — [Mitchell Hashimoto](https://github.com/mitchellh)
- **Shaders** — [hackr-sh/ghostty-shaders](https://github.com/hackr-sh/ghostty-shaders)
- **fzf** — [junegunn/fzf](https://github.com/junegunn/fzf)
- **Nerd Fonts** — [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts)

---

## License

MIT
