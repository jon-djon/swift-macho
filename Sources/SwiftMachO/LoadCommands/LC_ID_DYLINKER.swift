//
//  LC_ID_DYLINKER.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_ID_DYLINKER: LoadCommand {
    public let header: LoadCommandHeader
    public let range: Range<Int>
    public let nameOffset: UInt32
    public let name: String
}

extension LC_ID_DYLINKER {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_ID_DYLINKER else {
            throw MachOError.LoadCommandError("Invalid LC_ID_DYLINKER")
        }
        self.nameOffset = try UInt32(parsing: &input, endianness: endianness)

        try input.seek(toAbsoluteOffset: self.range.lowerBound)
        try input.seek(toRelativeOffset: self.nameOffset)
        self.name = try String(parsingNulTerminated: &input)
    }
}

extension LC_ID_DYLINKER: Displayable {
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
                label: "Name Offset", stringValue: nameOffset.description, offset: 8, size: 4,
                children: nil, obj: self),
            .init(
                label: "Name", stringValue: name, offset: Int(nameOffset), size: name.count,
                children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
