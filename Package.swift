// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Jobcan",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Jobcan",
            path: "Sources/Jobcan"
        )
    ]
)
