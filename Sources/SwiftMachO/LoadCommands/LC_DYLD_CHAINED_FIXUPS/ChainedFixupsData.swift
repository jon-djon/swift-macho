//
//  ChainedFixupsData.swift
//  swift-macho
//
//  Created by jon on 2/9/26.
//

import BinaryParsing
import Foundation

/// Complete chained fixups data
public struct ChainedFixupsData: Parseable {
    public let fixupsVersion: UInt32
    public let startsOffset: UInt32
    public let importsOffset: UInt32
    public let symbolsOffset: UInt32
    public let importsCount: UInt32
    public let importsFormat: ImportsFormat
    public let symbolsFormat: UInt32
    public let startsInImage: DyldChainedStartsInImage?
    public let imports: [DyldChainedImport]
    public let symbolStrings: [String]

    public let range: Range<Int>

    @CaseName
    public enum ImportsFormat: UInt32 {
        case DYLD_CHAINED_IMPORT = 1
        case DYLD_CHAINED_IMPORT_ADDEND = 2
        case DYLD_CHAINED_IMPORT_ADDEND64 = 3
    }
}

extension ChainedFixupsData {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        let startRange = input.parserRange.range
        let startPosition = input.parserRange.lowerBound

        // Parse header fields
        self.fixupsVersion = try UInt32(parsing: &input, endianness: endianness)
        guard self.fixupsVersion == 0 else {
            throw MachOError.parsingError(
                "ChainedFixupsData: unsupported fixups version \(self.fixupsVersion) (expected 0). "
                + "The linked edit data may be encrypted or corrupted.")
        }
        self.startsOffset = try UInt32(parsing: &input, endianness: endianness)
        self.importsOffset = try UInt32(parsing: &input, endianness: endianness)
        self.symbolsOffset = try UInt32(parsing: &input, endianness: endianness)
        self.importsCount = try UInt32(parsing: &input, endianness: endianness)

        let importsFormatRaw = try UInt32(parsing: &input, endianness: endianness)
        guard let importsFormat = ImportsFormat(rawValue: importsFormatRaw) else {
            throw MachOError.parsingError(
                "ChainedFixupsData: unknown imports format \(importsFormatRaw) "
                + "(fixups version: \(self.fixupsVersion), imports count: \(self.importsCount))")
        }
        self.importsFormat = importsFormat

        self.symbolsFormat = try UInt32(parsing: &input, endianness: endianness)

        // Parse starts in image if present
        var startsInImage: DyldChainedStartsInImage? = nil
        if self.startsOffset != 0 {
            try input.seek(toAbsoluteOffset: startPosition + Int(self.startsOffset))
            startsInImage = try DyldChainedStartsInImage(parsing: &input, endianness: endianness)
        }
        self.startsInImage = startsInImage

        // Parse imports
        var imports: [DyldChainedImport] = []
        if self.importsCount > 0 && self.importsOffset != 0 {
            try input.seek(toAbsoluteOffset: startPosition + Int(self.importsOffset))

            for _ in 0..<self.importsCount {
                imports.append(try DyldChainedImport(
                    parsing: &input, endianness: endianness, format: self.importsFormat))
            }
        }
        self.imports = imports

        // Parse symbol strings
        var symbolStrings: [String] = []
        let symOffset = self.symbolsOffset
        if symOffset != 0 && !imports.isEmpty {
            symbolStrings = try imports.map { imp in
                try input.seek(
                    toAbsoluteOffset: startPosition + Int(symOffset) + Int(imp.nameOffset))
                return try String(parsingNulTerminated: &input)
            }
        }
        self.symbolStrings = symbolStrings

        self.range = startRange
    }
}

extension ChainedFixupsData: Displayable {
    public var title: String { "Chained Fixups Data" }
    public var description: String {
        "Complete chained fixups information including imports and symbols"
    }
    public var fields: [DisplayableField] {
        var fields: [DisplayableField] = [
            .init(
                label: "Fixups Version", stringValue: fixupsVersion.description, offset: 0,
                size: 4, children: nil, obj: self),
            .init(
                label: "Starts Offset", stringValue: startsOffset.description, offset: 4,
                size: 4, children: nil, obj: self),
            .init(
                label: "Imports Offset", stringValue: importsOffset.description, offset: 8,
                size: 4, children: nil, obj: self),
            .init(
                label: "Symbols Offset", stringValue: symbolsOffset.description, offset: 12,
                size: 4, children: nil, obj: self),
            .init(
                label: "Imports Count", stringValue: importsCount.description, offset: 16,
                size: 4, children: nil, obj: self),
            .init(
                label: "Imports Format", stringValue: importsFormat.description, offset: 20,
                size: 4, children: nil, obj: self),
            .init(
                label: "Symbols Format",
                stringValue: symbolsFormat == 0 ? "Uncompressed" : "Zlib Compressed", offset: 24,
                size: 4, children: nil, obj: self),
        ]

        if let starts = startsInImage {
            fields.append(
                .init(
                    label: "Starts in Image", stringValue: "\(starts.segCount) segments",
                    offset: Int(startsOffset), size: 0, children: starts.fields, obj: self))
        }

        if !imports.isEmpty {
            fields.append(
                .init(
                    label: "Imports", stringValue: "\(imports.count) imports",
                    offset: Int(importsOffset), size: 0,
                    children: imports.enumerated().map { idx, imp in
                        let symbol = idx < symbolStrings.count ? symbolStrings[idx] : "?"
                        return .init(
                            label: "Import \(idx)", stringValue: symbol, offset: 0, size: 0,
                            children: imp.fields, obj: self)
                    }, obj: self))
        }

        return fields
    }
    public var children: [Displayable]? { nil }
}
