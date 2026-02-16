//
//  LC_DYLD_ENVIRONMENT.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_DYLD_ENVIRONMENT: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_DYLD_ENVIRONMENT
    public let header: LoadCommandHeader
    public let range: Range<Int>

    public let nameOffset: UInt32
    public let name: String

    public var absoluteOffset: Int { self.range.lowerBound + Int(self.nameOffset) }
}

extension LC_DYLD_ENVIRONMENT {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.nameOffset = try UInt32(parsing: &input, endianness: endianness)

        // May need to advance further if offset is past 12
        if self.nameOffset > 12 {
            try input.seek(toRelativeOffset: Int(self.nameOffset) - 12)
        }

        self.name = String(parsingUTF8: &input)
    }
}

extension LC_DYLD_ENVIRONMENT: Displayable {
    public var description: String { "" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Name Offset", stringValue: nameOffset.description, size: 4)
        b.add(label: "Name", stringValue: name, offset: Int(nameOffset), size: name.count)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
