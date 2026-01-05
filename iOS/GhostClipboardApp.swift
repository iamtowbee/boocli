//
//  GhostClipboardApp.swift
//  GhostClipboard for iOS
//
//  A spooky clipboard manager for your iPhone and iPad! 👻
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
                .onAppear {
                    // iOS: manual capture or paste to add items
                    loadInitialData()
                }
        }
    }

    private func loadInitialData() {
        // Sync from cloud on launch
        Task {
            do {
                let cloudItems = try await cloudSync.fetchFromCloud()
                await MainActor.run {
                    if clipboardManager.items.isEmpty {
                        clipboardManager.items = cloudItems
                    }
                }
            } catch {
                print("Failed to load from cloud: \(error)")
            }
        }
    }
}
