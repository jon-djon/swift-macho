//
//  LC_MAIN.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_MAIN: LoadCommand {
    public let header: LoadCommandHeader
    public let range: Range<Int>

    public let entryOff: UInt64
    public let stackSize: UInt64
}

extension LC_MAIN {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_MAIN else {
            throw MachOError.LoadCommandError("Invalid LC_MAIN")
        }

        self.entryOff = try UInt64(parsing: &input, endianness: endianness)
        self.stackSize = try UInt64(parsing: &input, endianness: endianness)
    }
}

extension LC_MAIN: Displayable {
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Command ID", stringValue: header.id.description, offset: 0, size: 4,
                children: nil, obj: self),
            .init(
                label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4,
                children: nil, obj: self),
            .init(
                label: "Entry Offset", stringValue: entryOff.description, offset: 8, size: 8,
                children: nil, obj: self),
            .init(
                label: "Stack Size", stringValue: stackSize.description, offset: 16, size: 8,
                children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
