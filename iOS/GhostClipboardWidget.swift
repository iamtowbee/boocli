//
//  GhostClipboardWidget.swift
//  GhostClipboard Widget
//
//  Shows recent clipboard items on your home screen
//

import WidgetKit
import SwiftUI

struct ClipboardEntry: TimelineEntry {
    let date: Date
    let items: [ClipboardItem]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ClipboardEntry {
        ClipboardEntry(date: Date(), items: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (ClipboardEntry) -> Void) {
        let entry = ClipboardEntry(date: Date(), items: loadItems())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClipboardEntry>) -> Void) {
        let items = loadItems()
        let entry = ClipboardEntry(date: Date(), items: items)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadItems() -> [ClipboardItem] {
        guard let data = UserDefaults(suiteName: "group.com.ghostclipboard")?.data(forKey: "clipboardHistory"),
              let items = try? JSONDecoder().decode([ClipboardItem].self, from: data) else {
            return []
        }
        return Array(items.prefix(5))
    }
}

struct GhostClipboardWidgetView: View {
    var entry: ClipboardEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("👻")
                    .font(.title)
                Text("Clipboard")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }

            if entry.items.isEmpty {
                VStack {
                    Spacer()
                    Text("No items yet")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ForEach(entry.items.prefix(3)) { item in
                    HStack(spacing: 4) {
                        Text(item.ghostEmoji)
                            .font(.caption)
                        Text(item.preview)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 2)
                }
            }

            Spacer()

            HStack {
                Spacer()
                Text("\(entry.items.count) items")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

@main
struct GhostClipboardWidget: Widget {
    let kind: String = "GhostClipboardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GhostClipboardWidgetView(entry: entry)
        }
        .configurationDisplayName("GhostClipboard")
        .description("Recent clipboard items")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct GhostClipboardWidget_Previews: PreviewProvider {
    static var previews: some View {
        GhostClipboardWidgetView(entry: ClipboardEntry(date: Date(), items: [
            ClipboardItem(content: "Example text", type: .text),
            ClipboardItem(content: "https://example.com", type: .url)
        ]))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
