//
//  LC_BUILD_VERSION.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

// Are there more valid values?
// https://github.com/apple-oss-distributions/dyld/blob/main/common/MachOAnalyzer.cpp
@CaseName
public enum ToolEnum: UInt32 {
    case TOOL_NONE = 0
    case TOOL_CLANG = 1
    case TOOL_SWIFT = 2
    case TOOL_LD = 3
    case TOOL_LLD = 4
}

@CaseName
public enum PlatformEnum: UInt32 {
    case PLATFORM_UNKNOWN = 0
    case PLATFORM_MACOS = 1
    case PLATFORM_IOS = 2
    case PLATFORM_TVOS = 3
    case PLATFORM_WATCHOS = 4
    case PLATFORM_BRIDGEOS = 5
    case PLATFORM_MACCATALYST = 6
    case PLATFORM_IOSSIMULATOR = 7
    case PLATFORM_TVOSSIMULATOR = 8
    case PLATFORM_WATCHOSSIMULATOR = 9
    case PLATFORM_DRIVERKIT = 10
    case PLATFORM_REALITYOS = 11
    case PLATFORM_REALITYOSSIMULATOR = 12
    case PLATFORM_FIRMWARE = 13
    case PLATFORM_SEPOS = 14
    case PLATFORM_MACOS_EXCLAVECORE = 15
    case PLATFORM_MACOS_EXCLAVEKIT = 16
    case PLATFORM_IOS_EXCLAVECORE = 17
    case PLATFORM_IOS_EXCLAVEKIT = 18
    case PLATFORM_TVOS_EXCLAVECORE = 19
    case PLATFORM_TVOS_EXCLAVEKIT = 20
    case PLATFORM_WATCHOS_EXCLAVECORE = 21
    case PLATFORM_WATCHOS_EXCLAVEKIT = 22
}

public struct LC_BUILD_VERSION: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_BUILD_VERSION
    public let header: LoadCommandHeader
    public let platform: PlatformEnum
    public let minOS: SemanticVersion
    public let sdk: SemanticVersion
    public let ntools: UInt32
    public let tools: [BuildToolVersion]

    public let range: Range<Int>

    public struct BuildToolVersion: Parseable {
        public let tool: ToolEnum
        public let version: SemanticVersion

        public let range: Range<Int>

        static public let size: Int = 8
    }
}

extension LC_BUILD_VERSION.BuildToolVersion {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        self.tool = try ToolEnum(parsing: &input, endianness: endianness)
        self.version = try SemanticVersion(parsing: &input, endianness: endianness)
    }
}

extension LC_BUILD_VERSION {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.platform = try PlatformEnum(parsing: &input, endianness: endianness)
        self.minOS = try SemanticVersion(parsing: &input, endianness: endianness)
        self.sdk = try SemanticVersion(parsing: &input, endianness: endianness)
        self.ntools = try UInt32(parsing: &input, endianness: endianness)

        self.tools = try Array(parsing: &input, count: Int(self.ntools)) { input in
            var span = try input.sliceSpan(byteCount: BuildToolVersion.size)
            return try BuildToolVersion(parsing: &span, endianness: endianness)
        }
    }
}

extension LC_BUILD_VERSION: Displayable {
    public var description: String {
        "Specifies the target platform, minimum OS version, SDK version, and build tools used to create the binary."
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Platform", stringValue: platform.description, size: 4)
        b.add(label: "Min OS", stringValue: minOS.description, size: 4)
        b.add(label: "SDK", stringValue: sdk.description, size: 4)
        b.add(label: "Number of Tools", stringValue: ntools.description, size: 4)
        b.add(label: "Tools \(ntools.description)", stringValue: "", offset: 24, size: 4,
              children: tools.enumerated().map { (index: Int, tool: BuildToolVersion) in
                  .init(
                      label: "Tool \(index.description)", stringValue: "",
                      offset: 24 + (index * 8), size: 8, children: tool.fields, obj: self)
              })
        return b.build()
    }
    public var children: [Displayable]? { nil }
}

extension LC_BUILD_VERSION.BuildToolVersion: Displayable {
    public var title: String { "BuildToolVersion" }
    public var description: String { "\(tool) \(version)" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Tool", stringValue: tool.description, offset: 0, size: 4, children: nil,
                obj: self),
            .init(
                label: "Version", stringValue: version.description, offset: 4, size: 4,
                children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
