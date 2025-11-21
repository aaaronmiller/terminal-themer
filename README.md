# 👻 Ghostty Terminal Themer

A comprehensive, dual-method configuration management system for the [Ghostty terminal emulator](https://ghostty.org) on macOS. Switch between 20 beautiful, curated themes instantly with either a direct command or an interactive fuzzy-finder menu.

## ✨ Features

- **20 Curated Themes**: Professionally configured profiles featuring popular themes like Catppuccin, Nord, Dracula, Tokyo Night, and more
- **Dual Switching Methods**:
  - `ss <number>`: Direct profile switching for speed
  - `gswitch`: Interactive fzf-based fuzzy finder with live preview
- **Optimized for AI CLI Tools**: No text wrapping, large scrollback, fast rendering
- **Visual Effects**: Optional shaders from the ghostty-shaders collection
- **Zero Configuration**: Single installation script sets up everything
- **Safe Backups**: Automatic configuration backups before changes
- **Fast Reload**: Instant configuration reload via keyboard shortcut

## 📦 What's Included

### Themes

The system includes 20 carefully crafted profiles with diverse visual styles:

| # | Theme | Style | # | Theme | Style |
|---|-------|-------|---|-------|-------|
| 01 | Catppuccin Latte | Light, Pastel | 11 | Monokai Pro | Professional Dark |
| 02 | Catppuccin Mocha | Cozy Dark | 12 | Ayu Dark | Elegant Dark |
| 03 | Nord | Arctic Blue | 13 | Material Ocean | Material Design |
| 04 | Dracula | Vibrant Dark | 14 | Palenight | Soft Purple |
| 05 | Solarized Dark | Precision Dark | 15 | Oceanic Next | Deep Blue |
| 06 | Solarized Light | Precision Light | 16 | GitHub Dark | Official GitHub |
| 07 | Gruvbox Dark | Retro Warm | 17 | Synthwave 84 | Neon Retro |
| 08 | Gruvbox Light | Retro Warm Light | 18 | Cyberpunk | High-Tech |
| 09 | Tokyo Night | Night City | 19 | Rose Pine | Natural Vibes |
| 10 | One Dark | Classic Atom | 20 | Everforest Dark | Forest Green |

### Configuration Highlights

Each profile includes:
- Optimized font rendering with various Nerd Fonts
- Custom background opacity settings
- Curated shader effects (where appropriate)
- Consistent 140x40 window geometry
- Metal renderer for performance
- 25,000 line scrollback buffer
- Disabled text wrapping (perfect for AI output)

## 🚀 Installation

### Prerequisites

- macOS (required for AppleScript-based config reload)
- [Ghostty terminal](https://ghostty.org) installed
- Homebrew (recommended, for fzf installation)
- Git (for cloning)

### Quick Install

1. **Clone this repository into your Ghostty config directory:**

```bash
git clone https://github.com/yourusername/terminal-themer.git ~/.config/ghostty-themer
cd ~/.config/ghostty-themer
```

2. **Run the installation script:**

```bash
./install.sh
```

The installer will:
- ✅ Install fzf via Homebrew (if available)
- ✅ Create required directories
- ✅ Clean up old configuration files
- ✅ Install all 20 profile configurations
- ✅ Clone the ghostty-shaders repository
- ✅ Install switching scripts to `~/scripts/`
- ✅ Add `ss` and `gswitch` commands to your `.zshrc`
- ✅ Create a default base configuration

3. **Reload your shell:**

```bash
source ~/.zshrc
```

## 📖 Usage

### Method 1: Direct Switching with `ss`

Switch directly to any profile by number:

```bash
# View available profiles
ss

# Switch to profile 5 (Solarized Dark)
ss 5

# Switch to profile 17 (Synthwave 84)
ss 17
```

**Output:**
```
✓ Switched to profile 5: Solarized Dark
✓ Configuration reloaded
```

### Method 2: Interactive Selection with `gswitch`

Launch an interactive fzf menu to browse and preview profiles:

```bash
gswitch
```

**Features:**
- Live preview of profile configuration
- Fuzzy search by name or number
- Arrow keys to navigate
- Enter to select, Esc to cancel
- Beautiful color-coded interface

## 🎨 Profile Details

### Light Themes
- **01 - Catppuccin Latte**: Warm pastel colors, perfect for bright environments
- **06 - Solarized Light**: Scientifically designed precision colors
- **08 - Gruvbox Light**: Retro warm light theme with excellent contrast

### Dark Themes
Most profiles are optimized for dark environments with various aesthetic styles:

- **Cozy & Comfortable**: Catppuccin Mocha, Rose Pine, Everforest
- **Vibrant & Colorful**: Dracula, Tokyo Night, Synthwave 84
- **Professional**: One Dark, Monokai Pro, GitHub Dark
- **Unique & Artistic**: Cyberpunk, Ayu Dark, Material Ocean
- **Classic**: Nord, Gruvbox Dark, Solarized Dark

### Shader Effects

Several profiles include optional shader effects:
- **Galaxy** (Dracula): Cosmic particle effects
- **Animated Gradient** (Catppuccin Mocha): Smooth color transitions
- **VHS** (Gruvbox Dark): Retro analog effect
- **Neon Glow** (Tokyo Night): Subtle neon highlights
- **Retrowave** (Synthwave 84): 80s aesthetic
- **Matrix Rain** (Cyberpunk): Digital rain effect
- **Aurora** (Rose Pine): Northern lights effect

*Note: Shaders require the ghostty-shaders repository, which is automatically cloned during installation.*

## 🛠️ How It Works

### Architecture

The system consists of three main components:

1. **Profile Library** (`~/.config/ghostty/profiles/`)
   - 20 complete configuration files
   - Named `profile_XX_ThemeName.conf`
   - Each is a fully self-contained Ghostty config

2. **Switching Scripts** (`~/scripts/`)
   - `ss.sh`: Direct profile switcher
   - `gswitch.sh`: Fzf-based interactive switcher
   - Both copy the selected profile to `~/.config/ghostty/config`

3. **Active Configuration** (`~/.config/ghostty/config`)
   - The file Ghostty actually reads
   - Replaced when you switch profiles
   - Reloaded via AppleScript keyboard automation

### The Switching Process

When you run `ss 5` or select a profile via `gswitch`:

1. The script identifies the corresponding profile file
2. Backs up the current config (timestamped)
3. Copies the profile to `~/.config/ghostty/config`
4. Sends `Cmd+Shift+R` to Ghostty via AppleScript
5. Ghostty instantly reloads with the new theme

**Result:** Theme switch happens in under 1 second with no terminal restart required.

## 📁 Installation Structure

After installation, you'll have:

```
~/.config/ghostty/
├── config                  # Active configuration (auto-managed)
├── profiles/               # All 20 theme profiles
│   ├── profile_01_Catppuccin_Latte.conf
│   ├── profile_02_Catppuccin_Mocha.conf
│   └── ... (18 more)
├── shaders/               # Visual effects library
│   └── [ghostty-shaders repo contents]
└── themes.json           # Theme definitions reference

~/scripts/
├── ss.sh                 # Direct profile switcher
└── gswitch.sh           # Fzf interactive switcher

~/.zshrc
└── [Updated with ss and gswitch aliases]
```

## 🔧 Customization

### Creating Your Own Profile

1. Copy an existing profile as a template:
```bash
cp ~/.config/ghostty/profiles/profile_03_Nord.conf ~/.config/ghostty/profiles/profile_21_MyTheme.conf
```

2. Edit the colors and settings:
```bash
# Change theme colors
background = 1a1b26
foreground = c0caf5
# ... modify as desired
```

3. Your new profile will automatically appear in `ss` and `gswitch`!

### Modifying the Base Config

The base configuration is created by `install.sh`. To change default settings that apply to all profiles:

1. Edit the template in `install.sh` (search for "Step 8")
2. Or manually edit `~/.config/ghostty/config` and those changes will persist until you switch profiles

### Using Different Fonts

Each profile specifies a font family. Popular choices:

- `BerkeleyMono Nerd Font` (default for several profiles)
- `JetBrains Mono`
- `Fira Code`
- `SF Mono` (macOS system font)
- `Hack Nerd Font`
- `Iosevka`

Install Nerd Fonts via Homebrew:
```bash
brew tap homebrew/cask-fonts
brew install font-jetbrains-mono-nerd-font
```

## 🐛 Troubleshooting

### `ss: command not found`

**Solution:** Reload your shell configuration:
```bash
source ~/.zshrc
```

### `fzf: command not found` when running `gswitch`

**Solution:** Install fzf:
```bash
brew install fzf
```

### Profile switches but Ghostty doesn't reload

**Cause:** AppleScript may not have accessibility permissions.

**Solution:**
1. Open System Preferences → Security & Privacy → Privacy → Accessibility
2. Add your terminal application (Terminal.app or Ghostty itself)
3. Try switching again

Alternatively, manually reload: Press `Cmd+Shift+R` in Ghostty.

### Colors look wrong

**Possible causes:**
- Terminal color management settings
- Font rendering issues

**Solution:**
1. Check that `window-theme` in your profile matches your macOS appearance (dark/light)
2. Ensure font is installed: `fc-list | grep "FontName"`
3. Try a different profile to isolate the issue

### Shaders not working

**Cause:** Shaders directory not cloned properly.

**Solution:** Manually clone:
```bash
git clone https://github.com/hackr-sh/ghostty-shaders.git ~/.config/ghostty/shaders
```

Then switch profiles again.

## 🤝 Contributing

Contributions are welcome! Ideas for contributions:

- Additional theme profiles
- Custom shader configurations
- Support for other shells (bash, fish)
- Linux/Windows support
- Theme preview generator

## 📝 License

MIT License - feel free to use and modify as needed.

## 🙏 Credits

- **Ghostty**: [Mitchell Hashimoto](https://github.com/mitchellh) for creating this amazing terminal
- **Shaders**: [hackr-sh/ghostty-shaders](https://github.com/hackr-sh/ghostty-shaders) for visual effects
- **Themes**: Inspired by popular color schemes from the developer community
- **fzf**: [junegunn/fzf](https://github.com/junegunn/fzf) for the fuzzy finder

## 🌟 Star This Repo

If you find this useful, please consider starring this repository!

---

**Made with ❤️ for the Ghostty community**
