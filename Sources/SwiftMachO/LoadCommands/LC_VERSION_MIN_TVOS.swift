//
//  LC_VERSION_MIN_TVOS.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_VERSION_MIN_TVOS: LoadCommand {
    public let header: LoadCommandHeader
    public let range: Range<Int>
}

extension LC_VERSION_MIN_TVOS {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_VERSION_MIN_TVOS else {
            throw MachOError.LoadCommandError("Invalid LC_VERSION_MIN_TVOS")
        }
    }
}

extension LC_VERSION_MIN_TVOS: Displayable {
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