// swift-tools-version:6.2
import PackageDescription
import CompilerPluginSupport

let package: Package = Package(
    name: "swift-macho",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .library(
            name: "SwiftMachO",
            targets: ["SwiftMachO"]),
//        .library(
//            name: "SwiftMachOMacros",
//            targets: ["SwiftMachO"]
//        ),
        .executable(
            name: "macho",
            targets: ["macho"]),
        .executable(
            name: "find",
            targets: ["find"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-asn1.git", from: "1.3.2"),
        .package(url: "https://github.com/apple/swift-certificates.git", from: "1.10.0"),
        // .package(url: "https://github.com/apple/swift-binary-parsing.git", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-binary-parsing.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "SwiftMachOMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "SwiftMachO",
            dependencies: [
                .product(name: "BinaryParsing", package: "swift-binary-parsing"),
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "X509", package: "swift-certificates"),
                "SwiftMachOMacros"
            ],
            path: "Sources/SwiftMachO"
        ),
        .executableTarget(name: "macho", dependencies: [
            "SwiftMachO",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .executableTarget(name: "find", dependencies: [
            "SwiftMachO",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .testTarget(
            name: "SwiftMachOMacrosTests",
            dependencies: [
                "SwiftMachOMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "Tests/SwiftMachOMacrosTests"
        ),
         .testTarget(
             name: "SwiftMachoTests",
             dependencies: ["SwiftMachO"],
             path: "Tests/SwiftMachoTests"
         ),
    ]
)
