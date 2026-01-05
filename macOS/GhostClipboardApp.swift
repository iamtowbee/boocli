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
