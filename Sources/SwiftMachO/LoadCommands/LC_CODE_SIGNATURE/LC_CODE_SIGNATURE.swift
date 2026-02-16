//
//  LC_CODE_SIGNATURE.swift
//  swift-macho
//
//  Created by jon on 9/29/25.
//

import BinaryParsing
import Foundation

public struct LC_CODE_SIGNATURE: LoadCommand, LoadCommandLinkEdit {
    public static let expectedID: LoadCommandHeader.ID = .LC_CODE_SIGNATURE
    public let range: Range<Int>
    public let header: LoadCommandHeader

    public let offset: UInt32  // Offset is relative to the beginning of the MachO
    public let size: UInt32
}

extension LC_CODE_SIGNATURE {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_CODE_SIGNATURE: Displayable {
    public var description: String { "" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        addLinkEditFields(to: &b, offsetIsHex: false)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
