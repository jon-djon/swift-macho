//
//  DyldChainedImport.swift
//  swift-macho
//
//  Created by jon on 2/9/26.
//

import BinaryParsing
import Foundation

/// Import entries (format varies based on ImportsFormat)
public struct DyldChainedImport: Parseable {
    // Could look at the order in which LC_LOAD_DYLIB,LC_LOAD_WEAK_DYLIB,LC_REEXPORT_DYLIB,LC_LOAD_UPWARD_DYLIB are defined
    // to map to the library
    public let libOrdinal: UInt8  // Library ordinal (1-based, 0 = self, -1 = main executable)
    public let weakImport: Bool
    public let nameOffset: UInt32  // Offset into symbol strings

    public let range: Range<Int>
}

extension DyldChainedImport {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        // Format: lib_ordinal (8 bits) | weak_import (1 bit) | name_offset (23 bits)
        let rawValue = try UInt32(parsing: &input, endianness: endianness)

        self.libOrdinal = UInt8(rawValue & 0xFF)
        self.weakImport = ((rawValue >> 8) & 0x01) != 0
        self.nameOffset = rawValue >> 9
    }
}

extension DyldChainedImport: Displayable {
    public var title: String { "Import" }
    public var description: String { "A symbol import entry" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Library Ordinal", stringValue: libOrdinal.description, offset: 0, size: 1,
                children: nil, obj: self),
            .init(
                label: "Weak Import", stringValue: weakImport.description, offset: 0, size: 1,
                children: nil, obj: self),
            .init(
                label: "Name Offset", stringValue: nameOffset.description, offset: 0, size: 4,
                children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
