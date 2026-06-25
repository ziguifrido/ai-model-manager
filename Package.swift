// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyAIModels",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "AIModelManager", targets: ["AIModelManager"]),
        .executable(name: "AIModelManagerApp", targets: ["AIModelManagerApp"])
    ],
    targets: [
        .target(
            name: "AIModelManager",
            path: "Sources/AIModelManager"
        ),
        .executableTarget(
            name: "AIModelManagerApp",
            dependencies: ["AIModelManager"],
            path: "Sources/AIModelManagerApp"
        ),
        .testTarget(
            name: "AIModelManagerTests",
            dependencies: ["AIModelManager"],
            path: "Tests/AIModelManagerTests"
        )
    ]
)
