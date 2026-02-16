//
//  LC_MAIN.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_MAIN: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_MAIN
    public let header: LoadCommandHeader
    public let range: Range<Int>

    public let entryOff: UInt64
    public let stackSize: UInt64
}

extension LC_MAIN {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.entryOff = try UInt64(parsing: &input, endianness: endianness)
        self.stackSize = try UInt64(parsing: &input, endianness: endianness)
    }
}

extension LC_MAIN: Displayable {
    public var description: String { "" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Entry Offset", stringValue: entryOff.description, size: 8)
        b.add(label: "Stack Size", stringValue: stackSize.description, size: 8)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
