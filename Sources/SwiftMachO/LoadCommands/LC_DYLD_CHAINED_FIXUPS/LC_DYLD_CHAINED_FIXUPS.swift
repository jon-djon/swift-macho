//
//  LC_DYLD_CHAINED_FIXUPS.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_DYLD_CHAINED_FIXUPS: LoadCommand, LoadCommandLinkEdit {
    public static let expectedID: LoadCommandHeader.ID = .LC_DYLD_CHAINED_FIXUPS
    public let header: LoadCommandHeader
    public let offset: UInt32
    public let size: UInt32

    public let range: Range<Int>
}

extension LC_DYLD_CHAINED_FIXUPS {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_DYLD_CHAINED_FIXUPS: Displayable {
    public var description: String {
        "The **LC_DYLD_CHAINED_FIXUPS** command is a Mach-O load command that specifies the location and size of the chained fixups data used by the dynamic linker (dyld) to apply rebasing and binding operations at runtime. Chained fixups are a modern, highly optimized data format that significantly reduces the size of dynamic linker information and accelerates application launch times by allowing dyld to process fixups more efficiently."
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        addLinkEditFields(to: &b)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
