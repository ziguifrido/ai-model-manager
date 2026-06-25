// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AIModelManager",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "AIModelManager", targets: ["AIModelManager"])
    ],
    targets: [
        .target(
            name: "AIModelManager",
            path: "AIModelManager",
            exclude: ["App", "Views", "ViewModels", "Resources", "Assets.xcassets", "Tests"]
        ),
        .testTarget(
            name: "AIModelManagerTests",
            dependencies: ["AIModelManager"],
            path: "AIModelManager/Tests/AIModelManagerTests"
        )
    ]
)
