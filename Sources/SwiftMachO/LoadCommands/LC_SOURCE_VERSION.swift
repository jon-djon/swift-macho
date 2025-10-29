//
//  LC_SOURCE_VERSION.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_SOURCE_VERSION: LoadCommand {
    public let header: LoadCommandHeader
    public let version: UInt64
    
    public let range: Range<Int>
}

extension LC_SOURCE_VERSION {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_SOURCE_VERSION else {
            throw MachOError.LoadCommandError("Invalid LC_SOURCE_VERSION")
        }
        self.version = try UInt64(parsing: &input, endianness: endianness)
    }
}

extension LC_SOURCE_VERSION: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Version", stringValue: version.description, offset: 8, size: 8, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
