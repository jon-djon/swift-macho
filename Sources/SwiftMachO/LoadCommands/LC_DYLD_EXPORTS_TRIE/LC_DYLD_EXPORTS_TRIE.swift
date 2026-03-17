//
//  LC_DYLD_EXPORTS_TRIE.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_DYLD_EXPORTS_TRIE: LoadCommand, LoadCommandLinkEdit {
    public static let expectedID: LoadCommandHeader.ID = .LC_DYLD_EXPORTS_TRIE
    public let header: LoadCommandHeader
    public let range: Range<Int>

    public let offset: UInt32
    public let size: UInt32
}

extension LC_DYLD_EXPORTS_TRIE {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.offset = try UInt32(parsingLittleEndian: &input)
        self.size = try UInt32(parsingLittleEndian: &input)
    }
}

extension LC_DYLD_EXPORTS_TRIE: Displayable {
    public var description: String {
        "Contains the export trie, a compressed prefix tree of all symbols exported by this binary. Each exported symbol has an address offset and flags indicating the export kind."
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        addLinkEditFields(to: &b, offsetIsHex: false)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
