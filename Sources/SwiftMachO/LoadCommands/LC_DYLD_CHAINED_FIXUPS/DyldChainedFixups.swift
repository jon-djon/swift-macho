//
//  DyldChainedFixups.swift
//  swift-macho
//
//  Created by jon on 2/9/26.
//

import Foundation
import BinaryParsing

// MARK: - Chained Fixups Data Structures

/// The main header for chained fixups data
public struct DyldChainedFixupsHeader: Parseable {
    public let fixupsVersion: UInt32        // Currently 0
    public let startsOffset: UInt32         // Offset to dyld_chained_starts_in_image
    public let importsOffset: UInt32        // Offset to imports table
    public let symbolsOffset: UInt32        // Offset to symbol strings
    public let importsCount: UInt32         // Number of imported symbols
    public let importsFormat: ImportsFormat // Import entry format
    public let symbolsFormat: UInt32        // 0 = uncompressed, 1 = zlib compressed
    
    public let range: Range<Int>
    
    @CaseName
    public enum ImportsFormat: UInt32 {
        case DYLD_CHAINED_IMPORT = 1
        case DYLD_CHAINED_IMPORT_ADDEND = 2
        case DYLD_CHAINED_IMPORT_ADDEND64 = 3
    }
}

extension DyldChainedFixupsHeader {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.fixupsVersion = try UInt32(parsing: &input, endianness: endianness)
        self.startsOffset = try UInt32(parsing: &input, endianness: endianness)
        self.importsOffset = try UInt32(parsing: &input, endianness: endianness)
        self.symbolsOffset = try UInt32(parsing: &input, endianness: endianness)
        self.importsCount = try UInt32(parsing: &input, endianness: endianness)
        self.importsFormat = try ImportsFormat(parsing: &input, endianness: endianness)
        self.symbolsFormat = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension DyldChainedFixupsHeader: Displayable {
    public var title: String { "Chained Fixups Header" }
    public var description: String { "The header describing the layout of chained fixups data" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Fixups Version", stringValue: fixupsVersion.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Starts Offset", stringValue: startsOffset.hexDescription, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Imports Offset", stringValue: importsOffset.hexDescription, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Symbols Offset", stringValue: symbolsOffset.hexDescription, offset: 12, size: 4, children: nil, obj: self),
            .init(label: "Imports Count", stringValue: importsCount.description, offset: 16, size: 4, children: nil, obj: self),
            .init(label: "Imports Format", stringValue: importsFormat.description, offset: 20, size: 4, children: nil, obj: self),
            .init(label: "Symbols Format", stringValue: symbolsFormat == 0 ? "Uncompressed" : "Zlib Compressed", offset: 24, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}

/// Describes where chains start in each segment
public struct DyldChainedStartsInImage: Parseable {
    public let segCount: UInt32
    public let segInfoOffsets: [UInt32]  // Array of offsets to dyld_chained_starts_in_segment
    
    public let range: Range<Int>
}

extension DyldChainedStartsInImage {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.segCount = try UInt32(parsing: &input, endianness: endianness)
        
        var offsets: [UInt32] = []
        for _ in 0..<segCount {
            offsets.append(try UInt32(parsing: &input, endianness: endianness))
        }
        self.segInfoOffsets = offsets
    }
}

extension DyldChainedStartsInImage: Displayable {
    public var title: String { "Chained Starts in Image" }
    public var description: String { "Describes fixup chain start locations across all segments" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Segment Count", stringValue: segCount.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Segment Info Offsets", stringValue: "\(segInfoOffsets.count) offsets", offset: 4, size: Int(segCount) * 4, 
                  children: segInfoOffsets.enumerated().map { idx, offset in
                      .init(label: "Segment \(idx)", stringValue: offset == 0 ? "No fixups" : offset.hexDescription, offset: 4 + idx * 4, size: 4, children: nil, obj: self)
                  }, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}

/// Import entries (format varies based on ImportsFormat)
public struct DyldChainedImport: Parseable {
    public let libOrdinal: UInt8   // Library ordinal (1-based, 0 = self, -1 = main executable)
    public let weakImport: Bool
    public let nameOffset: UInt32  // Offset into symbol strings
    
    public let range: Range<Int>
}

extension DyldChainedImport {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        // Format: lib_ordinal (8 bits) | weak_import (1 bit) | name_offset (23 bits)
        let rawValue = try UInt32(parsing: &input, endianness: endianness)
        
        self.libOrdinal = UInt8((rawValue >> 24) & 0xFF)
        self.weakImport = ((rawValue >> 23) & 0x1) != 0
        self.nameOffset = rawValue & 0x7FFFFF
    }
}

extension DyldChainedImport: Displayable {
    public var title: String { "Import" }
    public var description: String { "A symbol import entry" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Library Ordinal", stringValue: libOrdinal.description, offset: 0, size: 1, children: nil, obj: self),
            .init(label: "Weak Import", stringValue: weakImport.description, offset: 0, size: 1, children: nil, obj: self),
            .init(label: "Name Offset", stringValue: nameOffset.hexDescription, offset: 0, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}

/// Complete chained fixups data
public struct ChainedFixupsData: Parseable {
    public let header: DyldChainedFixupsHeader
    public let startsInImage: DyldChainedStartsInImage?
    public let imports: [DyldChainedImport]
    public let symbolStrings: [String]
    
    public let range: Range<Int>
}

extension ChainedFixupsData {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        let startRange = input.parserRange.range
        let startPosition = input.parserRange.lowerBound

        // Parse header
        self.header = try DyldChainedFixupsHeader(parsing: &input, endianness: endianness)

        // Parse starts in image if present
        var startsInImage: DyldChainedStartsInImage? = nil
        if header.startsOffset != 0 {
            try input.seek(toAbsoluteOffset: startPosition + Int(header.startsOffset))
            startsInImage = try DyldChainedStartsInImage(parsing: &input, endianness: endianness)
        }
        self.startsInImage = startsInImage

        // Parse imports
        var imports: [DyldChainedImport] = []
        if header.importsCount > 0 && header.importsOffset != 0 {
            try input.seek(toAbsoluteOffset: startPosition + Int(header.importsOffset))

            for _ in 0..<header.importsCount {
                imports.append(try DyldChainedImport(parsing: &input, endianness: endianness))
            }
        }
        self.imports = imports

        // Parse symbol strings
        var symbolStrings: [String] = []
        if header.symbolsOffset != 0 {
            try input.seek(toAbsoluteOffset: startPosition + Int(header.symbolsOffset))

            // Read null-terminated strings for each import
            for _ in 0..<header.importsCount {
                let symbol = String(parsingUTF8: &input)
                symbolStrings.append(symbol)
            }
        }
        self.symbolStrings = symbolStrings

        self.range = startRange
    }
}

extension ChainedFixupsData: Displayable {
    public var title: String { "Chained Fixups Data" }
    public var description: String { "Complete chained fixups information including imports and symbols" }
    public var fields: [DisplayableField] {
        var fields = header.fields
        
        if let starts = startsInImage {
            fields.append(.init(label: "Starts in Image", stringValue: "\(starts.segCount) segments", offset: 0, size: 0, children: starts.fields, obj: self))
        }
        
        if !imports.isEmpty {
            fields.append(.init(label: "Imports", stringValue: "\(imports.count) imports", offset: 0, size: 0,
                               children: imports.enumerated().map { idx, imp in
                                   let symbol = idx < symbolStrings.count ? symbolStrings[idx] : "?"
                                   return .init(label: "Import \(idx)", stringValue: symbol, offset: 0, size: 0, children: imp.fields, obj: self)
                               }, obj: self))
        }
        
        return fields
    }
    public var children: [Displayable]? { nil }
}
