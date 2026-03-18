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
    public let libOrdinal: Int32
    public let weakImport: Bool
    public let nameOffset: UInt32
    public let addend: Int64?

    public let range: Range<Int>
}

extension DyldChainedImport {
    public init(parsing input: inout ParserSpan, endianness: Endianness,
                format: ChainedFixupsData.ImportsFormat = .DYLD_CHAINED_IMPORT) throws {
        self.range = input.parserRange.range

        switch format {
        case .DYLD_CHAINED_IMPORT:
            // 4 bytes: lib_ordinal (8 bits) | weak_import (1 bit) | name_offset (23 bits)
            let rawValue = try UInt32(parsing: &input, endianness: endianness)
            self.libOrdinal = Int32(Int8(bitPattern: UInt8(rawValue & 0xFF)))
            self.weakImport = ((rawValue >> 8) & 0x01) != 0
            self.nameOffset = rawValue >> 9
            self.addend = nil

        case .DYLD_CHAINED_IMPORT_ADDEND:
            // 8 bytes: lib_ordinal (8 bits) | weak_import (1 bit) | name_offset (23 bits) | addend (32 bits)
            let rawValue = try UInt32(parsing: &input, endianness: endianness)
            self.libOrdinal = Int32(Int8(bitPattern: UInt8(rawValue & 0xFF)))
            self.weakImport = ((rawValue >> 8) & 0x01) != 0
            self.nameOffset = rawValue >> 9
            self.addend = Int64(Int32(bitPattern: try UInt32(parsing: &input, endianness: endianness)))

        case .DYLD_CHAINED_IMPORT_ADDEND64:
            // 16 bytes: lib_ordinal (16 bits) | weak_import (1 bit) | reserved (15 bits) | name_offset (32 bits) | addend (64 bits)
            let rawValue = try UInt32(parsing: &input, endianness: endianness)
            self.libOrdinal = Int32(Int16(bitPattern: UInt16(rawValue & 0xFFFF)))
            self.weakImport = ((rawValue >> 16) & 0x01) != 0
            self.nameOffset = try UInt32(parsing: &input, endianness: endianness)
            self.addend = Int64(bitPattern: try UInt64(parsing: &input, endianness: endianness))
        }
    }
}

extension DyldChainedImport: Displayable {
    public var title: String { "Import" }
    public var description: String { "A symbol import entry" }
    public var fields: [DisplayableField] {
        var fields: [DisplayableField] = [
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
        if let addend {
            fields.append(.init(
                label: "Addend", stringValue: addend.description, offset: 0, size: 0,
                children: nil, obj: self))
        }
        return fields
    }
    public var children: [Displayable]? { nil }
}
