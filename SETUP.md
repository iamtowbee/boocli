# 🎃 Quick Setup Guide for GhostClipboard

This guide will help you get GhostClipboard running on your Mac and iOS devices in just a few minutes!

## 📋 Prerequisites Checklist

- [ ] macOS Ventura (13.0) or later
- [ ] Xcode 15.0 or later
- [ ] Apple Developer Account (free or paid)
- [ ] iCloud account

## 🚀 Quick Start (5 Minutes)

### Step 1: Create macOS Project

1. **Open Xcode** and select "Create New Project"

2. **Choose Template:**
   - Platform: **macOS**
   - Template: **App**
   - Click **Next**

3. **Configure Project:**
   - Product Name: `GhostClipboard`
   - Team: Select your team
   - Organization Identifier: `com.yourname.ghostclipboard` (use your own)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Use Core Data: **Unchecked**
   - Include Tests: **Optional**
   - Click **Next** and save

4. **Add Source Files:**
   - Delete the default `ContentView.swift` if it exists
   - Right-click on the project → Add Files to "GhostClipboard"
   - Add ALL files from `GhostClipboard/macOS/`
   - Add ALL files from `GhostClipboard/Shared/`
   - Make sure "Copy items if needed" is **checked**
   - Make sure your target is **selected**

5. **Configure Entitlements:**
   - Select your project in navigator
   - Select your target
   - Go to **Signing & Capabilities** tab
   - Click **+ Capability**
   - Add **App Sandbox** (should already be there)
   - Add **iCloud**
     - Check **CloudKit**
     - Under **Containers**, click **+**
     - Enter: `iCloud.com.yourname.ghostclipboard` (use the same org identifier)
   - Under App Sandbox, enable:
     - **Outgoing Connections (Client)**
     - **User Selected Files** → Read Only

### Step 2: Create iOS Project

Repeat the same steps as macOS, but:
1. Choose **iOS** platform instead of macOS
2. Add files from `GhostClipboard/iOS/` and `GhostClipboard/Shared/`
3. Same iCloud container identifier: `iCloud.com.yourname.ghostclipboard`

### Step 3: Update CloudKit References

In both projects, update the CloudKit container identifier in `CloudSyncManager.swift`:

```swift
// Find this line (around line 18):
container = CKContainer(identifier: "iCloud.com.ghostclipboard")

// Change to YOUR identifier:
container = CKContainer(identifier: "iCloud.com.yourname.ghostclipboard")
```

### Step 4: Build and Run!

#### macOS:
1. Select "My Mac" as the destination
2. Press **⌘R** to build and run
3. The app will ask for accessibility permissions - grant them in System Settings

#### iOS:
1. Select your iPhone or simulator as destination
2. Press **⌘R** to build and run
3. If on device, make sure you're signed into iCloud

## 🔧 Detailed Configuration

### Setting Up CloudKit (Optional but Recommended)

For cloud sync to work properly:

1. **Go to CloudKit Dashboard:**
   - Visit: https://icloud.developer.apple.com/dashboard/
   - Sign in with your Apple ID
   - Select your container (e.g., `iCloud.com.yourname.ghostclipboard`)

2. **Create Development Schema:**
   - Click **Schema** → **Record Types**
   - The app will create the schema automatically on first sync
   - OR manually create `ClipboardItem` record type with fields:
     - `id` (String)
     - `content` (String)
     - `timestamp` (Date/Time)
     - `type` (String)
     - `isFavorite` (Int64)
     - `tags` (List<String>)

3. **Deploy to Production:**
   - After testing, go to **Schema** → **Deploy to Production**
   - This makes cloud sync work for production builds

### Troubleshooting Common Issues

#### "No such module 'CloudKit'" error
- Make sure you added the iCloud capability
- Clean build folder (⌘⇧K)
- Restart Xcode

#### macOS app doesn't monitor clipboard
- Grant accessibility permissions:
  - System Settings → Privacy & Security → Accessibility
  - Add GhostClipboard and enable it

#### Cloud sync not working
1. Ensure you're signed into iCloud on all devices
2. Check iCloud Drive is enabled
3. Verify your container identifier matches everywhere
4. Try manual sync using the cloud button

#### Simulator issues
- CloudKit works better on real devices
- Sign into iCloud in the simulator: Settings → Sign in
- Or test without cloud sync first

## 📱 Testing Cloud Sync

1. **Run macOS app:**
   - Copy some text
   - Verify it appears in the history
   - Click the cloud icon to sync

2. **Run iOS app:**
   - Wait a moment or tap cloud icon
   - Your items should appear!

3. **Test from iOS:**
   - Add an item on iOS
   - Sync
   - Check if it appears on macOS

## 🎨 Customization

### Change the App Icon

1. Create your own spooky icon (1024x1024 PNG)
2. Use [App Icon Generator](https://www.appicon.co/) to create all sizes
3. Add to Assets.xcassets in Xcode

### Change Color Scheme

Edit the color values in `ContentView.swift`:
- Purple theme: `.purple` → change to your color
- Gradients: `[.purple, .blue]` → change both colors

### Add More Ghost Quotes

In `Shared/ClipboardItem.swift`, find `GhostQuotes` and add your messages!

## 🚢 Distribution

### TestFlight (Recommended for Testing)

1. **Archive the app:**
   - Select "Any Mac (Apple Silicon)" or "Any iOS Device"
   - Product → Archive
   - Wait for archive to complete

2. **Upload to App Store Connect:**
   - Click **Distribute App**
   - Choose **App Store Connect**
   - Upload

3. **Add to TestFlight:**
   - Go to App Store Connect
   - Select your app
   - Go to TestFlight tab
   - Add internal testers

### Direct Distribution (macOS only)

1. **Notarize the app** (required for distribution)
2. **Export as Developer ID** app
3. Share the .app file

## 🆘 Need Help?

### Check These First:
- [ ] All files copied correctly?
- [ ] Entitlements configured?
- [ ] iCloud container identifier matches everywhere?
- [ ] Signed into iCloud?
- [ ] Build errors? Try Clean Build Folder (⌘⇧K)

### Still Stuck?

1. Check the main README.md
2. Look at Xcode's error messages carefully
3. Search the error on Stack Overflow
4. Create an issue on GitHub with:
   - Xcode version
   - macOS/iOS version
   - Full error message
   - Steps you've tried

## ✅ Success Checklist

Once everything is working, you should be able to:

**macOS:**
- [x] App launches without errors
- [x] Clipboard is automatically monitored
- [x] Items appear when you copy text
- [x] Can search through history
- [x] Can favorite items
- [x] Cloud sync button works

**iOS:**
- [x] App launches without errors
- [x] Can add items manually
- [x] Can paste from current clipboard
- [x] Favorites tab works
- [x] Ghost mode is fun!
- [x] Cloud sync works

## 🎉 You're Done!

Enjoy your spooky clipboard manager! Your clipboard is now haunted... but in the best way possible! 👻

---

*Remember: With great clipboard power comes great clipboard responsibility!* 💀
