//
//  LC_SUB_CLIENT.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_SUB_CLIENT: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_SUB_CLIENT
    public let header: LoadCommandHeader
    public let strOffset: UInt32
    public let name: String

    public let range: Range<Int>

    public var nameOffset: Int { self.range.lowerBound + Int(self.strOffset) }
}

extension LC_SUB_CLIENT {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.strOffset = try UInt32(parsing: &input, endianness: endianness)

        // May need to advance further if offset is past 12
        if self.strOffset > 12 {
            try input.seek(toRelativeOffset: Int(self.strOffset) - 12)
        }

        self.name = String(parsingUTF8: &input)
    }
}

extension LC_SUB_CLIENT: Displayable {
    public var description: String { "" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Name Offset", stringValue: strOffset.description, size: 4)
        b.add(label: "Name", stringValue: name, offset: Int(strOffset), size: name.count)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
