# 👻 GhostClipboard

A spooky clipboard manager for macOS, iOS, and terminal with cloud sync!

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20CLI-purple) ![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Features

**macOS** • Automatic monitoring • Ghost UI • Search • Favorites • iCloud sync • Shortcuts
**iOS** • Universal design • Ghost Mode • Cloud sync • Rich previews
**CLI** • Interactive TUI • Lightning fast • Data sharing • Fun ghost extras

## Quick Start

### macOS/iOS Apps

1. Create Xcode project (macOS or iOS → App)
2. Add files from `macOS/`, `iOS/`, `Shared/`
3. Enable iCloud + CloudKit: `iCloud.com.yourname.ghostclipboard`
4. Build and run (⌘R)

See [SETUP.md](SETUP.md) for details.

### CLI Tool

```bash
cd CLI
./install.sh        # Install globally
ghostclip           # Run
```

## Usage

**macOS:** `⌘⇧C` Capture • `⌘⇧K` Clear • `⌘F` Search • Click to copy

**iOS:** Tap to copy • Long press for options

**CLI:**
```bash
ghostclip           # Interactive mode
ghostclip --list    # List items
ghostclip --last    # Copy last item

# Fun extras!
ghostclip --fortune # Get a spooky fortune
ghostclip --haunt   # Get haunted
ghostclip --story   # Hear a ghost story
```

**Interactive Keys:** `↑↓` Navigate • `Enter` Copy • `f` Favorite • `/` Search • `q` Quit

## Structure

```
├── macOS/          # macOS app
├── iOS/            # iOS app
├── Shared/         # Shared Swift code
├── CLI/            # Terminal interface
└── extras/boocli/  # Original terminal ghost companion (Node.js)
```

## Cloud Sync

Uses iCloud CloudKit • Auto sync on launch • Manual sync via cloud button • Private container

## Extras

The original BOOCLI terminal companion lives in `extras/boocli/`:

```bash
cd extras/boocli
npm install && npm start
```

Interactive ghost with fortunes, stories, and ASCII art!

## Requirements

macOS 13.0+ • iOS 16.0+ • Xcode 15.0+ • Apple Developer Account (for CloudKit)

## License

MIT

---

*"I see dead copies... and I help you resurrect them!"* 👻💀
