// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SystemEagleEye",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "SystemEagleEye", targets: ["SystemEagleEye"])
    ],
    targets: [
        .executableTarget(
            name: "SystemEagleEye",
            path: "Sources/SystemEagleEye",
            exclude: ["Info.plist"]
        )
    ]
)
