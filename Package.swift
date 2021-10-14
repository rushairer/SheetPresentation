// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SheetPresentation",
    platforms: [.iOS(.v14), .watchOS(.v7), .macOS(.v11), .tvOS(.v14)],
    products: [
        .library(
            name: "SheetPresentation",
            targets: ["SheetPresentation"]),
    ],
    dependencies: [
        .package(name: "RoundedCorners", url: "https://github.com/rushairer/RoundedCorners", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "SheetPresentation",
            dependencies: [
                "RoundedCorners"
            ]),
        .testTarget(
            name: "SheetPresentationTests",
            dependencies: ["SheetPresentation"]),
    ],
    swiftLanguageVersions: [.v5]
)
