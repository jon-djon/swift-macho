//
//  LC_FILESET_ENTRY.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_FILESET_ENTRY: LoadCommand {
    public let header: LoadCommandHeader
    public let range: Range<Int>

    /// Virtual memory address where this entry is mapped
    public let vmaddr: UInt64
    /// File offset to the Mach-O header for this entry
    public let fileoff: UInt64
    /// Offset to the entry ID string (from start of load command)
    public let entryIdOffset: UInt32
    /// Reserved field
    public let reserved: UInt32
    /// The entry identifier string (e.g., kernel extension bundle ID)
    public let entryId: String

    public var entryIdAbsoluteOffset: Int { self.range.lowerBound + Int(self.entryIdOffset) }
}

extension LC_FILESET_ENTRY {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_FILESET_ENTRY else {
            throw MachOError.LoadCommandError("Invalid LC_FILESET_ENTRY")
        }

        self.vmaddr = try UInt64(parsing: &input, endianness: endianness)
        self.fileoff = try UInt64(parsing: &input, endianness: endianness)
        self.entryIdOffset = try UInt32(parsing: &input, endianness: endianness)
        self.reserved = try UInt32(parsing: &input, endianness: endianness)

        // Seek to the string offset and parse the entry ID
        try input.seek(toAbsoluteOffset: self.range.lowerBound)
        try input.seek(toRelativeOffset: self.entryIdOffset)
        self.entryId = try String(parsingNulTerminated: &input)
    }
}

extension LC_FILESET_ENTRY: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "Specifies an entry in a fileset (kernel collection), containing the virtual address, file offset, and identifier for a Mach-O binary within the container." }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "VM Address", stringValue: vmaddr.hexDescription, offset: 8, size: 8, children: nil, obj: self),
            .init(label: "File Offset", stringValue: fileoff.hexDescription, offset: 16, size: 8, children: nil, obj: self),
            .init(label: "Entry ID Offset", stringValue: entryIdOffset.description, offset: 24, size: 4, children: nil, obj: self),
            .init(label: "Reserved", stringValue: reserved.description, offset: 28, size: 4, children: nil, obj: self),
            .init(label: "Entry ID", stringValue: entryId, offset: Int(entryIdOffset), size: entryId.count, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
