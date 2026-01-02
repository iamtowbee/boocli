//
//  CloudSyncManager.swift
//  GhostClipboard
//
//  Handles iCloud sync for clipboard items
//

import Foundation
import CloudKit
import Combine

class CloudSyncManager: ObservableObject {
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let recordType = "ClipboardItem"

    init() {
        container = CKContainer(identifier: "iCloud.com.ghostclipboard")
        privateDatabase = container.privateCloudDatabase
    }

    // Save item to iCloud
    func saveToCloud(_ item: ClipboardItem) async throws {
        let record = CKRecord(recordType: recordType)
        record["id"] = item.id.uuidString as CKRecordValue
        record["content"] = item.content as CKRecordValue
        record["timestamp"] = item.timestamp as CKRecordValue
        record["type"] = item.type.rawValue as CKRecordValue
        record["isFavorite"] = item.isFavorite as CKRecordValue
        record["tags"] = item.tags as CKRecordValue

        try await privateDatabase.save(record)
    }

    // Fetch all items from iCloud
    func fetchFromCloud() async throws -> [ClipboardItem] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        let (results, _) = try await privateDatabase.records(matching: query, resultsLimit: 100)

        var items: [ClipboardItem] = []

        for (_, result) in results {
            switch result {
            case .success(let record):
                if let item = clipboardItem(from: record) {
                    items.append(item)
                }
            case .failure(let error):
                print("Error fetching record: \(error)")
            }
        }

        return items
    }

    // Sync: upload local items and download cloud items
    func sync(localItems: [ClipboardItem]) async throws -> [ClipboardItem] {
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncError = nil
        }

        defer {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
            }
        }

        // Fetch cloud items
        let cloudItems = try await fetchFromCloud()

        // Merge logic: prefer newer items
        var mergedItems: [UUID: ClipboardItem] = [:]

        // Add cloud items
        for item in cloudItems {
            mergedItems[item.id] = item
        }

        // Add local items (will override if newer)
        for item in localItems {
            if let existing = mergedItems[item.id] {
                // Keep the newer one
                if item.timestamp > existing.timestamp {
                    mergedItems[item.id] = item
                }
            } else {
                mergedItems[item.id] = item
            }
        }

        // Upload new local items to cloud
        for item in localItems {
            if !cloudItems.contains(where: { $0.id == item.id }) {
                try? await saveToCloud(item)
            }
        }

        return Array(mergedItems.values).sorted { $0.timestamp > $1.timestamp }
    }

    // Convert CKRecord to ClipboardItem
    private func clipboardItem(from record: CKRecord) -> ClipboardItem? {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let content = record["content"] as? String,
              let timestamp = record["timestamp"] as? Date,
              let typeString = record["type"] as? String,
              let type = ClipboardItemType(rawValue: typeString) else {
            return nil
        }

        let isFavorite = record["isFavorite"] as? Bool ?? false
        let tags = record["tags"] as? [String] ?? []

        return ClipboardItem(
            id: id,
            content: content,
            timestamp: timestamp,
            type: type,
            isFavorite: isFavorite,
            tags: tags
        )
    }

    // Delete from cloud
    func deleteFromCloud(itemId: UUID) async throws {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(format: "id == %@", itemId.uuidString))
        let (results, _) = try await privateDatabase.records(matching: query)

        for (recordID, _) in results {
            try await privateDatabase.deleteRecord(withID: recordID)
        }
    }
}
