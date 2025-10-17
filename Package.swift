// swift-tools-version:6.2
import PackageDescription


let package: Package = Package(
    name: "swift-macho",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .library(
            name: "SwiftMachO",
            targets: ["SwiftMachO"]),
        .executable(
            name: "macho",
            targets: ["macho"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-asn1.git", from: "1.3.2"),
        .package(url: "https://github.com/apple/swift-certificates.git", from: "1.10.0"),
        // .package(url: "https://github.com/apple/swift-binary-parsing.git", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-binary-parsing.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "SwiftMachO",
            dependencies: [
                .product(name: "BinaryParsing", package: "swift-binary-parsing"),
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "X509", package: "swift-certificates"),
            ],
            path: "Sources/SwiftMachO"
        ),
        // .testTarget(
        //     name: "SwiftMachoTests",
        //     dependencies: ["SwiftMacho"],
        //     path: "Tests/SwiftMachoTests"
        // ),
        .executableTarget(name: "macho", dependencies: [
            "SwiftMachO",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ])
    ]
)
