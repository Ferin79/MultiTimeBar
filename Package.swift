// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MultiTime",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MultiTime", targets: ["MultiTime"])
    ],
    targets: [
        .executableTarget(
            name: "MultiTime",
            path: "Sources/MultiTime"
        )
    ]
)
