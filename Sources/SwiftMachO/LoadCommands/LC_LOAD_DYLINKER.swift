//
//  LC_LOAD_DYLINKER.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_LOAD_DYLINKER: LoadCommand {
    public let header: LoadCommandHeader
    public let range: Range<Int>
}

extension LC_LOAD_DYLINKER {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_LOAD_DYLINKER else {
            throw MachOError.LoadCommandError("Invalid LC_LOAD_DYLINKER")
        }
    }
}

extension LC_LOAD_DYLINKER: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}