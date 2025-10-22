//
//  LC_SEGMENT_SPLIT_INFO.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_SEGMENT_SPLIT_INFO: LoadCommand {
    public let header: LoadCommandHeader
    public let offset: UInt32
    public let size: UInt32
    public let range: Range<Int>
}

extension LC_SEGMENT_SPLIT_INFO {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_SEGMENT_SPLIT_INFO else {
            throw MachOError.LoadCommandError("Invalid LC_SEGMENT_SPLIT_INFO")
        }
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_SEGMENT_SPLIT_INFO: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Offset", stringValue: offset.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: size.description, offset: 12, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
