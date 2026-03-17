//
//  DyldChainedStartsInImage.swift
//  swift-macho
//
//  Created by jon on 2/9/26.
//

import BinaryParsing
import Foundation

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
