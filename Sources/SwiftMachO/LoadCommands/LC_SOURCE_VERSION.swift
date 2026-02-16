//
//  LC_SOURCE_VERSION.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_SOURCE_VERSION: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_SOURCE_VERSION
    public let header: LoadCommandHeader
    public let version: UInt64

    public let range: Range<Int>
}

extension LC_SOURCE_VERSION {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self.version = try UInt64(parsing: &input, endianness: endianness)
    }
}

extension LC_SOURCE_VERSION: Displayable {
    public var description: String { "" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Version", stringValue: version.description, size: 8)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
