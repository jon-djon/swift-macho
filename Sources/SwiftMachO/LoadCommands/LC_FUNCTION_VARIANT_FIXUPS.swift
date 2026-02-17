//
//  LC_FUNCTION_VARIANT_FIXUPS.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_FUNCTION_VARIANT_FIXUPS: LoadCommand, LoadCommandLinkEdit {
    public static let expectedID: LoadCommandHeader.ID = .LC_FUNCTION_VARIANT_FIXUPS
    public let header: LoadCommandHeader
    public let range: Range<Int>

    public let offset: UInt32
    public let size: UInt32
}

extension LC_FUNCTION_VARIANT_FIXUPS {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_FUNCTION_VARIANT_FIXUPS: Displayable {
    public var description: String { "Function Variant Fixups" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        addLinkEditFields(to: &b, offsetIsHex: false)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
