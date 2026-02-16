//
//  LC_LOAD_DYLINKER.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_LOAD_DYLINKER: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_LOAD_DYLINKER
    public let header: LoadCommandHeader
    public let nameOffset: UInt32
    public let name: String
    public let range: Range<Int>
}

extension LC_LOAD_DYLINKER {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.nameOffset = try UInt32(parsing: &input, endianness: endianness)

        try input.seek(toAbsoluteOffset: self.range.lowerBound)
        try input.seek(toRelativeOffset: self.nameOffset)
        self.name = try String(parsingNulTerminated: &input)
    }
}

extension LC_LOAD_DYLINKER: Displayable {
    public var description: String { "" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Name Offset", stringValue: nameOffset.description, size: 4)
        b.add(label: "Name", stringValue: name, offset: Int(nameOffset), size: name.count)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
