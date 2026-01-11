//
//  GhostClipboardApp.swift
//  GhostClipboard for macOS
//
//  A spooky clipboard manager that haunts your Mac! 👻
//

import SwiftUI

@main
struct GhostClipboardApp: App {
    @StateObject private var clipboardManager = ClipboardManager()
    @StateObject private var cloudSync = CloudSyncManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clipboardManager)
                .environmentObject(cloudSync)
                .frame(minWidth: 700, minHeight: 500)
                .onAppear {
                    clipboardManager.startMonitoring()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Capture Clipboard") {
                    clipboardManager.captureClipboard()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])

                Button("Sync to Cloud") {
                    Task { @MainActor in
                        do {
                            let merged = try await cloudSync.sync(localItems: clipboardManager.items)
                            clipboardManager.items = merged
                        } catch {
                            print("Sync failed: \(error)")
                        }
                    }
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])

                Divider()

                Button("Export History...") {
                    exportHistory(clipboardManager: clipboardManager)
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])

                Button("Import History...") {
                    importHistory(clipboardManager: clipboardManager)
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])

                Divider()

                Button("Clear History") {
                    clipboardManager.clearAll()
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView()
                .environmentObject(clipboardManager)
                .environmentObject(cloudSync)
        }
    }
}

// Helper functions for export/import
func exportHistory(clipboardManager: ClipboardManager) {
    let panel = NSSavePanel()
    panel.allowedContentTypes = [.json]
    panel.nameFieldStringValue = "clipboard-history.json"
    panel.message = "Export clipboard history"

    panel.begin { response in
        guard response == .OK, let url = panel.url else { return }

        if let encoded = try? JSONEncoder().encode(clipboardManager.items) {
            try? encoded.write(to: url)
        }
    }
}

func importHistory(clipboardManager: ClipboardManager) {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.json]
    panel.message = "Import clipboard history"
    panel.allowsMultipleSelection = false

    panel.begin { response in
        guard response == .OK, let url = panel.url else { return }

        if let data = try? Data(contentsOf: url),
           let items = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            clipboardManager.items = items
        }
    }
}
