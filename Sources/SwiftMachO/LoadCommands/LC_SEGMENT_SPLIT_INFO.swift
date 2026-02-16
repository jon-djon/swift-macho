//
//  LC_SEGMENT_SPLIT_INFO.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_SEGMENT_SPLIT_INFO: LoadCommand, LoadCommandLinkEdit {
    public static let expectedID: LoadCommandHeader.ID = .LC_SEGMENT_SPLIT_INFO
    public let header: LoadCommandHeader
    public let offset: UInt32
    public let size: UInt32
    public let range: Range<Int>
}

// MARK: - Split Segment Info Data

/// The kind of pointer adjustment in split segment info v2
@CaseName
public enum SplitSegInfoV2Kind: UInt8 {
    case pointer64 = 1  // DYLD_CACHE_ADJ_V2_POINTER_64
    case delta64 = 2  // DYLD_CACHE_ADJ_V2_DELTA_64
    case delta32 = 3  // DYLD_CACHE_ADJ_V2_DELTA_32
    case arm64ADRP = 4  // DYLD_CACHE_ADJ_V2_ARM64_ADRP
    case arm64Off12 = 5  // DYLD_CACHE_ADJ_V2_ARM64_OFF12
    case arm64Br26 = 6  // DYLD_CACHE_ADJ_V2_ARM64_BR26
    case armMovwMovt = 7  // DYLD_CACHE_ADJ_V2_ARM_MOVW_MOVT
    case armBr24 = 8  // DYLD_CACHE_ADJ_V2_ARM_BR24
    case thumbMovwMovt = 9  // DYLD_CACHE_ADJ_V2_THUMB_MOVW_MOVT
    case thumbBr22 = 10  // DYLD_CACHE_ADJ_V2_THUMB_BR22
    case imageOff32 = 11  // DYLD_CACHE_ADJ_V2_IMAGE_OFF_32
    case threaded = 12  // DYLD_CACHE_ADJ_V2_THREADED_POINTER_64
}

/// An individual fixup location from split segment info
public struct SplitSegInfoFixup: Parseable {
    public let kind: SplitSegInfoV2Kind
    public let fromSectionIndex: UInt
    public let fromSectionOffset: UInt
    public let toSectionIndex: UInt
    public let toSectionOffset: UInt

    public let range: Range<Int>
}

/// Parsed split segment info data from __LINKEDIT
public struct SplitSegInfo: Parseable {
    public let version: Int  // 1 for v1 format, 2 for v2 format
    public let fixups: [SplitSegInfoFixup]
    public let range: Range<Int>
}

extension SplitSegInfo {
    /// V2 format marker byte
    private static let v2Marker: UInt8 = 0x7F

    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range

        guard !input.isEmpty else {
            self.version = 0
            self.fixups = []
            return
        }

        // Check if this is v2 format (starts with 0x7F)
        let firstByte = try UInt8(parsing: &input)

        if firstByte == Self.v2Marker {
            self.version = 2
            self.fixups = try Self.parseV2(&input)
        } else {
            // V1 format - rewind and parse
            try input.seek(toRelativeOffset: -1)
            self.version = 1
            self.fixups = try Self.parseV1(&input)
        }
    }

    /// Parse v1 format: simple list of ULEB128 encoded offsets
    /// V1 format is a series of ULEB128 deltas terminated by 0
    private static func parseV1(_ input: inout ParserSpan) throws -> [SplitSegInfoFixup] {
        var fixups: [SplitSegInfoFixup] = []
        var currentOffset: UInt = 0

        while !input.isEmpty {
            let start = input.startPosition
            let delta = try UInt(parsingLEB128: &input)
            if delta == 0 {
                break
            }
            currentOffset += delta

            // V1 format doesn't have kind/section info, use defaults
            fixups.append(
                SplitSegInfoFixup(
                    kind: .pointer64,
                    fromSectionIndex: 0,
                    fromSectionOffset: currentOffset,
                    toSectionIndex: 0,
                    toSectionOffset: 0,
                    range: start..<input.startPosition
                ))
        }

        return fixups
    }

    /// Parse v2 format: hierarchical structure with section indices and kinds
    /// Format: count FromToSection+
    /// FromToSection: fromSectionIndex toSectionIndex count ToOffset+
    /// ToOffset: toSectionOffsetDelta count FromOffset+
    /// FromOffset: kind count fromSectionOffsetDelta
    private static func parseV2(_ input: inout ParserSpan) throws -> [SplitSegInfoFixup] {
        var fixups: [SplitSegInfoFixup] = []

        // Parse the number of FromToSection entries
        let sectionPairCount = try UInt(parsingLEB128: &input)

        for _ in 0..<sectionPairCount {
            guard !input.isEmpty else { break }

            let fromSectionIndex = try UInt(parsingLEB128: &input)
            let toSectionIndex = try UInt(parsingLEB128: &input)
            let toOffsetCount = try UInt(parsingLEB128: &input)

            var toSectionOffset: UInt = 0

            for _ in 0..<toOffsetCount {
                guard !input.isEmpty else { break }

                let toOffsetDelta = try UInt(parsingLEB128: &input)
                toSectionOffset += toOffsetDelta

                let fromOffsetCount = try UInt(parsingLEB128: &input)
                var fromSectionOffset: UInt = 0

                for _ in 0..<fromOffsetCount {
                    guard !input.isEmpty else { break }

                    let kindStart = input.startPosition
                    let kindRaw = try UInt(parsingLEB128: &input)
                    guard let kind = SplitSegInfoV2Kind(rawValue: UInt8(kindRaw)) else {
                        // Skip unknown kinds
                        _ = try UInt(parsingLEB128: &input)  // count
                        _ = try UInt(parsingLEB128: &input)  // delta
                        continue
                    }

                    let count = try UInt(parsingLEB128: &input)

                    for _ in 0..<count {
                        guard !input.isEmpty else { break }

                        let fromOffsetDelta = try UInt(parsingLEB128: &input)
                        fromSectionOffset += fromOffsetDelta

                        fixups.append(
                            SplitSegInfoFixup(
                                kind: kind,
                                fromSectionIndex: fromSectionIndex,
                                fromSectionOffset: fromSectionOffset,
                                toSectionIndex: toSectionIndex,
                                toSectionOffset: toSectionOffset,
                                range: kindStart..<input.startPosition
                            ))
                    }
                }
            }
        }

        return fixups
    }
}

extension LC_SEGMENT_SPLIT_INFO {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_SEGMENT_SPLIT_INFO: Displayable {
    public var description: String {
        """
        Contains information used to split segments between read-only and read-write portions.

        This data in `__LINKEDIT` helps the dynamic linker optimize memory usage by allowing \
        shared libraries to share read-only pages across processes while keeping writable data private. \
        Used in conjunction with the `MH_SPLIT_SEGS` header flag.
        """
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Data Offset", stringValue: offset.hexDescription, size: 4)
        b.add(label: "Data Size", stringValue: size.description, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}

extension SplitSegInfo: Displayable {
    public var title: String { "SplitSegInfo" }
    public var description: String {
        version == 2
            ? "Split segment info v2 format with detailed fixup information"
            : "Split segment info v1 format with offset deltas"
    }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Version", stringValue: "v\(version)", offset: 0, size: 1, children: nil,
                obj: self),
            .init(
                label: "Fixups", stringValue: "\(fixups.count) entries", offset: 1,
                size: range.count - 1,
                children: fixups.enumerated().map { index, fixup in
                    .init(
                        label: "Fixup \(index)", stringValue: fixup.description, offset: 0, size: 0,
                        children: fixup.fields, obj: fixup)
                }, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}

extension SplitSegInfoFixup: Displayable {
    public var title: String { "Fixup" }
    public var description: String {
        "\(kind.description): section \(fromSectionIndex):\(fromSectionOffset.hexDescription) -> section \(toSectionIndex):\(toSectionOffset.hexDescription)"
    }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Kind", stringValue: kind.description, offset: 0, size: 0, children: nil,
                obj: self),
            .init(
                label: "From Section Index", stringValue: fromSectionIndex.description, offset: 0,
                size: 0, children: nil, obj: self),
            .init(
                label: "From Section Offset", stringValue: fromSectionOffset.hexDescription,
                offset: 0, size: 0, children: nil, obj: self),
            .init(
                label: "To Section Index", stringValue: toSectionIndex.description, offset: 0,
                size: 0, children: nil, obj: self),
            .init(
                label: "To Section Offset", stringValue: toSectionOffset.hexDescription, offset: 0,
                size: 0, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
