// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncURLSession",
    products: [
        .library(
            name: "AsyncURLSession",
            targets: ["AsyncURLSession"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/Roy-wonji/LogMacro.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "AsyncURLSession",
            dependencies: [
//                .product(name: "LogMacro", package: "LogMacro"),
            ],
            linkerSettings: [
                .linkedFramework("OSLog")
            ]
        ),
        .testTarget(
            name: "AsyncURLSessionTests",
            dependencies: ["AsyncURLSession"]
        ),
    ]
)
