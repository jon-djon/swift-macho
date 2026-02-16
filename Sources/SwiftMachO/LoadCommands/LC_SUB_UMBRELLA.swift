//
//  LC_SUB_UMBRELLA.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_SUB_UMBRELLA: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_SUB_UMBRELLA
    public let header: LoadCommandHeader
    public let strOffset: UInt32
    public let name: String

    public let range: Range<Int>

    public var nameOffset: Int { self.range.lowerBound + Int(self.strOffset) }
}

extension LC_SUB_UMBRELLA {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.strOffset = try UInt32(parsing: &input, endianness: endianness)

        // May need to advance further if offset is past 12
        if self.strOffset > 12 {
            try input.seek(toRelativeOffset: Int(self.strOffset) - 12)
        }

        self.name = try String(parsingNulTerminated: &input)
    }
}

extension LC_SUB_UMBRELLA: Displayable {
    public var description: String {
        "The **LC_SUB_UMBRELLA** command identifies a sub-umbrella framework that this framework re-exports. It specifies the name of another umbrella framework whose symbols should be visible to clients linking against this framework. This is part of the two-level namespace mechanism used in macOS frameworks."
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
                label: "Name Offset", stringValue: strOffset.description, offset: 8, size: 4,
                children: nil, obj: self),
            .init(
                label: "Umbrella Name", stringValue: name, offset: Int(strOffset), size: name.count,
                children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
