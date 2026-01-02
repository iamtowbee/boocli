# 👻 GhostClipboard CLI

A spooky interactive terminal interface for GhostClipboard!

## Features

- 📋 **Browse clipboard history** in your terminal
- ⌨️ **Keyboard-driven UI** with vim-like navigation
- 🔍 **Search and filter** clipboard items
- ⭐ **Manage favorites**
- 🎨 **Beautiful ghost-themed UI** with colors and box drawing
- 🔄 **Shares data** with macOS/iOS apps
- ⚡ **Lightning fast** - pure Swift, no dependencies

## Screenshot

```
═══════════════════════════════════════════════════
👻 GhostClipboard CLI 👻
Every paste summons us closer... 🕯️
═══════════════════════════════════════════════════
Items: 5

▶ 👻    📝 import Foundation... [2m ago]
  🎃    🔗 https://github.com/awesome... [5m ago]
  💀 ⭐ 💻 func clipboardManager()... [1h ago]
  🦇    📝 TODO: Add more ghosts... [3h ago]
  🕷️    🔗 https://swift.org... [1d ago]

────────────────────────────────────────────────────
Commands:
  ↑/↓ Navigate  | ENTER Copy  | F Toggle Favorite  | D Delete
  / Search  | * Favorites Only  | R Refresh  | Q Quit
────────────────────────────────────────────────────
```

## Installation

### Quick Install

```bash
cd GhostClipboard/CLI
./install.sh
```

This will:
1. Compile the Swift binary
2. Install `ghostclip` command globally
3. Make it available from anywhere

### Manual Build

```bash
swiftc -O main.swift -o ghostclip-bin
chmod +x ghostclip
```

Then run with `./ghostclip`

## Usage

### Interactive Mode (Default)

```bash
ghostclip
```

Launches the full interactive TUI where you can:
- Browse all clipboard items
- Search with `/`
- Navigate with arrow keys or j/k
- Copy items with Enter
- Toggle favorites with `f`
- Delete items with `d`
- Filter to favorites only with `*`

### Command Line Mode

```bash
# List all items
ghostclip --list

# Copy last item to clipboard
ghostclip --last

# Show help
ghostclip --help
```

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `↑/↓` or `k/j` | Navigate up/down |
| `Enter` | Copy selected item to clipboard |
| `f` | Toggle favorite status |
| `d` | Delete selected item |
| `/` | Enter search mode |
| `*` | Toggle favorites-only filter |
| `r` | Refresh from disk |
| `q` | Quit |

### Search Mode

Press `/` to enter search mode, then:
- Type to filter items
- Press `Enter` to exit search mode
- Press `Backspace` to delete characters

## Data Sharing

The CLI reads and writes to the same UserDefaults as the macOS app:
- **Key**: `clipboardHistory`
- **Location**: `~/Library/Preferences/`

This means:
- ✅ Changes in CLI appear in the macOS app
- ✅ Changes in macOS app appear in CLI
- ✅ Favorites sync between both
- ✅ Deletions sync automatically

## Examples

### Quick Copy Last Item

```bash
# Copy the most recent clipboard item
ghostclip --last
```

### Browse and Search

```bash
# Launch interactive mode
ghostclip

# Press / to search
# Type "http" to find URLs
# Press Enter to copy
```

### Favorites Workflow

```bash
ghostclip
# Navigate to an item
# Press 'f' to favorite
# Press '*' to show only favorites
# Press 'q' to quit
```

## Requirements

- macOS 10.15+
- Swift 5.0+ (comes with Xcode)
- GhostClipboard macOS app (optional but recommended)

## Architecture

The CLI is a single Swift file that:
1. Uses raw terminal mode for keyboard input
2. Renders with ANSI escape codes
3. Reads/writes JSON from UserDefaults
4. Uses NSPasteboard for clipboard access
5. Shares the same `ClipboardItem` model as the apps

## Tips & Tricks

### Add to Your Shell

Add an alias for quick access:

```bash
# In ~/.zshrc or ~/.bashrc
alias gc='ghostclip'
alias gcl='ghostclip --last'
```

### Use in Scripts

```bash
# Get last copied URL
ghostclip --last | grep http
```

### Integration with tmux

```bash
# Bind to a key in tmux.conf
bind-key C-g run-shell "ghostclip"
```

## Troubleshooting

### "Command not found"

Make sure `/usr/local/bin` is in your PATH:

```bash
echo $PATH | grep /usr/local/bin
```

If not, add to `~/.zshrc`:

```bash
export PATH="/usr/local/bin:$PATH"
```

### No clipboard items shown

1. Run the GhostClipboard macOS app first
2. Copy some text
3. Run `ghostclip --list` to verify

### Compilation errors

Make sure you have Xcode command line tools:

```bash
xcode-select --install
```

## Why Swift?

- **Fast**: Compiled, native performance
- **Integrated**: Uses same NSPasteboard as macOS app
- **Data sharing**: Easy UserDefaults access
- **No dependencies**: Single file, standard library only

## Future Ideas

- [ ] Export to file
- [ ] Import from file
- [ ] Sync indicator
- [ ] Preview mode for long items
- [ ] Syntax highlighting for code
- [ ] Mouse support (maybe)

## License

MIT - Same as parent project

---

*"I see dead copies... and I help you resurrect them!" - GhostClipboard CLI* 👻
