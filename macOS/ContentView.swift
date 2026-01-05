//
//  ContentView.swift
//  GhostClipboard for macOS
//
//  Main view for the macOS app
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @EnvironmentObject var cloudSync: CloudSyncManager
    @State private var searchText = ""
    @State private var selectedFilter: ClipboardItemType?
    @State private var showingGhost = true
    @State private var ghostMessage = GhostQuotes.random()
    @State private var ghostOpacity = 1.0

    var filteredItems: [ClipboardItem] {
        var items = clipboardManager.items

        // Filter by type
        if let filter = selectedFilter {
            items = items.filter { $0.type == filter }
        }

        // Search
        if !searchText.isEmpty {
            items = items.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }

        return items
    }

    var body: some View {
        NavigationView {
            // Sidebar
            VStack(spacing: 0) {
                // Ghost mascot
                VStack {
                    Text("👻")
                        .font(.system(size: 60))
                        .opacity(ghostOpacity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                ghostOpacity = 0.5
                            }
                        }

                    Text("GhostClipboard")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(ghostMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .onTapGesture {
                            ghostMessage = GhostQuotes.random()
                        }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple.opacity(0.1))

                Divider()

                // Filters
                List {
                    Section("Filters") {
                        Button(action: { selectedFilter = nil }) {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text("All Items")
                                Spacer()
                                Text("\(clipboardManager.items.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)

                        ForEach(ClipboardItemType.allCases, id: \.self) { type in
                            Button(action: { selectedFilter = type }) {
                                HStack {
                                    Image(systemName: type.icon)
                                        .foregroundColor(type.color)
                                    Text(type.rawValue.capitalized)
                                    Spacer()
                                    let count = clipboardManager.items.filter { $0.type == type }.count
                                    Text("\(count)")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Section("Quick Actions") {
                        Button(action: { clipboardManager.captureClipboard() }) {
                            HStack {
                                Image(systemName: "doc.on.clipboard")
                                Text("Capture Now")
                            }
                        }

                        Button(action: { syncToCloud() }) {
                            HStack {
                                Image(systemName: cloudSync.isSyncing ? "icloud.and.arrow.up" : "icloud")
                                Text(cloudSync.isSyncing ? "Syncing..." : "Sync to Cloud")
                            }
                        }
                        .disabled(cloudSync.isSyncing)
                    }
                }
                .listStyle(.sidebar)
            }
            .frame(width: 250)

            // Main content
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search clipboard...", text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

                // Clipboard items
                if filteredItems.isEmpty {
                    VStack {
                        Spacer()
                        Text("🦇")
                            .font(.system(size: 80))
                        Text("No items yet...")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Copy something to get started!")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredItems) { item in
                                ClipboardItemRow(item: item)
                                    .environmentObject(clipboardManager)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }

    private func syncToCloud() {
        Task {
            do {
                let mergedItems = try await cloudSync.sync(localItems: clipboardManager.items)
                await MainActor.run {
                    clipboardManager.items = mergedItems
                }
            } catch {
                print("Sync error: \(error)")
            }
        }
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Ghost emoji
            Text(item.ghostEmoji)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 4) {
                // Type and timestamp
                HStack {
                    Label(item.type.rawValue.capitalized, systemImage: item.type.icon)
                        .font(.caption)
                        .foregroundColor(item.type.color)

                    Spacer()

                    Text(item.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Content preview
                Text(item.preview)
                    .font(.body)
                    .lineLimit(3)
                    .textSelection(.enabled)

                // Tags
                if !item.tags.isEmpty {
                    HStack {
                        ForEach(item.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.purple.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }

            Spacer()

            // Actions
            if isHovered {
                HStack(spacing: 8) {
                    Button(action: { clipboardManager.toggleFavorite(item) }) {
                        Image(systemName: item.isFavorite ? "star.fill" : "star")
                            .foregroundColor(item.isFavorite ? .yellow : .secondary)
                    }
                    .buttonStyle(.plain)

                    Button(action: { clipboardManager.copyToClipboard(item) }) {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.plain)

                    Button(action: { clipboardManager.deleteItem(item) }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(isHovered ? Color.purple.opacity(0.05) : Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(item.isFavorite ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            CloudSettingsView()
                .tabItem {
                    Label("Cloud Sync", systemImage: "icloud")
                }
        }
        .frame(width: 450, height: 300)
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager

    var body: some View {
        Form {
            Section {
                Toggle("Monitor Clipboard Automatically", isOn: .constant(clipboardManager.isMonitoring))
                    .onChange(of: clipboardManager.isMonitoring) { newValue in
                        if newValue {
                            clipboardManager.startMonitoring()
                        } else {
                            clipboardManager.stopMonitoring()
                        }
                    }

                HStack {
                    Text("Clipboard Items:")
                    Spacer()
                    Text("\(clipboardManager.items.count) items")
                        .foregroundColor(.secondary)
                }

                Button("Clear All History") {
                    clipboardManager.clearAll()
                }
                .foregroundColor(.red)
            }
        }
        .padding()
    }
}

struct CloudSettingsView: View {
    @EnvironmentObject var cloudSync: CloudSyncManager

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Sync Status:")
                    Spacer()
                    if cloudSync.isSyncing {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Syncing...")
                            .foregroundColor(.secondary)
                    } else {
                        Text("Ready")
                            .foregroundColor(.green)
                    }
                }

                if let lastSync = cloudSync.lastSyncDate {
                    HStack {
                        Text("Last Sync:")
                        Spacer()
                        Text(lastSync, style: .relative)
                            .foregroundColor(.secondary)
                    }
                }

                if let error = cloudSync.syncError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            Section {
                Text("💀 Cloud storage keeps your clipboard safe in the spirit realm!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
