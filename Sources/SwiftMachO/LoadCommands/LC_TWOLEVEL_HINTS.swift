//
//  LC_TWOLEVEL_HINTS.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_TWOLEVEL_HINTS: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_TWOLEVEL_HINTS
    public let header: LoadCommandHeader
    public let range: Range<Int>

    public let offset: UInt32
    public let nhints: UInt32
    // TODO: Need to parse the hints pointed to by offset
}

extension LC_TWOLEVEL_HINTS {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.nhints = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_TWOLEVEL_HINTS: Displayable {
    public var description: String { "Two-level namespace hints" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Hints Offset", stringValue: offset.hexDescription, size: 4)
        b.add(label: "Number of Hints", stringValue: nhints.description, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
