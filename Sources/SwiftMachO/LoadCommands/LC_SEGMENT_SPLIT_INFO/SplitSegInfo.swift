//
//  SplitSegInfo.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

/// Parsed split segment info data from __LINKEDIT
public struct SplitSegInfo: Parseable {
    public let firstByte: UInt8
    public let fixups: [SplitSegInfoFixup]
    public let range: Range<Int>

    public var version: Int {
        if self.firstByte == Self.v2Marker {
            return 2
        } else {
            return 1
        }
    }
}

extension SplitSegInfo {
    /// V2 format marker byte
    private static let v2Marker: UInt8 = 0x7F

    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range

        guard !input.isEmpty else {
            self.firstByte = 0
            self.fixups = []
            return
        }

        // Check if this is v2 format (starts with 0x7F)
        let startPosition = input.parserRange.lowerBound
        self.firstByte = try UInt8(parsing: &input)

        if self.firstByte == Self.v2Marker {
            self.fixups = try Self.parseV2(&input)
        } else {
            // V1 format - rewind and parse
            try input.seek(toAbsoluteOffset: startPosition)
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
                    guard let kindByte = UInt8(exactly: kindRaw),
                          let kind = SplitSegInfoV2Kind(rawValue: kindByte) else {
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
