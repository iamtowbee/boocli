//
//  ClipboardManager.swift
//  GhostClipboard
//
//  Manages clipboard history and operations
//

import Foundation
import Combine

#if os(macOS)
import AppKit
typealias PlatformPasteboard = NSPasteboard
#else
import UIKit
typealias PlatformPasteboard = UIPasteboard
#endif

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var isMonitoring: Bool = false

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let maxItems = 100

    init() {
        loadFromUserDefaults()
    }

    // Start monitoring clipboard
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        #if os(macOS)
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        #endif
    }

    // Stop monitoring clipboard
    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }

    // Check for clipboard changes (macOS)
    private func checkClipboard() {
        #if os(macOS)
        let currentChangeCount = NSPasteboard.general.changeCount
        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount
            captureClipboard()
        }
        #endif
    }

    // Capture current clipboard content
    func captureClipboard() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general

        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            // Don't add duplicates if the last item is the same
            if let lastItem = items.first, lastItem.content == string {
                return
            }

            let type = detectType(for: string)
            let item = ClipboardItem(content: string, type: type)
            addItem(item)
        }
        #else
        let pasteboard = UIPasteboard.general

        if let string = pasteboard.string, !string.isEmpty {
            if let lastItem = items.first, lastItem.content == string {
                return
            }

            let type = detectType(for: string)
            let item = ClipboardItem(content: string, type: type)
            addItem(item)
        }
        #endif
    }

    // Add item to history
    func addItem(_ item: ClipboardItem) {
        items.insert(item, at: 0)

        // Limit history size
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }

        saveToUserDefaults()
    }

    // Copy item back to clipboard
    func copyToClipboard(_ item: ClipboardItem) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        #else
        UIPasteboard.general.string = item.content
        #endif
    }

    // Delete item
    func deleteItem(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        saveToUserDefaults()
    }

    // Toggle favorite
    func toggleFavorite(_ item: ClipboardItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }

    // Clear all history
    func clearAll() {
        items.removeAll()
        saveToUserDefaults()
    }

    // Detect content type
    private func detectType(for content: String) -> ClipboardItemType {
        // URL detection
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let matches = detector.matches(in: content, range: NSRange(content.startIndex..., in: content))
            if !matches.isEmpty {
                return .url
            }
        }

        // Code detection (simple heuristic)
        let codePatterns = ["func ", "def ", "class ", "import ", "const ", "let ", "var ", "function ", "{", "}", ";"]
        if codePatterns.contains(where: { content.contains($0) }) {
            return .code
        }

        return .text
    }

    // Persistence
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "clipboardHistory")
        }
    }

    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "clipboardHistory"),
           let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            items = decoded
        }
    }
}
