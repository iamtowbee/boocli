# 👻 GhostClipboard

A spooky clipboard manager for macOS and iOS with cloud sync!

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS-purple) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-blue)

## Features

### macOS App
Automatic clipboard monitoring • Ghost-themed UI • Smart search • Type detection • Favorites • iCloud sync • Keyboard shortcuts

### iOS App
Universal design • Ghost Mode • Favorites tab • Cloud sync • Rich previews • Manual entry • Smart categories

### CLI Tool
Interactive terminal UI • Pure Swift • Data sharing with GUI • Quick commands • Search & filter

## Quick Start

### macOS/iOS Apps

1. **Create Xcode project** (macOS or iOS → App)
2. **Add files** from `macOS/`, `iOS/`, and `Shared/`
3. **Enable iCloud** capability with CloudKit
4. **Set container**: `iCloud.com.yourname.ghostclipboard`
5. **Build and run** (⌘R)

See [SETUP.md](SETUP.md) for detailed instructions.

### CLI Tool

```bash
cd CLI
./install.sh       # Install globally
# Or
./ghostclip        # Run directly
```

## Usage

**macOS:**
`⌘⇧C` Capture • `⌘⇧K` Clear • `⌘F` Search • Click to copy

**iOS:**
Tap to copy • Long press for options • Pull to refresh

**CLI:**
```bash
ghostclip           # Interactive mode
ghostclip --list    # List items
ghostclip --last    # Copy last item
```

**CLI Keys:**
`↑↓` Navigate • `Enter` Copy • `f` Favorite • `/` Search • `*` Favorites only • `q` Quit

## Structure

```
GhostClipboard/
├── Shared/         # Shared Swift code
├── macOS/          # macOS app
├── iOS/            # iOS app
└── CLI/            # Terminal interface
```

## Cloud Sync

- Uses iCloud CloudKit for sync
- Automatic when opening app
- Manual sync via cloud button
- All data in private iCloud container

## Customization

**Add ghosts** in `ClipboardItem.swift`:
```swift
let ghosts = ["👻", "🎃", "💀", "🦇", "🕷️", "🕸️", "⚰️", "🔮", "🌙", "✨"]
```

**Add quotes** in `ClipboardItem.swift`:
```swift
static let hauntingMessages = [
    "Your message here! 👻",
]
```

## Troubleshooting

**macOS clipboard not monitoring:**
System Settings → Privacy & Security → Accessibility → Enable GhostClipboard

**Cloud sync not working:**
- Sign into iCloud
- Enable iCloud Drive
- Check container ID matches everywhere

**CLI command not found:**
```bash
echo $PATH | grep /usr/local/bin
# If missing, add to ~/.zshrc:
export PATH="/usr/local/bin:$PATH"
```

## Requirements

- macOS 13.0+
- iOS 16.0+
- Xcode 15.0+
- Apple Developer Account (for CloudKit)

## License

MIT - Free to haunt as you please!

---

*"I see dead copies... and I help you resurrect them!"* 👻💀
