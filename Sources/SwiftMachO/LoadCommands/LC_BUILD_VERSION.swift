//
//  LC_BUILD_VERSION.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

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
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_BUILD_VERSION else {
            throw MachOError.LoadCommandError("Invalid LC_BUILD_VERSION")
        }
        
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
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Platform", stringValue: platform.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Min OS", stringValue: minOS.description, offset: 12, size: 4, children: nil, obj: self),
            .init(label: "SDK", stringValue: sdk.description, offset: 16, size: 4, children: nil, obj: self),
            .init(label: "Number of Tools", stringValue: ntools.description, offset: 20, size: 4, children: nil, obj: self),
            .init(label: "Tools \(ntools.description)", stringValue: "", offset: 24, size: 4,
                  children: tools.enumerated().map { (index: Int, tool: BuildToolVersion) in
                        .init(label: "Tool \(index.description)", stringValue: "", offset: 24+(index*8), size: 8, children: tool.fields, obj: self)
                  },
                  obj: self
            ),
        ]
    }
    public var children: [Displayable]? { nil }
}

extension LC_BUILD_VERSION.BuildToolVersion: Displayable {
    public var title: String { "BuildToolVersion" }
    public var description: String { "\(tool) \(version)" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Tool", stringValue: tool.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Version", stringValue: version.description, offset: 4, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
