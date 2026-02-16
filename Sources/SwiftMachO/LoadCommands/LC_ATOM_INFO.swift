//
//  LC_ATOM_INFO.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_ATOM_INFO: LoadCommand, LoadCommandLinkEdit {
    public static let expectedID: LoadCommandHeader.ID = .LC_ATOM_INFO
    public let header: LoadCommandHeader
    public let offset: UInt32
    public let size: UInt32

    public let range: Range<Int>
}

extension LC_ATOM_INFO {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_ATOM_INFO: Displayable {
    public var description: String {
        "The **LC_ATOM_INFO** command is a Mach-O load command that contains the file offset and size of atom info data used by the linker. This information describes the boundaries of atoms (indivisible code or data blocks) in the __text section, which helps the linker perform optimizations and dead code stripping."
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Offset", stringValue: offset.hexDescription, size: 4)
        b.add(label: "Size", stringValue: size.description, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
