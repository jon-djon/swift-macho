//
//  LC_SYMTAB.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_SYMTAB: LoadCommand {
    public let header: LoadCommandHeader
    public let symbolTableOffset: UInt32
    public let numSymbols: UInt32
    public let stringTableOffset: UInt32
    public let stringTableSize: UInt32
    
    public let range: Range<Int>
    
    public var symbolTableSize: Int {
        Int(numSymbols) * 16
    }
}

extension LC_SYMTAB {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_SYMTAB else {
            throw MachOError.LoadCommandError("Invalid LC_SYMTAB")
        }
        
        self.symbolTableOffset = try UInt32(parsing: &input, endianness: endianness)
        self.numSymbols = try UInt32(parsing: &input, endianness: endianness)
        self.stringTableOffset = try UInt32(parsing: &input, endianness: endianness)
        self.stringTableSize = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_SYMTAB: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "The **LC_SYMTAB** command is a Mach-O load command that specifies the location and size of the Symbol Table and the String Table within the binary file. Its purpose is to provide the static linker (during the build process), the dynamic linker (dyld) at runtime, and debugging tools (like lldb and nm) with the necessary metadata to resolve names to addresses." }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Symbol Table Offset", stringValue: symbolTableOffset.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Number of Symbols", stringValue: numSymbols.description, offset: 12, size: 4, children: nil, obj: self),
            .init(label: "String Table Offset", stringValue: stringTableOffset.description, offset: 16, size: 4, children: nil, obj: self),
            .init(label: "String Table Size", stringValue: stringTableSize.description, offset: 20, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
