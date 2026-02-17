//
//  LC_DYLD_INFO.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

import Foundation
import BinaryParsing

public struct LC_DYLD_INFO: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_DYLD_INFO
    public let header: LoadCommandHeader
    public let range: Range<Int>

    public let rebaseOff: UInt32
    public let rebaseSize: UInt32
    public let bindOff: UInt32
    public let bindSize: UInt32
    public let weakBindOff: UInt32
    public let weakBindSize: UInt32
    public let lazyBindOff: UInt32
    public let lazyBindSize: UInt32
    public let exportOff: UInt32
    public let exportSize: UInt32
}

extension LC_DYLD_INFO {
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
        self.exportOff = try UInt32(parsing: &input, endianness: endianness)
        self.exportSize = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_DYLD_INFO: Displayable {
    public var description: String { "Dynamic linker information" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Rebase Offset", stringValue: rebaseOff.hexDescription, size: 4)
        b.add(label: "Rebase Size", stringValue: rebaseSize.description, size: 4)
        b.add(label: "Bind Offset", stringValue: bindOff.hexDescription, size: 4)
        b.add(label: "Bind Size", stringValue: bindSize.description, size: 4)
        b.add(label: "Weak Bind Offset", stringValue: weakBindOff.hexDescription, size: 4)
        b.add(label: "Weak Bind Size", stringValue: weakBindSize.description, size: 4)
        b.add(label: "Lazy Bind Offset", stringValue: lazyBindOff.hexDescription, size: 4)
        b.add(label: "Lazy Bind Size", stringValue: lazyBindSize.description, size: 4)
        b.add(label: "Export Offset", stringValue: exportOff.hexDescription, size: 4)
        b.add(label: "Export Size", stringValue: exportSize.description, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}