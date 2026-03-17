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
        addLinkEditFields(to: &b)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
