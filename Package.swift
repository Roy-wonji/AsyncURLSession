// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncURLSession",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "AsyncURLSession",
            targets: ["AsyncURLSession"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Roy-wonji/LogMacro.git", from: "1.1.1")
    ],
    targets: [
        .target(
            name: "AsyncURLSession",
            dependencies: [
                "LogMacro"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AsyncURLSessionTests",
            dependencies: ["AsyncURLSession"]
        ),
    ]
)
