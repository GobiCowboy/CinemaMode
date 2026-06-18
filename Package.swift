// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CinemaMode",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CinemaModeCore",
            targets: ["CinemaModeCore"]
        ),
        .executable(
            name: "CinemaMode",
            targets: ["CinemaMode"]
        )
    ],
    targets: [
        .target(
            name: "CinemaModeCore"
        ),
        .executableTarget(
            name: "CinemaMode",
            dependencies: ["CinemaModeCore"]
        ),
        .testTarget(
            name: "CinemaModeCoreTests",
            dependencies: ["CinemaModeCore"]
        )
    ]
)

