#!/usr/bin/env swift
//
//  main.swift
//  GhostClipboard CLI
//
//  Interactive shell interface for GhostClipboard
//  Shares data with the macOS GUI app
//

import Foundation
import AppKit

// MARK: - ANSI Colors
enum ANSIColor: String {
    case reset = "\u{001B}[0m"
    case bold = "\u{001B}[1m"
    case dim = "\u{001B}[2m"

    case black = "\u{001B}[30m"
    case red = "\u{001B}[31m"
    case green = "\u{001B}[32m"
    case yellow = "\u{001B}[33m"
    case blue = "\u{001B}[34m"
    case magenta = "\u{001B}[35m"
    case cyan = "\u{001B}[36m"
    case white = "\u{001B}[37m"

    case bgBlack = "\u{001B}[40m"
    case bgRed = "\u{001B}[41m"
    case bgGreen = "\u{001B}[42m"
    case bgYellow = "\u{001B}[43m"
    case bgBlue = "\u{001B}[44m"
    case bgMagenta = "\u{001B}[45m"
    case bgCyan = "\u{001B}[46m"
    case bgWhite = "\u{001B}[47m"

    case purple = "\u{001B}[95m"
    case brightCyan = "\u{001B}[96m"
}

func colored(_ text: String, _ color: ANSIColor, bold: Bool = false) -> String {
    let prefix = bold ? ANSIColor.bold.rawValue + color.rawValue : color.rawValue
    return prefix + text + ANSIColor.reset.rawValue
}

// MARK: - Clipboard Item (matches SwiftUI version)
struct ClipboardItem: Codable {
    let id: UUID
    let content: String
    let timestamp: Date
    let type: String
    var isFavorite: Bool
    var tags: [String]

    var preview: String {
        let maxLength = 100
        if content.count > maxLength {
            return String(content.prefix(maxLength)) + "..."
        }
        return content
    }

    var ghostEmoji: String {
        let ghosts = ["👻", "🎃", "💀", "🦇", "🕷️", "🕸️", "⚰️", "🔮"]
        let index = abs(id.hashValue) % ghosts.count
        return ghosts[index]
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

// MARK: - Ghost Quotes
let ghostQuotes = [
    "Boo! Your clipboard is haunted! 👻",
    "I've been watching your copy-paste habits...",
    "Your clipboard history speaks volumes... spooky volumes! 📚",
    "Every paste summons us closer... 🕯️",
    "Copy, paste, and be merry... for tomorrow we haunt! ⚰️"
]

// MARK: - CLI Manager
class GhostClipboardCLI {
    var items: [ClipboardItem] = []
    var selectedIndex = 0
    var filterText = ""
    var showFavoritesOnly = false

    init() {
        loadItems()
    }

    func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "clipboardHistory"),
           let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            items = decoded
        }
    }

    func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "clipboardHistory")
        }
    }

    var filteredItems: [ClipboardItem] {
        var result = items

        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        if !filterText.isEmpty {
            result = result.filter { $0.content.localizedCaseInsensitiveContains(filterText) }
        }

        return result
    }

    func copyToClipboard(item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
    }

    func toggleFavorite(at index: Int) {
        guard index < items.count else { return }
        items[index].isFavorite.toggle()
        saveItems()
    }

    func deleteItem(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
        saveItems()
    }

    func exportToFile(path: String) -> Bool {
        guard let encoded = try? JSONEncoder().encode(items) else { return false }
        do {
            try encoded.write(to: URL(fileURLWithPath: path))
            return true
        } catch {
            return false
        }
    }

    func importFromFile(path: String) -> Bool {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) else {
            return false
        }
        items = decoded
        saveItems()
        return true
    }
}

// MARK: - UI Rendering
class UI {
    static func clearScreen() {
        print("\u{001B}[2J\u{001B}[H", terminator: "")
    }

    static func moveCursor(row: Int, col: Int) {
        print("\u{001B}[\(row);\(col)H", terminator: "")
    }

    static func hideCursor() {
        print("\u{001B}[?25l", terminator: "")
    }

    static func showCursor() {
        print("\u{001B}[?25h", terminator: "")
    }

    static func drawBox(x: Int, y: Int, width: Int, height: Int, title: String = "") {
        moveCursor(row: y, col: x)
        print("┌" + String(repeating: "─", count: width - 2) + "┐")

        for i in 1..<height-1 {
            moveCursor(row: y + i, col: x)
            print("│" + String(repeating: " ", count: width - 2) + "│")
        }

        moveCursor(row: y + height - 1, col: x)
        print("└" + String(repeating: "─", count: width - 2) + "┘")

        if !title.isEmpty {
            moveCursor(row: y, col: x + 2)
            print(" \(title) ")
        }
    }

    static func getTerminalSize() -> (width: Int, height: Int) {
        var size = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &size) == 0 {
            return (Int(size.ws_col), Int(size.ws_row))
        }
        return (80, 24)
    }
}

// MARK: - Main App
func renderUI(cli: GhostClipboardCLI) {
    UI.clearScreen()
    let (width, height) = UI.getTerminalSize()

    // Header
    let header = "👻 GhostClipboard CLI 👻"
    let quote = ghostQuotes.randomElement() ?? ""

    print(colored(String(repeating: "═", count: width), .purple, bold: true))
    print(colored(header.padding(toLength: width, withPad: " ", startingAt: 0), .purple, bold: true))
    print(colored(quote.padding(toLength: width, withPad: " ", startingAt: 0), .cyan))
    print(colored(String(repeating: "═", count: width), .purple, bold: true))

    // Filter info
    var filterInfo = "Items: \(cli.filteredItems.count)"
    if cli.showFavoritesOnly {
        filterInfo += " ⭐ Favorites"
    }
    if !cli.filterText.isEmpty {
        filterInfo += " | Search: '\(cli.filterText)'"
    }
    print(colored(filterInfo, .dim))
    print()

    // Items list
    let items = cli.filteredItems
    if items.isEmpty {
        print(colored("  No items found! 🦇", .yellow))
        print(colored("  Copy something to add it to your clipboard history.", .dim))
    } else {
        for (index, item) in items.prefix(height - 12).enumerated() {
            let isSelected = index == cli.selectedIndex
            let prefix = isSelected ? colored("▶ ", .green, bold: true) : "  "
            let ghost = item.ghostEmoji
            let favorite = item.isFavorite ? "⭐" : "  "
            let typeIcon = getTypeIcon(item.type)
            let time = colored("[\(item.timeAgo)]", .dim)

            let line = "\(prefix)\(ghost) \(favorite) \(typeIcon) "
            let contentMaxLength = width - 30
            let contentPreview = String(item.preview.prefix(contentMaxLength))

            if isSelected {
                print(colored(line + contentPreview, .cyan, bold: true) + " " + time)
            } else {
                print(line + contentPreview + " " + time)
            }
        }
    }

    // Footer with commands
    print()
    print(colored(String(repeating: "─", count: width), .purple))
    print(colored("Commands:", .purple, bold: true))
    print("  ↑/↓ Navigate  | " + colored("ENTER", .green) + " Copy  | " +
          colored("P", .cyan) + " Preview  | " +
          colored("F", .yellow) + " Favorite  | " +
          colored("D", .red) + " Delete")
    print("  " + colored("/", .cyan) + " Search  | " +
          colored("*", .yellow) + " Favorites  | " +
          colored("E", .blue) + " Export  | " +
          colored("I", .blue) + " Import  | " +
          colored("Q", .red) + " Quit")
    print(colored(String(repeating: "─", count: width), .purple))
}

func getTypeIcon(_ type: String) -> String {
    switch type {
    case "url": return "🔗"
    case "code": return "💻"
    case "image": return "🖼️"
    default: return "📝"
    }
}

// MARK: - Input Handling
func setupRawMode() {
    var term = termios()
    tcgetattr(STDIN_FILENO, &term)
    var raw = term
    raw.c_lflag &= ~(UInt(ECHO | ICANON))
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
}

func restoreTerminal() {
    var term = termios()
    tcgetattr(STDIN_FILENO, &term)
    term.c_lflag |= UInt(ECHO | ICANON)
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &term)
}

func readKey() -> String? {
    var char: UInt8 = 0
    let count = read(STDIN_FILENO, &char, 1)

    if count <= 0 {
        return nil
    }

    // Handle escape sequences (arrow keys)
    if char == 27 { // ESC
        var seq1: UInt8 = 0
        var seq2: UInt8 = 0

        if read(STDIN_FILENO, &seq1, 1) == 1 && read(STDIN_FILENO, &seq2, 1) == 1 {
            if seq1 == 91 { // [
                switch seq2 {
                case 65: return "UP"
                case 66: return "DOWN"
                case 67: return "RIGHT"
                case 68: return "LEFT"
                default: break
                }
            }
        }
    }

    return String(UnicodeScalar(char))
}

// MARK: - Main Loop
func runInteractiveMode() {
    let cli = GhostClipboardCLI()

    setupRawMode()
    UI.hideCursor()

    defer {
        restoreTerminal()
        UI.showCursor()
        UI.clearScreen()
        print("👻 The ghost fades away... until next time!\n")
    }

    var running = true
    var searchMode = false

    while running {
        renderUI(cli: cli)

        if searchMode {
            UI.showCursor()
            print("\nSearch: \(cli.filterText)_")
        }

        guard let key = readKey() else { continue }

        if searchMode {
            if key == "\n" || key == "\r" {
                searchMode = false
                UI.hideCursor()
            } else if key == "\u{7F}" || key == "\u{08}" { // Backspace
                if !cli.filterText.isEmpty {
                    cli.filterText.removeLast()
                }
            } else if key.count == 1 && key.unicodeScalars.first!.value >= 32 {
                cli.filterText += key
            }
            continue
        }

        switch key.uppercased() {
        case "UP":
            if cli.selectedIndex > 0 {
                cli.selectedIndex -= 1
            }

        case "DOWN":
            if cli.selectedIndex < cli.filteredItems.count - 1 {
                cli.selectedIndex += 1
            }

        case "\n", "\r": // Enter
            if !cli.filteredItems.isEmpty && cli.selectedIndex < cli.filteredItems.count {
                let item = cli.filteredItems[cli.selectedIndex]
                cli.copyToClipboard(item: item)

                // Show confirmation
                UI.clearScreen()
                print("\n" + colored("  ✅ Copied to clipboard!", .green, bold: true))
                print(colored("  \(item.preview)", .cyan))
                print("\n  Press any key to continue...")
                _ = readKey()
            }

        case "F": // Toggle favorite
            if !cli.filteredItems.isEmpty && cli.selectedIndex < cli.filteredItems.count {
                let item = cli.filteredItems[cli.selectedIndex]
                if let originalIndex = cli.items.firstIndex(where: { $0.id == item.id }) {
                    cli.toggleFavorite(at: originalIndex)
                }
            }

        case "D": // Delete
            if !cli.filteredItems.isEmpty && cli.selectedIndex < cli.filteredItems.count {
                let item = cli.filteredItems[cli.selectedIndex]
                if let originalIndex = cli.items.firstIndex(where: { $0.id == item.id }) {
                    cli.deleteItem(at: originalIndex)
                    cli.selectedIndex = min(cli.selectedIndex, cli.filteredItems.count - 1)
                }
            }

        case "/": // Search mode
            searchMode = true
            cli.filterText = ""

        case "*": // Toggle favorites
            cli.showFavoritesOnly.toggle()
            cli.selectedIndex = 0

        case "R": // Refresh
            cli.loadItems()
            cli.selectedIndex = 0

        case "P": // Preview full item
            if !cli.filteredItems.isEmpty && cli.selectedIndex < cli.filteredItems.count {
                let item = cli.filteredItems[cli.selectedIndex]
                UI.clearScreen()
                print(colored("\n👻 Full Preview", .purple, bold: true))
                print(colored(String(repeating: "─", count: 50), .purple))
                print(colored("\nType: \(item.type) | Created: \(item.timeAgo)", .dim))
                if item.isFavorite {
                    print(colored("⭐ Favorite", .yellow))
                }
                print("")
                print(item.content)
                print(colored("\n" + String(repeating: "─", count: 50), .purple))
                print(colored("\nPress any key to return...", .dim))
                _ = readKey()
            }

        case "E": // Export
            UI.clearScreen()
            print(colored("\n💾 Export Clipboard History", .purple, bold: true))
            print("\nEnter file path (e.g., ~/clipboard-export.json):")
            UI.showCursor()
            if let path = readLine(), !path.isEmpty {
                let expandedPath = NSString(string: path).expandingTildeInPath
                if cli.exportToFile(path: expandedPath) {
                    print(colored("\n✅ Exported \(cli.items.count) items to \(expandedPath)", .green))
                } else {
                    print(colored("\n❌ Export failed!", .red))
                }
            }
            print("\nPress any key to continue...")
            UI.hideCursor()
            _ = readKey()

        case "I": // Import
            UI.clearScreen()
            print(colored("\n📥 Import Clipboard History", .purple, bold: true))
            print("\nEnter file path:")
            UI.showCursor()
            if let path = readLine(), !path.isEmpty {
                let expandedPath = NSString(string: path).expandingTildeInPath
                if cli.importFromFile(path: expandedPath) {
                    print(colored("\n✅ Imported \(cli.items.count) items from \(expandedPath)", .green))
                } else {
                    print(colored("\n❌ Import failed!", .red))
                }
            }
            print("\nPress any key to continue...")
            UI.hideCursor()
            _ = readKey()

        case "Q": // Quit
            running = false

        default:
            break
        }
    }
}

// MARK: - Entry Point
if CommandLine.arguments.contains("--help") || CommandLine.arguments.contains("-h") {
    print("""
    👻 GhostClipboard CLI

    Usage:
      ghostclip              Run interactive mode
      ghostclip --help       Show this help
      ghostclip --list       List all items
      ghostclip --last       Copy last item

    Fun Extras:
      ghostclip --fortune    Get a spooky fortune
      ghostclip --haunt      Get haunted by a ghost
      ghostclip --story      Hear a ghost story

    Interactive Mode Commands:
      ↑/↓         Navigate items
      ENTER       Copy selected item to clipboard
      P           Preview full item
      F           Toggle favorite
      D           Delete item
      /           Search
      *           Show favorites only
      E           Export to file
      I           Import from file
      R           Refresh from disk
      Q           Quit

    The CLI shares clipboard history with the GhostClipboard macOS app!
    """)
    exit(0)
}

if CommandLine.arguments.contains("--list") {
    let cli = GhostClipboardCLI()
    print(colored("👻 GhostClipboard History", .purple, bold: true))
    print(colored(String(repeating: "─", count: 50), .purple))

    for (index, item) in cli.items.prefix(20).enumerated() {
        print("\(item.ghostEmoji) [\(index + 1)] \(item.preview)")
        print(colored("   \(item.timeAgo) | \(item.type)", .dim))
    }
    exit(0)
}

if CommandLine.arguments.contains("--last") {
    let cli = GhostClipboardCLI()
    if let last = cli.items.first {
        cli.copyToClipboard(item: last)
        print(colored("✅ Copied: ", .green) + last.preview)
    } else {
        print(colored("❌ No clipboard history found!", .red))
    }
    exit(0)
}

// Fun extras!
if CommandLine.arguments.contains("--fortune") {
    let fortunes = [
        "A mysterious presence watches over your code tonight... 👁️",
        "Beware of bugs that lurk in the shadows of your semicolons...",
        "Your next commit will haunt the repository forever... choose wisely.",
        "Three merge conflicts shall appear before the moon is full.",
        "The spirit of a forgotten TODO comment calls out to you...",
        "Your code will compile on the first try... said no ghost ever.",
        "A phantom variable hovers nearby, undefined and restless.",
        "The ancient curse of 'works on my machine' shall be lifted... eventually.",
        "Beware: a wild null pointer approaches at midnight.",
        "The ghost of technical debt past shall visit you soon."
    ]
    print(colored("\n🔮 The Ghost King peers into your future... 🔮\n", .purple, bold: true))
    usleep(500_000)
    print(colored(fortunes.randomElement()!, .yellow, bold: true))
    print("")
    exit(0)
}

if CommandLine.arguments.contains("--haunt") {
    let messages = [
        "BOO! Did I scare you? 👻",
        "Debugging at this hour? How... spooky! 🕯️",
        "I see dead code... it's everywhere! 💀",
        "Your console.logs can't save you now! 🔮",
        "Commit your changes... before they disappear! ⚰️",
        "I've been watching your git history... interesting choices. 📜",
        "The spirits sense... a memory leak! 🌙",
        "Wooooooo! Stack overflow! Wooooooo! 👁️"
    ]
    print(colored("\n       .--.", .cyan))
    print(colored("      |o_o |", .cyan))
    print(colored("      |:_/ |", .cyan))
    print(colored("     //   \\ \\", .cyan))
    print(colored("    (|     | )", .cyan))
    print(colored("   /'\\   _/`\\", .cyan))
    print(colored("   \\___)=(___/\n", .cyan))
    usleep(500_000)
    print(colored(messages.randomElement()!, .white, bold: true))
    print("")
    exit(0)
}

if CommandLine.arguments.contains("--story") {
    let stories = [
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
        """)
    ]
    let story = stories.randomElement()!
    print(colored("\n📖 " + story.title + " 📖\n", .red, bold: true))
    usleep(500_000)
    for line in story.story.split(separator: "\n") {
        print(colored(String(line), .white))
        usleep(300_000)
    }
    print("")
    exit(0)
}

// Default: run interactive mode
runInteractiveMode()
