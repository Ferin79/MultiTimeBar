// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MultiTimeBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MultiTimeBar", targets: ["MultiTimeBar"])
    ],
    targets: [
        .executableTarget(
            name: "MultiTimeBar",
            path: "Sources/MultiTimeBar"
        )
    ]
)
