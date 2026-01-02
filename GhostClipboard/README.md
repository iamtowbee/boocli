# 👻 GhostClipboard

A spooky clipboard manager for macOS and iOS with cloud sync! Never lose your clipboard history to the void again.

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS-purple)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-blue)

## 🎃 Features

### macOS App
- **🔮 Automatic Clipboard Monitoring** - Captures every copy automatically
- **👻 Ghost-Themed UI** - Spooky animations and delightful ghost mascots
- **🔍 Smart Search** - Find anything in your clipboard history
- **🏷️ Type Detection** - Automatically categorizes text, URLs, code, and images
- **⭐ Favorites** - Star your most-used clipboard items
- **☁️ iCloud Sync** - Share clipboard history across all your devices
- **⌨️ Keyboard Shortcuts** - Quick actions with keyboard commands
- **🌙 Beautiful Design** - Native macOS experience with modern SwiftUI

### iOS App
- **📱 Universal Design** - Works beautifully on iPhone and iPad
- **👻 Ghost Mode** - Summon random ghosts for fun messages
- **⭐ Favorites Tab** - Quick access to starred items
- **☁️ Cloud Sync** - Seamlessly syncs with macOS app
- **🎨 Rich Previews** - Beautiful cards for each clipboard item
- **📋 Manual Entry** - Add items manually or from current clipboard
- **🏷️ Smart Categories** - Filter by text, URLs, code, or images

## 📦 What's Included

```
GhostClipboard/
├── Shared/                    # Shared code for both platforms
│   ├── ClipboardItem.swift    # Data models
│   ├── ClipboardManager.swift # Clipboard monitoring & management
│   └── CloudSyncManager.swift # iCloud CloudKit sync
├── macOS/                     # macOS app
│   ├── GhostClipboardApp.swift
│   ├── ContentView.swift
│   ├── Info.plist
│   └── GhostClipboard.entitlements
└── iOS/                       # iOS app
    ├── GhostClipboardApp.swift
    ├── ContentView.swift
    ├── Info.plist
    └── GhostClipboard.entitlements
```

## 🛠️ Building the Apps

### Prerequisites

- **Xcode 15.0+** (for Xcode 15 or later)
- **macOS Ventura 13.0+** (for macOS development)
- **iOS 16.0+** SDK (for iOS development)
- **Apple Developer Account** (for CloudKit and app signing)

### Step 1: Set Up Xcode Projects

Since we're using SwiftUI, you'll need to create Xcode projects for both platforms:

#### For macOS:

1. Open Xcode
2. Create new project → **macOS** → **App**
3. Product Name: `GhostClipboard`
4. Organization Identifier: `com.ghostclipboard`
5. Interface: **SwiftUI**
6. Language: **Swift**
7. Add the files from `GhostClipboard/macOS/` and `GhostClipboard/Shared/`
8. Add the entitlements file to your project

#### For iOS:

1. Open Xcode
2. Create new project → **iOS** → **App**
3. Product Name: `GhostClipboard`
4. Organization Identifier: `com.ghostclipboard`
5. Interface: **SwiftUI**
6. Language: **Swift**
7. Add the files from `GhostClipboard/iOS/` and `GhostClipboard/Shared/`
8. Add the entitlements file to your project

### Step 2: Configure iCloud

1. **Enable iCloud in Xcode:**
   - Select your project in the navigator
   - Select your target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "iCloud"
   - Check "CloudKit"
   - Add container: `iCloud.com.ghostclipboard`

2. **Configure CloudKit Dashboard:**
   - Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/)
   - Select your container
   - Create a new Record Type: `ClipboardItem`
   - Add fields:
     - `id` (String)
     - `content` (String)
     - `timestamp` (Date/Time)
     - `type` (String)
     - `isFavorite` (Int64)
     - `tags` (String List)

### Step 3: Build and Run

#### macOS:
```bash
# In Xcode
1. Select "GhostClipboard" scheme with "My Mac" destination
2. Click Run (⌘R)
3. Grant clipboard access when prompted
```

#### iOS:
```bash
# In Xcode
1. Select "GhostClipboard" scheme with your device/simulator
2. Click Run (⌘R)
3. Sign in with your Apple ID in Settings → iCloud
```

### Quick Setup Script (Alternative)

If you prefer using Swift Package Manager for the shared code:

```bash
cd GhostClipboard/Shared
swift package init --type library --name GhostClipboardKit
```

Then add to `Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GhostClipboardKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "GhostClipboardKit",
            targets: ["GhostClipboardKit"]),
    ],
    targets: [
        .target(
            name: "GhostClipboardKit",
            dependencies: []),
    ]
)
```

## 🎮 Usage

### macOS

**Keyboard Shortcuts:**
- `⌘⇧C` - Capture current clipboard
- `⌘⇧K` - Clear all history
- `⌘F` - Search
- `⌘,` - Open settings

**Features:**
- Clipboard is automatically monitored in the background
- Click any item to copy it back to clipboard
- Hover over items to see action buttons
- Star items to mark as favorites
- Search through your entire history
- Filter by type (text, URL, code, images)

### iOS

**Gestures:**
- **Tap** any item to copy to clipboard
- **Long press** to see more options
- **Pull to refresh** to sync from cloud

**Tabs:**
- **History** - View all clipboard items
- **Favorites** - Quick access to starred items
- **Ghost Mode** - Have fun with random ghosts!

## ☁️ Cloud Sync

GhostClipboard uses iCloud CloudKit to sync your clipboard history across devices:

- **Automatic Sync** - Items sync when you open the app
- **Manual Sync** - Tap the cloud icon to sync immediately
- **Conflict Resolution** - Newer items always win
- **Privacy** - All data stored in your private iCloud container

## 🎨 Customization

### Adding More Ghosts

Edit `ClipboardItem.swift` to add more ghost emojis:

```swift
var ghostEmoji: String {
    let ghosts = ["👻", "🎃", "💀", "🦇", "🕷️", "🕸️", "⚰️", "🔮", "🌙", "✨"]
    // Add your own here!
    let index = abs(id.hashValue) % ghosts.count
    return ghosts[index]
}
```

### Adding More Ghost Quotes

Edit `ClipboardItem.swift`:

```swift
struct GhostQuotes {
    static let hauntingMessages = [
        "Boo! Your clipboard is haunted! 👻",
        // Add your own spooky messages!
    ]
}
```

## 🔒 Privacy & Security

- **Local First** - All data stored locally by default
- **Optional Cloud** - iCloud sync is opt-in
- **No Tracking** - Zero analytics or tracking
- **Sandboxed** - Apps run in Apple's sandbox for security
- **Open Source** - All code is visible and auditable

## 🐛 Troubleshooting

### macOS: Clipboard Not Monitoring

- Check System Settings → Privacy & Security → Accessibility
- Grant GhostClipboard permission

### Cloud Sync Not Working

- Ensure you're signed into iCloud
- Check Settings → Apple ID → iCloud → iCloud Drive is enabled
- Verify internet connection
- Check CloudKit Dashboard for container status

### Items Not Appearing

- Try manual sync (cloud icon)
- Restart the app
- Check iCloud storage isn't full

## 🎯 Future Ideas

- [ ] Browser extension
- [ ] Clipboard sharing between users
- [ ] OCR for images
- [ ] Rich text formatting
- [ ] Clipboard snippets/templates
- [ ] Quick actions/shortcuts
- [ ] Menu bar app for macOS
- [ ] Widgets for iOS
- [ ] Watch app

## 📝 License

MIT License - Feel free to use this for your own projects!

## 🙏 Credits

Built with 💀 by the ghost developers

**Technologies:**
- SwiftUI
- CloudKit
- Combine
- AppKit (macOS)
- UIKit (iOS)

## 📚 Related

This is part of the BOOCLI family of spooky apps! Check out:
- **BOOCLI** - The terminal ghost companion (in the root directory)

---

**Remember**: Your clipboard is now haunted... but in a good way! 👻✨

## 🆘 Support

Found a bug? The ghost ate it! Just kidding - please:
1. Check existing issues
2. Create a new issue with details
3. Include: macOS/iOS version, steps to reproduce, expected vs actual behavior

---

*"I see dead code... and I help you manage it!" - GhostClipboard* 💀
