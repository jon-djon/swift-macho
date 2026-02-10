//
//  LC_ATOM_INFO.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_ATOM_INFO: LoadCommand, LoadCommandLinkEdit {
    public let header: LoadCommandHeader
    public let offset: UInt32
    public let size: UInt32
    
    public let range: Range<Int>
}

extension LC_ATOM_INFO {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_ATOM_INFO else {
            throw MachOError.LoadCommandError("Invalid LC_ATOM_INFO")
        }
        
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_ATOM_INFO: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "The **LC_ATOM_INFO** command is a Mach-O load command that contains the file offset and size of atom info data used by the linker. This information describes the boundaries of atoms (indivisible code or data blocks) in the __text section, which helps the linker perform optimizations and dead code stripping." }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Offset", stringValue: offset.hexDescription, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: size.description, offset: 12, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
