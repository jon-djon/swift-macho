//
//  Untitled.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_ENCRYPTION_INFO_64: LoadCommand {
    public let header: LoadCommandHeader
    public let range: Range<Int>
    
    public let offset: UInt32
    public let size: UInt32
    public let cryptID: UInt32
    public let pad: UInt32
}

extension LC_ENCRYPTION_INFO_64 {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_ENCRYPTION_INFO_64 else {
            throw MachOError.LoadCommandError("Invalid LC_ENCRYPTION_INFO_64")
        }
        
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
        self.cryptID = try UInt32(parsing: &input, endianness: endianness)
        self.pad = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_ENCRYPTION_INFO_64: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Offset", stringValue: offset.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: size.description, offset: 12, size: 4, children: nil, obj: self),
            .init(label: "Crypt ID", stringValue: cryptID.description, offset: 16, size: 4, children: nil, obj: self),
            .init(label: "Pad", stringValue: pad.description, offset: 20, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
