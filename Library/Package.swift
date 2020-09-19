// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Library",
    platforms: [.macOS(.v10_12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Library",
            targets: ["Library"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Kentzo/ShortcutRecorder.git", from: "3.3.0"),        
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Library",
            dependencies: [
                // swift 5.2 强制要求 package
                .product(name: "ShortcutRecorder",package: "ShortcutRecorder"),
                .product(name: "LaunchAtLogin",package: "LaunchAtLogin")
            ]),
        .testTarget(
            name: "LibraryTests",
            dependencies: ["Library"]),
    ]
)
