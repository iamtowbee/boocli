// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GhostClipboardKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "GhostClipboardKit",
            targets: ["GhostClipboardKit"]),
    ],
    dependencies: [
        // No external dependencies - pure Swift!
    ],
    targets: [
        .target(
            name: "GhostClipboardKit",
            dependencies: [],
            path: "Shared"),
    ]
)
