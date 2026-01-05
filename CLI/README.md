# 👻 GhostClipboard CLI

Interactive terminal interface for GhostClipboard with fun ghost extras!

## Features

📋 Browse clipboard history • ⌨️ Keyboard-driven UI • 🔍 Search & filter • ⭐ Favorites • 🔄 Syncs with macOS app • ⚡ Pure Swift • 🎃 Fun extras (fortunes, hauntings, stories)

## Installation

```bash
./install.sh        # Install globally
# Or
./ghostclip         # Run directly
```

## Usage

**Interactive Mode:**
```bash
ghostclip
```
Keys: `↑↓` Navigate • `Enter` Copy • `f` Favorite • `d` Delete • `/` Search • `*` Favorites • `q` Quit

**Quick Commands:**
```bash
ghostclip --list    # List all items
ghostclip --last    # Copy last item
```

**Fun Extras:**
```bash
ghostclip --fortune # Get spooky fortune
ghostclip --haunt   # Get haunted by a ghost
ghostclip --story   # Hear a ghost story
```

## Data Sharing

Reads/writes to same UserDefaults as macOS GUI app:
- Changes in CLI appear in macOS app
- Changes in macOS app appear in CLI
- Favorites and deletions sync automatically

## Shell Integration

```bash
# Add to ~/.zshrc
alias gc='ghostclip'
alias gcl='ghostclip --last'
```

## Requirements

macOS 10.15+ • Swift 5.0+

---

*"I see dead copies... and I help you resurrect them!"* 👻
