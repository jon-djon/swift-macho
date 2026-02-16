//
//  LC_DYLD_INFO_ONLY.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_DYLD_INFO_ONLY: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_DYLD_INFO_ONLY
    public let header: LoadCommandHeader
    public let rebaseOff: UInt32
    public let rebaseSize: UInt32
    public let bindOff: UInt32
    public let bindSize: UInt32
    public let weakBindOff: UInt32
    public let weakBindSize: UInt32
    public let lazyBindOff: UInt32
    public let lazyBindSize: UInt32
    public let exportBindOff: UInt32
    public let exportBindSize: UInt32

    public let range: Range<Int>
}

extension LC_DYLD_INFO_ONLY {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.rebaseOff = try UInt32(parsing: &input, endianness: endianness)
        self.rebaseSize = try UInt32(parsing: &input, endianness: endianness)
        self.bindOff = try UInt32(parsing: &input, endianness: endianness)
        self.bindSize = try UInt32(parsing: &input, endianness: endianness)
        self.weakBindOff = try UInt32(parsing: &input, endianness: endianness)
        self.weakBindSize = try UInt32(parsing: &input, endianness: endianness)
        self.lazyBindOff = try UInt32(parsing: &input, endianness: endianness)
        self.lazyBindSize = try UInt32(parsing: &input, endianness: endianness)
        self.exportBindOff = try UInt32(parsing: &input, endianness: endianness)
        self.exportBindSize = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_DYLD_INFO_ONLY: Displayable {
    public var description: String {
        "The **LC_DYLD_INFO_ONLY** command is a Mach-O load command that centralizes and supersedes several older, separate load commands related to dynamic linking and the Dynamic Link Editor (dyld). It contains file offsets and sizes that point to tables used exclusively by dyld at runtime to handle various dynamic linking tasks. Because it only contains offsets and sizes, it is usually quite small."
    }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Command ID", stringValue: header.id.description, offset: 0, size: 4,
                children: nil, obj: self),
            .init(
                label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4,
                children: nil, obj: self),
            .init(
                label: "Rebase Offset", stringValue: rebaseOff.hexDescription, offset: 8, size: 4,
                children: nil, obj: self),
            .init(
                label: "Rebase Size", stringValue: rebaseSize.description, offset: 12, size: 4,
                children: nil, obj: self),
            .init(
                label: "Bind Offset", stringValue: bindOff.hexDescription, offset: 16, size: 4,
                children: nil, obj: self),
            .init(
                label: "Bind Size", stringValue: bindSize.description, offset: 20, size: 4,
                children: nil, obj: self),
            .init(
                label: "Weak Bind Offset", stringValue: weakBindOff.hexDescription, offset: 24,
                size: 4, children: nil, obj: self),
            .init(
                label: "Weak Bind Size", stringValue: weakBindSize.description, offset: 28, size: 4,
                children: nil, obj: self),
            .init(
                label: "Lazy Bind Offset", stringValue: lazyBindOff.hexDescription, offset: 32,
                size: 4, children: nil, obj: self),
            .init(
                label: "Lazy Bind Size", stringValue: lazyBindSize.description, offset: 36, size: 4,
                children: nil, obj: self),
            .init(
                label: "Export Bind Offset", stringValue: exportBindOff.hexDescription, offset: 40,
                size: 4, children: nil, obj: self),
            .init(
                label: "Export Bind Size", stringValue: exportBindSize.description, offset: 44,
                size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
