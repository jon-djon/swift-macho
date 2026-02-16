//
//  LC_FILESET_ENTRY.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_FILESET_ENTRY: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_FILESET_ENTRY
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

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

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
    public var description: String {
        "Specifies an entry in a fileset (kernel collection), containing the virtual address, file offset, and identifier for a Mach-O binary within the container."
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "VM Address", stringValue: vmaddr.hexDescription, size: 8)
        b.add(label: "File Offset", stringValue: fileoff.hexDescription, size: 8)
        b.add(label: "Entry ID Offset", stringValue: entryIdOffset.description, size: 4)
        b.add(label: "Reserved", stringValue: reserved.description, size: 4)
        b.add(label: "Entry ID", stringValue: entryId, offset: Int(entryIdOffset), size: entryId.count)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
