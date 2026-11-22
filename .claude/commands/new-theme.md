---
description: Design a complete Ghostty terminal theme from a concept or mood — applies color theory to derive all 16 ANSI palette colors, designs a multi-shader stack with opacity modeling, selects typography with italic cross-pairing, and specifies a background image. Writes the finished .conf file and optionally switches to it live. Usage: /new-theme <concept, mood, or name>
---

You are a world-class terminal theme designer. Your task is to create a new Ghostty terminal theme profile based on the concept: **$ARGUMENTS**

If no concept was provided, ask the user for a theme name, mood, or inspiration before proceeding.

---

## STEP 1 — FIND THE NEXT PROFILE NUMBER

Run this command to determine the next available profile number:

```bash
ls ~/.config/ghostty/profiles/profile_*.conf 2>/dev/null | sed 's/.*profile_\([0-9]*\)_.*/\1/' | sort -n | tail -1
```

The new profile number = (result + 1), zero-padded to 2 digits (e.g., 22 → `22`).

Also run:
```bash
ls ~/.config/ghostty/shaders/*.glsl | xargs -I{} basename {} .glsl | sort
```
to confirm which shaders are available.

---

## STEP 2 — COLOR THEORY ANALYSIS

Based on the concept **$ARGUMENTS**, choose ONE of the following color theory approaches and explain why it fits:

### Available Approaches

| Theory | Structure | Best For |
|--------|-----------|----------|
| **Complementary** | 2 hues 180° apart | High contrast, neon, cyberpunk |
| **Split-Complementary** | 1 base + 2 flanking (150°/210°) | Vibrant but balanced |
| **Triadic** | 3 hues 120° apart | Dynamic, rich syntax highlighting |
| **Analogous** | 3-5 adjacent hues (20-40° apart) | Cozy, harmonious, low fatigue |
| **Tetradic/Square** | 4 hues 90° apart | Complex, maximum variety |
| **Monochromatic** | 1 hue, varied saturation/lightness | Minimal, focused, professional |

### Concrete Derivation Algorithm (work in HSL space)

**Step A — Choose your seed hue and theory hues:**
- Complementary:       H, H+180°
- Split-Complementary: H, H+150°, H+210°
- Triadic:             H, H+120°, H+240°
- Analogous:           H, H+25°, H+50° (or H-25°, H-50°)
- Tetradic:            H, H+90°, H+180°, H+270°
- Monochromatic:       H only (vary S and L across slots)

Normalize all angles to 0–360°.

**Step B — Derive background, foreground, selection:**
```
background:    HSL(H, clamp(S×0.12, 5%, 18%), 10–14%)   // very dark, slight tint
foreground:    HSL(H, clamp(S×0.06, 2%,  8%), 87–92%)   // near-white, slight warmth
selection-bg:  HSL(H_dominant, S×0.40, 28–32%)
selection-fg:  same as foreground
cursor-color:  most saturated accent hue at S=80–90%, L=60–65%
```

**Step C — Map theory hues to the 6 ANSI accent slots:**
Distribute your theory hues so warm hues (red/orange/yellow range) cover slots 1 and 3, and cool hues (blue/cyan/green range) cover slots 2, 4, 6. Slot 5 (magenta/purple) bridges them.

Target for all accent colors: S = 55–75%, L = 58–65%
- Exception: **yellow/slot 3** → L = 63–70% (yellow reads dim at lower L)
- Exception: **blue/slot 4** → L = 50–58% (blue reads bright at lower L)
- Exception: **red/slot 1** → S = 65–80% (red needs high saturation to read as danger)

**Step D — Bright variants (slots 8–15):**
Same H and S as their base. Raise L by +15–20%. That's it.

**Step E — Neutral grays (slots 0, 7, 8, 15):**
```
palette 0  (dark gray):    HSL(H, 10–18%, 14–18%)   // slightly colored shadow
palette 7  (light gray):   HSL(H,  5–10%, 75–80%)   // muted near-white
palette 8  (bright black): HSL(H,  8–15%, 22–28%)   // dim text, comments
palette 15 (bright white): HSL(H,  3– 6%, 92–96%)   // brightest text
```

Show all derivation math explicitly. Then convert every value to 6-digit hex.

**Step F — Syntax highlight validation (required before finalizing):**

Mentally test these pairs and confirm each passes:

| Code context       | Colors in play           | Must pass                          |
|--------------------|--------------------------|-------------------------------------|
| Error message      | palette 1 on background  | Clearly red, high contrast         |
| Added line (diff)  | palette 2 on background  | Clearly green, distinct from cyan  |
| Warning / string   | palette 3 on background  | Yellow visible, not muddy          |
| Keyword            | palette 4 or 5           | Distinct from string color (3)     |
| Comment            | palette 8 on background  | Readable but clearly subordinate   |
| Search highlight   | selection-bg             | Visible but not eye-searing        |

If any row fails, adjust that color's L value (±5–8%) until it passes. Do not move on until all rows pass.

---

## STEP 3 — SHADER LAYER STACK

Design a 2–3 shader combination. Each shader feeds its output into the next as `iChannel0`, so order matters.

### Available Shader Categories

**Background / Ambiance** (Layer 1 — sets the atmosphere):
- `animated-gradient-shader` — slow atmospheric color wash
- `galaxy` — cosmic particle field
- `starfield` / `starfield-colors` — parallax star layers
- `underwater` — fluid caustic light
- `smoke-and-ghost` — drifting ethereal mist
- `gradient-background` — static tinted gradient
- `mnoise` — organic perlin noise

**Screen Polish / Glow** (Layer 2 — enhances visual depth):
- `bloom` — light diffusion/glow around bright elements *(almost always improves the result)*
- `glow-rgbsplit-twitchy` — chromatic aberration + RGB separation
- `dither` — ordered dithering, adds grain/texture
- `tft` — LCD subpixel matrix overlay
- `negative` — inversion effect

**Retro / CRT** (Layer 2 or standalone — complete aesthetic):
- `bettercrt` — scanlines + barrel distortion + phosphor glow
- `amber_crt` — warm amber phosphor screen
- `retro-terminal` — vintage green terminal look
- `in-game-crt` — arcade monitor style
- `crt` — minimal CRT

**Cursor / Interaction** (Layer 3 — reactive to user):
- `cursor_blaze` — fire trail following cursor
- `cursor_smear_fade` — motion blur ghost trail
- `spotlight` — soft spotlight that follows cursor

**Particle / Atmospheric** (use sparingly):
- `just-snow` — falling snow
- `sparks-from-fire` — rising embers
- `fireworks` / `fireworks-rockets` — celebration bursts
- `sin-interference` — sine wave interference pattern

**Distortion / Heavy FX** (bold aesthetic choices):
- `glitchy` — digital glitch corruption
- `drunkard` — wobbly screen warp
- `inside-the-matrix` / `matrix-hallway` — matrix rain
- `cubes` — 3D rotating cubes

### Proven Layering Combinations (reference)
- **Retro perfection**: `tft` → `bettercrt` → `bloom`
- **Trippy vintage**: `drunkard` → `retro-terminal` → `bloom`
- **Glitch art**: `glitchy` → `bettercrt` → `water` → `bloom`
- **Cosmic fire**: `galaxy` → `bloom` → `cursor_blaze`
- **Neon space**: `starfield-colors` → `glow-rgbsplit-twitchy` → `cursor_blaze`
- **Deep sea**: `underwater` → `smoke-and-ghost` → `bloom`
- **Soft atmospheric**: `animated-gradient-shader` → `bloom` → `cursor_smear_fade`
- **Ethereal**: `smoke-and-ghost` → `mnoise` → `bloom`

### Opacity × Shader Interaction Model

`background-opacity` and shader count compound each other. More shaders = more visual weight = requires higher base opacity to keep text readable:

| # Shaders | Shader weight   | `background-opacity` | `background-opacity-cells` |
|-----------|-----------------|----------------------|----------------------------|
| 0         | —               | 0.85–1.0             | true (default)             |
| 1         | Light (bloom, gradient, tft, dither) | 0.88–0.95 | **false** |
| 1         | Heavy (galaxy, matrix, underwater)   | 0.93–0.97 | **false** |
| 2         | Any mix         | 0.93–0.97            | **false**                  |
| 3         | Any mix         | 0.95–0.98            | **false**                  |

**`background-opacity-cells = false`** is almost always the right call when using shaders. It applies opacity only to the empty canvas — text cell backgrounds stay solid. Result: text is sharp, background glows. Without it, semi-transparent text backgrounds compete with shaders and create a murky smear.

### Shader Performance Tiers

Do not combine multiple Tier 3 shaders — they will impact performance:

- **Tier 1** (always smooth): `bloom`, `tft`, `dither`, `gradient-background`, `cursor_smear_fade`, `spotlight`, `bettercrt`, `retro-terminal`, `amber_crt`
- **Tier 2** (moderate GPU): `animated-gradient-shader`, `galaxy`, `starfield`, `starfield-colors`, `underwater`, `smoke-and-ghost`, `mnoise`, `glow-rgbsplit-twitchy`, `cursor_blaze`, `glitchy`
- **Tier 3** (GPU-heavy): `inside-the-matrix`, `matrix-hallway`, `cubes`, `gears-and-belts`, `cineShader-Lava`, `fireworks`, `fireworks-rockets`, `drunkard`

Good stacks: T1+T1+T2 ✓, T1+T2 ✓, T2+T1 ✓, T3 alone ✓
Avoid: T3+T2 ⚠, T3+T3 ✗

### Shader Selection Rules
1. **Always verify** the shader files exist in `~/.config/ghostty/shaders/` before referencing them
2. The final layer should usually be a polish effect (bloom, glow, tft) — not a heavy distortion
3. Cursor effects work best as the last layer so they composite over everything
4. If using a heavy particle effect (matrix, fireworks, cubes), limit to 1 shader total
5. `bloom` alone as the only shader is valid and elegant for minimal themes

Justify each shader choice: how it complements the palette, what visual layer it contributes, and how the layers interact when composited.

> **Conflict or uncertainty?** If at any point you encounter an unresolved tension — two equally valid shader choices, a color that fails validation but fixing it breaks coherence, a font pairing that doesn't feel right — stop and invoke `/deliberative-refinement` (if available) to reason through the tradeoff before committing. It is better to pause and deliberate than to silently pick the worse option.

---

## STEP 4 — TYPOGRAPHY

Select font and sizing based on the theme's personality.

### Font Personality Guide

| Font | Character | Ligatures | Nerd Icons | Best With |
|------|-----------|-----------|------------|-----------|
| `JetBrainsMono Nerd Font` | Modern, geometric, readable | ✓ | ✓✓ | Most themes |
| `JetBrainsMono NF` | Compact variant | ✓ | ✓✓ | Dense info displays |
| `BerkeleyMono Nerd Font` | Elegant, literary | ✓ | ✓✓ | Warm/cozy/artistic themes |
| `FiraCode Nerd Font` | Developer-focused, clean | ✓✓ | ✓ | Professional/minimal |
| `CaskaydiaCove Nerd Font` | Microsoft modern (Cascadia Code) | ✓✓ | ✓✓ | Modern/clean |
| `VictorMono Nerd Font` | Distinctive cursive italics | ✓ | ✓ | Creative/expressive |
| `Iosevka Nerd Font` | Tall, slim, compact | ✓✓ | ✓✓ | Technical/minimal |
| `IosevkaTerm Nerd Font` | Iosevka optimized for terminals | ✓✓ | ✓✓ | High-density |
| `Hack Nerd Font` | Neutral, universal | – | ✓✓ | When unsure |
| `Mononoki Nerd Font` | Cute, rounded | – | ✓ | Light/playful themes |
| `UbuntuMono Nerd Font` | Friendly, Linux-native | – | ✓ | System-native feel |
| `3270 Nerd Font` | IBM mainframe nostalgia | – | ✓ | Retro/terminal aesthetic |

### Sizing Guidelines
- `font-size`: 11–14pt. Smaller (11–12) for dense/professional. Larger (13–14) for showcase/artistic.
- `adjust-cell-height`: 25–40%. Lower = compact. Higher = airy/spacious.
- `adjust-icon-height`: Optional, 80–100% if Nerd Font icons appear over/undersized.
- `font-feature`: Include `+liga` for fonts with ligature support.

### Italic Font Cross-Pairing (high visual impact, often overlooked)

Ghostty supports a separate font for italic text. In code, comments, docstrings, and type annotations all render italic — meaning a cursive italic font creates striking visual contrast while keeping regular code clean and geometric.

```
font-family-italic      = "VictorMono Nerd Font"
font-family-bold-italic = "VictorMono Nerd Font"
```

**Pairing guide:**

| Regular (body)              | Italic (accent)              | Character                      |
|-----------------------------|------------------------------|--------------------------------|
| JetBrainsMono Nerd Font     | VictorMono Nerd Font         | Professional backbone + flair  |
| FiraCode Nerd Font          | VictorMono Nerd Font         | Developer precision + warmth   |
| Iosevka Nerd Font           | Iosevka Nerd Font (Oblique)  | Ultra-consistent minimal       |
| BerkeleyMono Nerd Font      | VictorMono Nerd Font         | Literary, editorial richness   |
| CaskaydiaCove Nerd Font     | VictorMono Nerd Font         | Modern clean + expressive      |
| 3270 Nerd Font              | 3270 Nerd Font               | Pure retro (no cross-pairing)  |

If keeping a single font, at minimum set `font-style-italic = "Italic"` explicitly.

### Cursor Style Selection

Choose based on theme personality — do not default to `block` blindly:

| Style         | Best for                                           |
|---------------|----------------------------------------------------|
| `block`       | Classic dark themes; bold, high visibility         |
| `bar`         | Minimal, light, or modern themes; unobtrusive      |
| `underline`   | Retro/CRT themes; matches the aesthetic            |
| `block_hollow`| Dark atmospheric themes; elegant, less heavy       |

- `cursor-style-blink = false` for professional/static themes; `true` for animated or retro themes
- `cursor-opacity = 0.85–1.0`. Slightly transparent (0.85) adds elegance to atmospheric themes

---

## STEP 5 — BACKGROUND IMAGE COMPOSITION

Design a background image concept that either **mirrors** or **thoughtfully contrasts** the theme palette.

Choose one compositional strategy:

**A) Color Mirror** — Image uses the same hue family as the theme. Creates unity.
Example: A dark teal theme → deep ocean photograph, heavily desaturated/tinted teal.

**B) Warm/Cool Contrast** — Cool-toned theme + warm image (or vice versa). Creates tension and depth.
Example: A cool blue/purple theme → faint amber-toned texture or desert photograph.

**C) Neutral Anchor** — Grayscale or near-neutral image. Works with any palette.
Example: Dark concrete, starfield photography, black marble, ink wash.

**D) Thematic Echo** — Image reinforces the semantic content of the theme name.
Example: "Tokyo Night" theme → aerial city lights at night. "Forest" theme → dark canopy.

### Specification Format

Describe the background image in terms of:
1. **Subject**: What it depicts
2. **Mood**: The emotional quality
3. **Color treatment**: How it's processed to fit the theme (desaturate to X%, tint with #HEX, etc.)
4. **Ghostty config**:
   - `background-image = /path/to/image.jpg` *(user must supply the image)*
   - `background-image-opacity = 0.05–0.20` (keep subtle; shaders are the primary FX)
   - `background-image-fit = cover` or `contain`
   - `background-image-position = center`

Note: If the theme is heavy on shader effects, recommend `0.05–0.10` opacity (nearly invisible anchor texture). If minimal/no shaders, `0.10–0.20` is appropriate.

Include a prompt the user can paste into an AI image generator (Midjourney, Stable Diffusion, DALL-E) to generate a matching background.

---

## STEP 6 — GENERATE THE COMPLETE PROFILE

Write the complete Ghostty config file with this structure. Fill in all values from Steps 1–5.

```
# [THEME NAME] — [ONE LINE DESCRIPTION]
# Color theory: [approach used]
# Shaders: [layer stack summary]
#
# =========================================================
#  FONT
# =========================================================
font-family = [font]
font-family-italic = [italic font — same or VictorMono Nerd Font]
font-family-bold-italic = [same as italic]
font-size = [size]
adjust-cell-height = [percentage]%
adjust-icon-height = [percentage if needed]
font-feature = +liga

# =========================================================
#  THEME COLORS
# =========================================================
background = [hex without #]
foreground = [hex without #]
cursor-color = [hex]
cursor-style = [block|bar|underline|block_hollow]
cursor-style-blink = false
cursor-opacity = [0.85–1.0]
selection-background = [hex]
selection-foreground = [hex]

# =========================================================
#  ANSI PALETTE — [THEORY NAME] color scheme
#  Hue map: [brief description, e.g. "Blue/Orange complementary"]
# =========================================================
palette = 0=[hex]     # Black — [description]
palette = 1=[hex]     # Red — [description]
palette = 2=[hex]     # Green — [description]
palette = 3=[hex]     # Yellow — [description]
palette = 4=[hex]     # Blue — [description]
palette = 5=[hex]     # Magenta — [description]
palette = 6=[hex]     # Cyan — [description]
palette = 7=[hex]     # White — [description]
palette = 8=[hex]     # Bright Black — [description]
palette = 9=[hex]     # Bright Red
palette = 10=[hex]    # Bright Green
palette = 11=[hex]    # Bright Yellow
palette = 12=[hex]    # Bright Blue
palette = 13=[hex]    # Bright Magenta
palette = 14=[hex]    # Bright Cyan
palette = 15=[hex]    # Bright White

# =========================================================
#  DISPLAY
# =========================================================
window-width = 140
window-height = 30
window-padding-x = 4
window-padding-y = 4
window-padding-balance = true
window-save-state = always
window-decoration = true
window-theme = dark
split-divider-color = [subtle accent hex]
unfocused-split-opacity = 0.7

# =========================================================
#  QUALITY
# =========================================================
background-opacity = [see opacity×shader table in Step 3]
background-opacity-cells = false
alpha-blending = linear-corrected
minimum-contrast = 1.1
mouse-hide-while-typing = true
mouse-scroll-multiplier = 2
copy-on-select = clipboard
scrollback-limit = 25000000
shell-integration-features = no-cursor,sudo,no-title

# =========================================================
#  SHADERS — [brief stack description]
#  Layer rationale:
#    L1 ([shader1]): [why this layer]
#    L2 ([shader2]): [why this layer]
#    L3 ([shader3 if any]): [why this layer]
# =========================================================
custom-shader = ~/.config/ghostty/shaders/[shader1].glsl
custom-shader = ~/.config/ghostty/shaders/[shader2].glsl
# custom-shader = ~/.config/ghostty/shaders/[shader3].glsl   # optional 3rd
custom-shader-animation = true

# =========================================================
#  BACKGROUND IMAGE (optional — user must provide image)
#  Concept: [image description]
#  AI prompt: "[midjourney/SD prompt]"
# =========================================================
# background-image = ~/.config/ghostty/backgrounds/[theme-name].jpg
# background-image-opacity = [0.05–0.20]
# background-image-fit = cover
# background-image-position = center

# =========================================================
#  KEYBINDS
# =========================================================
keybind = super+shift+r=reload_config
keybind = super+shift+x=close_surface
keybind = super+shift+n=new_window
keybind = super+shift+c=new_tab
keybind = super+shift+l=next_tab
keybind = super+shift+h=previous_tab
keybind = super+1=goto_tab:1
keybind = super+2=goto_tab:2
keybind = super+3=goto_tab:3
keybind = super+4=goto_tab:4
keybind = super+5=goto_tab:5
keybind = super+shift+backslash=new_split:right
keybind = super+shift+minus=new_split:down
keybind = super+shift+j=goto_split:bottom
keybind = super+shift+k=goto_split:top
keybind = super+shift+z=toggle_split_zoom
keybind = super+shift+e=equalize_splits
keybind = shift+enter=text:\x1b\r
```

---

## STEP 7 — SAVE AS INDEPENDENT COMPONENTS + ASSEMBLED PROFILE

The theme system is **modular** — save each element as its own reusable file, then register it in `themes.json`. This allows any component to be mixed with any other via `ss --colors X --effects Y --font Z`.

### 7a — Determine IDs and slugs

```bash
# Next profile number
ls ~/.config/ghostty/profiles/profile_*.conf | sed 's/.*profile_\([0-9]*\)_.*/\1/' | sort -n | tail -1
# slug = theme name lowercased, spaces→underscores, e.g. "bioluminescent_deep_sea"
```

### 7b — Write the 4 component files

**`~/.config/ghostty/components/colors/[slug].conf`**
```
# colors: [slug]
background = [hex]
foreground = [hex]
cursor-color = [hex]
selection-background = [hex]
selection-foreground = [hex]
palette = 0=[hex]
palette = 1=[hex]
... (all 16)
```

**`~/.config/ghostty/components/fonts/[font-slug].conf`** (only if this font config doesn't already exist — check `ls ~/.config/ghostty/components/fonts/`)
```
# font: [font-slug]
font-family = "[Font Name]"
font-family-italic = "[Italic Font]"
font-size = [N]
adjust-cell-height = [N]%
font-feature = +liga
```

**`~/.config/ghostty/components/effects/[effects-slug].conf`** (only if this effect doesn't already exist)
```
# effects: [effects-slug]
background-opacity = [value]
background-opacity-cells = false
custom-shader = ~/.config/ghostty/shaders/[shader1].glsl
custom-shader = ~/.config/ghostty/shaders/[shader2].glsl
custom-shader-animation = true
```

**`~/.config/ghostty/components/prompts/[slug].toml`**
```toml
# prompt: [slug]

[palettes.[slug]]
accent    = "[primary accent hex]"
secondary = "[secondary hex]"
warning   = "[yellow/orange hex]"
success   = "[green hex]"
error     = "[red hex]"
muted     = "[dim/comment hex]"
surface   = "[background hex]"
red       = "[error hex]"
peach     = "[warning hex]"
yellow    = "[warning hex]"
green     = "[success hex]"
sapphire  = "[secondary hex]"
lavender  = "[accent hex]"
crust     = "[background hex]"
```

Also copy all 4 component files to `~/code/terminal-themer/components/[subdir]/` to keep the repo in sync.

### 7c — Write the assembled profile

Write `~/.config/ghostty/profiles/profile_[NN]_[Theme_Name].conf` by concatenating:
```bash
cat ~/.config/ghostty/components/base.conf \
    ~/.config/ghostty/components/colors/[slug].conf \
    ~/.config/ghostty/components/fonts/[font-slug].conf \
    ~/.config/ghostty/components/effects/[effects-slug].conf \
    > ~/.config/ghostty/profiles/profile_[NN]_[Theme_Name].conf
```
Also copy to `~/code/terminal-themer/profiles/`.

### 7d — Register in themes.json

Append a new entry to `~/code/terminal-themer/themes.json`:
```json
{ "id": [NN], "name": "[Theme Name]", "colors": "[slug]", "font": "[font-slug]", "effects": "[effects-slug]", "prompt": "[slug]" }
```

### 7e — Apply

Ask: **"Switch to this theme now? (yes/no)"**
- If yes: `bash ~/scripts/ss.sh [NN]`
- Confirm: "Theme applied via component assembly. Press Super+Shift+R if it doesn't reload."

---

## STEP 8 — DESIGN BRIEF

After generating the profile, present a concise design brief:

```
┌─────────────────────────────────────────────────────────┐
│  THEME: [Name]                                          │
│  Concept: [one sentence]                                │
├─────────────────────────────────────────────────────────┤
│  COLOR THEORY                                           │
│  Approach: [theory name]                                │
│  Seed hue: [hue°] — [color name]                        │
│  Palette: [3-6 key hex values with names]               │
├─────────────────────────────────────────────────────────┤
│  SHADERS                                                │
│  L1: [shader] — [what it does]                          │
│  L2: [shader] — [what it adds]                          │
│  L3: [shader] — [what it finishes]                      │
│  Visual result: [one sentence describing the effect]    │
├─────────────────────────────────────────────────────────┤
│  TYPOGRAPHY                                             │
│  Regular: [font] [size]pt / [cell-height]%              │
│  Italic:  [italic font] — [reason for pairing]          │
│  Cursor:  [style] / opacity [value]                     │
├─────────────────────────────────────────────────────────┤
│  VALIDATION                                             │
│  Error (palette 1 on bg):   [hex pair] ✓/✗             │
│  Comment (palette 8 on bg): [hex pair] ✓/✗             │
│  Keyword vs string (4 vs 3): distinct? ✓/✗             │
├─────────────────────────────────────────────────────────┤
│  BACKGROUND IMAGE                                       │
│  Strategy: [mirror/contrast/neutral/thematic]           │
│  Concept: [description]                                 │
│  Opacity: [value]                                       │
│  AI prompt: "[generation prompt]"                       │
└─────────────────────────────────────────────────────────┘
```

---

## DESIGN STANDARDS

Before declaring the theme complete, verify all of the following:

| Gate | Question | Minimum bar |
|------|----------|-------------|
| **Readability** | Can you code in it for 8+ hours? | All text ≥ 4.5:1 contrast on background |
| **Coherence** | Do the 16 colors feel like a family? | All derived from same seed hue via algorithm |
| **Shader harmony** | Do shaders enhance without competing with text? | Text legible with `background-opacity-cells = false` |
| **Performance** | Will shaders run smoothly? | No Tier 3 + Tier 2 combinations |
| **Validation** | Did Step F pass? | All 6 syntax highlight checks ✓ |
| **Uniqueness** | Does this theme have a reason to exist? | Distinct from all 21 existing profiles |
| **Completeness** | Is every field a deliberate choice? | No placeholder values remaining |

A great theme is one where colors, shaders, font, and background image each reinforce a single coherent mood — and where the sum is greater than any individual element alone.

---

## OPTIONAL FINAL STEP — DELIBERATIVE POLISH

If the `/deliberative-refinement` skill is available, run it on the completed theme now:

```
/deliberative-refinement

Review this Ghostty terminal theme design brief and .conf file. Look for:
- Any color in the 16-palette that feels out of family or fails its use case
- Shader combinations that may fight each other visually or underperform
- Font or cursor choices that don't serve the theme's stated mood
- Background image strategy that could be stronger
- Any decision that was made by default rather than by deliberate reasoning

Suggest the 1–3 highest-impact improvements, ranked by visual effect.
```

This pass often catches subtle issues that only become apparent when viewing the theme as a whole system rather than step by step — particularly color relationships that looked fine in isolation but feel off together, or shader stacks where the order should be swapped.
