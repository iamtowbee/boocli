//
//  ContentView.swift
//  GhostClipboard for iOS
//
//  Main view for the iOS app
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @EnvironmentObject var cloudSync: CloudSyncManager
    @State private var selectedTab = 0
    @State private var showingSettings = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Clipboard History
            ClipboardHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(0)

            // Favorites
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
                .tag(1)

            // Ghost Mode (Fun feature)
            GhostModeView()
                .tabItem {
                    Label("Ghost", systemImage: "moon.stars.fill")
                }
                .tag(2)
        }
        .accentColor(.purple)
    }
}

struct ClipboardHistoryView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @EnvironmentObject var cloudSync: CloudSyncManager
    @State private var searchText = ""
    @State private var selectedFilter: ClipboardItemType?
    @State private var showingAddSheet = false

    var filteredItems: [ClipboardItem] {
        var items = clipboardManager.items

        if let filter = selectedFilter {
            items = items.filter { $0.type == filter }
        }

        if !searchText.isEmpty {
            items = items.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }

        return items
    }

    var body: some View {
        NavigationView {
            VStack {
                // Filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        FilterPill(title: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }

                        ForEach(ClipboardItemType.allCases, id: \.self) { type in
                            FilterPill(
                                title: type.rawValue.capitalized,
                                icon: type.icon,
                                color: type.color,
                                isSelected: selectedFilter == type
                            ) {
                                selectedFilter = type
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                // Items list
                if filteredItems.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Text("👻")
                            .font(.system(size: 80))
                        Text("No clipboard items yet!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Tap + to add an item from your clipboard")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            ClipboardItemCard(item: item)
                                .environmentObject(clipboardManager)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search clipboard...")
                }
            }
            .navigationTitle("👻 GhostClipboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { syncToCloud() }) {
                        Image(systemName: cloudSync.isSyncing ? "icloud.and.arrow.up" : "icloud")
                    }
                    .disabled(cloudSync.isSyncing)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddClipboardItemSheet()
                    .environmentObject(clipboardManager)
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

struct FilterPill: View {
    let title: String
    var icon: String?
    var color: Color = .purple
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? color : .primary)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

struct ClipboardItemCard: View {
    let item: ClipboardItem
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var showingActionSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Ghost emoji
                Text(item.ghostEmoji)
                    .font(.title)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Label(item.type.rawValue.capitalized, systemImage: item.type.icon)
                            .font(.caption)
                            .foregroundColor(item.type.color)

                        Spacer()

                        if item.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }

                        Text(item.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Text(item.preview)
                .font(.body)
                .lineLimit(4)

            if !item.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(item.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.2))
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.isFavorite ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            clipboardManager.copyToClipboard(item)
            // Show feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        .onLongPressGesture {
            showingActionSheet = true
        }
        .confirmationDialog("Clipboard Item", isPresented: $showingActionSheet, titleVisibility: .visible) {
            Button("Copy to Clipboard") {
                clipboardManager.copyToClipboard(item)
            }

            Button(item.isFavorite ? "Remove from Favorites" : "Add to Favorites") {
                clipboardManager.toggleFavorite(item)
            }

            Button("Delete", role: .destructive) {
                clipboardManager.deleteItem(item)
            }

            Button("Cancel", role: .cancel) {}
        }
    }
}

struct FavoritesView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager

    var favoriteItems: [ClipboardItem] {
        clipboardManager.items.filter { $0.isFavorite }
    }

    var body: some View {
        NavigationView {
            if favoriteItems.isEmpty {
                VStack(spacing: 16) {
                    Text("⭐")
                        .font(.system(size: 80))
                    Text("No favorites yet!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Long press any item to add it to favorites")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .navigationTitle("Favorites")
            } else {
                List {
                    ForEach(favoriteItems) { item in
                        ClipboardItemCard(item: item)
                            .environmentObject(clipboardManager)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Favorites")
            }
        }
    }
}

struct GhostModeView: View {
    @State private var currentGhost = "👻"
    @State private var ghostMessage = GhostQuotes.random()
    @State private var isAnimating = false

    let ghosts = ["👻", "💀", "🎃", "🦇", "🕷️", "🕸️", "⚰️", "🔮", "🌙", "✨"]

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Text(currentGhost)
                    .font(.system(size: 120))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .rotationEffect(.degrees(isAnimating ? 10 : -10))
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)

                Text(ghostMessage)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    currentGhost = ghosts.randomElement() ?? "👻"
                    ghostMessage = GhostQuotes.random()
                }) {
                    Text("Summon New Ghost")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Ghost Mode")
            .onAppear {
                isAnimating = true
            }
        }
    }
}

struct AddClipboardItemSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var text = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add from Clipboard")
                    .font(.headline)

                Button(action: pasteFromClipboard) {
                    HStack {
                        Image(systemName: "doc.on.clipboard")
                        Text("Paste from Clipboard")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                Divider()

                Text("Or enter manually:")
                    .font(.headline)

                TextEditor(text: $text)
                    .frame(height: 200)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button(action: addManualItem) {
                    Text("Add Item")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(text.isEmpty ? Color.gray : Color.purple)
                        .cornerRadius(12)
                }
                .disabled(text.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func pasteFromClipboard() {
        if let pasteboardString = UIPasteboard.general.string {
            text = pasteboardString
            clipboardManager.captureClipboard()
            dismiss()
        }
    }

    private func addManualItem() {
        if !text.isEmpty {
            let item = ClipboardItem(content: text)
            clipboardManager.addItem(item)
            dismiss()
        }
    }
}
