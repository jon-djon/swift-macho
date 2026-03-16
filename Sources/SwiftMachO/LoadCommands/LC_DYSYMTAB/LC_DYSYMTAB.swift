//
//  LC_DYSYMTAB.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_DYSYMTAB: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_DYSYMTAB
    public let header: LoadCommandHeader
    public let range: Range<Int>

    public let localSymbolIndex: UInt32
    public let numLocalSymbols: UInt32
    public let externalSymbolIndex: UInt32
    public let numExternalSymbols: UInt32
    public let undefinedSymbolIndex: UInt32
    public let numUndefinedSymbols: UInt32
    public let tocOffset: UInt32
    public let numToc: UInt32
    public let moduleTableOffset: UInt32
    public let numModuleTable: UInt32
    public let externalReferenceSymbolOffset: UInt32
    public let numExternalReferenceSymbols: UInt32
    public let indirectSymbolOffset: UInt32
    public let numIndirectSymbols: UInt32
    public let externalRelocationOffset: UInt32
    public let numExternalRelocations: UInt32
    public let localRelocationOffset: UInt32
    public let numLocalRelocations: UInt32
}

extension LC_DYSYMTAB {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self.localSymbolIndex = try UInt32(parsing: &input, endianness: endianness)
        self.numLocalSymbols = try UInt32(parsing: &input, endianness: endianness)
        self.externalSymbolIndex = try UInt32(parsing: &input, endianness: endianness)
        self.numExternalSymbols = try UInt32(parsing: &input, endianness: endianness)
        self.undefinedSymbolIndex = try UInt32(parsing: &input, endianness: endianness)
        self.numUndefinedSymbols = try UInt32(parsing: &input, endianness: endianness)
        self.tocOffset = try UInt32(parsing: &input, endianness: endianness)
        self.numToc = try UInt32(parsing: &input, endianness: endianness)
        self.moduleTableOffset = try UInt32(parsing: &input, endianness: endianness)
        self.numModuleTable = try UInt32(parsing: &input, endianness: endianness)
        self.externalReferenceSymbolOffset = try UInt32(parsing: &input, endianness: endianness)
        self.numExternalReferenceSymbols = try UInt32(parsing: &input, endianness: endianness)
        self.indirectSymbolOffset = try UInt32(parsing: &input, endianness: endianness)
        self.numIndirectSymbols = try UInt32(parsing: &input, endianness: endianness)
        self.externalRelocationOffset = try UInt32(parsing: &input, endianness: endianness)
        self.numExternalRelocations = try UInt32(parsing: &input, endianness: endianness)
        self.localRelocationOffset = try UInt32(parsing: &input, endianness: endianness)
        self.numLocalRelocations = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_DYSYMTAB: Displayable {
    public var description: String { "Dynamic Symbol Table" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Local Symbol Index", stringValue: localSymbolIndex.description, size: 4)
        b.add(label: "Num Local Symbols", stringValue: numLocalSymbols.description, size: 4)
        b.add(label: "External Symbol Index", stringValue: externalSymbolIndex.description, size: 4)
        b.add(label: "Num External Symbols", stringValue: numExternalSymbols.description, size: 4)
        b.add(
            label: "Undefined Symbol Index", stringValue: undefinedSymbolIndex.description, size: 4)
        b.add(label: "Num Undefined Symbols", stringValue: numUndefinedSymbols.description, size: 4)
        b.add(label: "TOC Offset", stringValue: tocOffset.hexDescription, size: 4)
        b.add(label: "Num TOC Entries", stringValue: numToc.description, size: 4)
        b.add(label: "Module Table Offset", stringValue: moduleTableOffset.hexDescription, size: 4)
        b.add(label: "Num Module Table Entries", stringValue: numModuleTable.description, size: 4)
        b.add(
            label: "Ext Ref Sym Offset", stringValue: externalReferenceSymbolOffset.hexDescription,
            size: 4)
        b.add(
            label: "Num Ext Ref Syms", stringValue: numExternalReferenceSymbols.description, size: 4
        )
        b.add(
            label: "Indirect Sym Offset", stringValue: indirectSymbolOffset.hexDescription, size: 4)
        b.add(label: "Num Indirect Syms", stringValue: numIndirectSymbols.description, size: 4)
        b.add(
            label: "Ext Reloc Offset", stringValue: externalRelocationOffset.hexDescription, size: 4
        )
        b.add(label: "Num Ext Relocs", stringValue: numExternalRelocations.description, size: 4)
        b.add(
            label: "Local Reloc Offset", stringValue: localRelocationOffset.hexDescription, size: 4)
        b.add(label: "Num Local Relocs", stringValue: numLocalRelocations.description, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
