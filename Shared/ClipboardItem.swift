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
        "The spirits are pleased with your clipboard hygiene! 🔮",
        "Your clipboard souls are eternal in the cloud! ☁️",
        "Beware: zombie pastes from the past approach! 🧟",
        "The ghosts of clipboards past visit you tonight... 👁️",
        "In the spirit realm, nothing is ever truly deleted! 💀",
        "Your copy history echoes through eternity... 🌙"
    ]

    static let fortunes = [
        "A mysterious presence watches over your code tonight... 👁️",
        "Beware of bugs that lurk in the shadows of your semicolons...",
        "Your next commit will haunt the repository forever... choose wisely.",
        "Three merge conflicts shall appear before the moon is full.",
        "The spirit of a forgotten TODO comment calls out to you...",
        "Your code will compile on the first try... said no ghost ever.",
        "A phantom variable hovers nearby, undefined and restless.",
        "The ancient curse of 'works on my machine' shall be lifted... eventually.",
        "Beware: a wild null pointer approaches at midnight.",
        "The ghost of technical debt past shall visit you soon.",
        "Your pull request shall be approved... in the afterlife. 💀",
        "The spirits foresee... a production deploy on Friday. Run! 🏃",
        "A cursed dependency shall haunt your package manager. 📦"
    ]

    static let stories = [
        (title: "The Infinite Loop", story: """
        Long ago, a developer wrote a while loop without a break condition.
        They say on quiet nights, you can still hear the CPU fan spinning...
        The program runs to this day, in a server room no one dares to enter.
        Some say the developer is still there, waiting for the loop to end...

        But it never does. It. Never. Does. 👻
        """),
        (title: "The Missing Semicolon", story: """
        In the depths of a legacy codebase, there lived a bug.
        Not just any bug - a bug that appeared only in production.
        Developers searched for years, but found nothing in their tests.
        One night, a junior dev stayed late, and finally saw it...

        A single missing semicolon, hiding in plain sight.
        But when they went to fix it... the line had vanished.
        To this day, the bug still haunts production. 🌙
        """),
        (title: "The Haunted Repository", story: """
        They say never to clone the cursed repository.
        But the new intern didn't believe in superstitions.
        'git clone' they typed, confident and unafraid.

        The download began: 1GB... 10GB... 100GB of node_modules.
        It never stopped. The hard drive filled completely.
        When they looked at their terminal, a message appeared:

        'npm install is now haunting your dreams... forever.' 💀
        """),
        (title: "The Phantom Commit", story: """
        In every codebase, there are commits from [deleted user].
        No one knows who they were, or where they went.
        But their code remains, undocumented and mysterious.

        Legend says if you run 'git blame' at 3 AM,
        You'll see commits from tomorrow, written by no one,
        Fixing bugs that haven't happened yet. ⏰
        """)
    ]

    static func random() -> String {
        hauntingMessages.randomElement() ?? "👻"
    }

    static func randomFortune() -> String {
        fortunes.randomElement() ?? "The spirits are silent... 🌙"
    }

    static func randomStory() -> (title: String, story: String) {
        stories.randomElement() ?? (title: "The Ghost", story: "Boo! 👻")
    }
}
