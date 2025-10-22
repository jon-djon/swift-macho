//
//  LC_DYSYMTAB.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_DYSYMTAB: LoadCommand {
    public let header: LoadCommandHeader
    public let localSymbolIndex: UInt32
    public let numLocalSymbols: UInt32
    public let externalSymbolIndex: UInt32
    public let numExternalSymbols: UInt32
    // TODO: Lots of more fields here to parse
    public let range: Range<Int>
}

extension LC_DYSYMTAB {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_DYSYMTAB else {
            throw MachOError.LoadCommandError("Invalid LC_DYSYMTAB")
        }
        self.localSymbolIndex = try UInt32(parsing: &input, endianness: endianness)
        self.numLocalSymbols = try UInt32(parsing: &input, endianness: endianness)
        self.externalSymbolIndex = try UInt32(parsing: &input, endianness: endianness)
        self.numExternalSymbols = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_DYSYMTAB: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Local Symbol Index", stringValue: localSymbolIndex.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Number of Local Symbols", stringValue: numLocalSymbols.description, offset: 12, size: 4, children: nil, obj: self),
            .init(label: "External Symbol Index", stringValue: externalSymbolIndex.description, offset: 16, size: 4, children: nil, obj: self),
            .init(label: "Number of External Symbols", stringValue: numExternalSymbols.description, offset: 20, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
