//
//  ClipboardItem.swift
//  GhostClipboard
//
//  Shared data models for clipboard items
//

import Foundation
import SwiftUI

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let content: String
    let timestamp: Date
    let type: ClipboardItemType
    var isFavorite: Bool
    var tags: [String]

    init(id: UUID = UUID(), content: String, timestamp: Date = Date(), type: ClipboardItemType = .text, isFavorite: Bool = false, tags: [String] = []) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.type = type
        self.isFavorite = isFavorite
        self.tags = tags
    }

    var preview: String {
        let maxLength = 100
        if content.count > maxLength {
            return String(content.prefix(maxLength)) + "..."
        }
        return content
    }

    var ghostEmoji: String {
        // Different ghost emojis based on content type or time
        let ghosts = ["👻", "🎃", "💀", "🦇", "🕷️", "🕸️", "⚰️", "🔮"]
        let index = abs(id.hashValue) % ghosts.count
        return ghosts[index]
    }
}

enum ClipboardItemType: String, Codable, CaseIterable {
    case text = "text"
    case url = "url"
    case image = "image"
    case code = "code"

    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .url: return "link"
        case .image: return "photo"
        case .code: return "chevron.left.forwardslash.chevron.right"
        }
    }

    var color: Color {
        switch self {
        case .text: return .purple
        case .url: return .blue
        case .image: return .pink
        case .code: return .green
        }
    }
}

// Ghost quotes and messages
struct GhostQuotes {
    static let hauntingMessages = [
        "Boo! Your clipboard is haunted! 👻",
        "I've been watching your copy-paste habits...",
        "Your clipboard history speaks volumes... spooky volumes! 📚",
        "Ctrl+C, Ctrl+V... the ghost approves! ✨",
        "This clipboard is now property of the spirit realm! 🌙",
        "Every paste summons us closer... 🕯️",
        "Your clipboard is looking spooktacular today! 💀",
        "We ghosts never forget... unlike your clipboard! 🦇",
        "Copy, paste, and be merry... for tomorrow we haunt! ⚰️",
        "The spirits are pleased with your clipboard hygiene! 🔮"
    ]

    static func random() -> String {
        hauntingMessages.randomElement() ?? "👻"
    }
}
