//
//  LC_SYMSEG.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_SYMSEG: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_SYMSEG
    public let header: LoadCommandHeader
    public let offset: UInt32
    public let size: UInt32

    public let range: Range<Int>
}

extension LC_SYMSEG {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_SYMSEG: Displayable {
    public var description: String { "Obsolete. Specifies the offset and size of the GNU-style symbol table segment." }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Offset", stringValue: offset.hexDescription, size: 4)
        b.add(label: "Size", stringValue: size.description, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
