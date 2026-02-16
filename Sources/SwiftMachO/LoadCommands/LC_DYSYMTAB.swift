//
//  LC_DYSYMTAB.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_DYSYMTAB: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_DYSYMTAB
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
        
        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self.localSymbolIndex = try UInt32(parsing: &input, endianness: endianness)
        self.numLocalSymbols = try UInt32(parsing: &input, endianness: endianness)
        self.externalSymbolIndex = try UInt32(parsing: &input, endianness: endianness)
        self.numExternalSymbols = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_DYSYMTAB: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "The **LC_DYSYMTAB** (Dynamic Symbol Table) command is a Mach-O load command that specifies the organization and location of the auxiliary symbol tables used exclusively by the dynamic linker (dyld) at runtime. It is used in conjunction with the main symbol table defined by LC_SYMTAB to facilitate efficient and correct dynamic linking." }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Local Symbol Index", stringValue: localSymbolIndex.description, size: 4)
        b.add(label: "Number of Local Symbols", stringValue: numLocalSymbols.description, size: 4)
        b.add(label: "External Symbol Index", stringValue: externalSymbolIndex.description, size: 4)
        b.add(label: "Number of External Symbols", stringValue: numExternalSymbols.description, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
