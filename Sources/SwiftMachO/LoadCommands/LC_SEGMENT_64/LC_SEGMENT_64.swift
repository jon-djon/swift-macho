//
//  LC_SEGMENT_64.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_SEGMENT_64: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_SEGMENT_64
    public let header: LoadCommandHeader
    public let name: String
    public let vmaddr: UInt64
    public let vmsize: UInt64
    public let fileOffset: UInt64
    public let fileSize: UInt64
    public let maxProt: VM_PROT
    public let initProt: VM_PROT
    public let nsects: UInt32
    public let flags: SegmentFlags
    public let sections: [Section64]

    public let range: Range<Int>
}

extension LC_SEGMENT_64 {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        var span = try input.sliceSpan(byteCount: 16)
        self.name = String(parsingUTF8: &span).trimmingCharacters(in: CharacterSet(charactersIn: "\0"))

        self.vmaddr = try UInt64(parsing: &input, endianness: endianness)
        self.vmsize = try UInt64(parsing: &input, endianness: endianness)
        self.fileOffset = try UInt64(parsing: &input, endianness: endianness)
        self.fileSize = try UInt64(parsing: &input, endianness: endianness)
        self.maxProt = try VM_PROT(parsing: &input, endianness: endianness)
        self.initProt = try VM_PROT(parsing: &input, endianness: endianness)
        self.nsects = try UInt32(parsing: &input, endianness: endianness)
        self.flags = try SegmentFlags(parsing: &input, endianness: endianness)

        self.sections = try Array(parsing: &input, count: Int(self.nsects)) { input in
            var symbolSpan = try input.sliceSpan(byteCount: Section64.size)
            return try Section64(parsing: &symbolSpan, endianness: endianness)
        }
    }
}

extension LC_SEGMENT_64: Displayable {
    public var description: String {
        """
        Defines a 64-bit segment of the binary that is mapped into memory at runtime.

        Common segments include:
        `__PAGEZERO`: Guard page at address 0 to catch NULL pointer dereferences
        `__TEXT`: Executable code and read-only data
        `__DATA`: Writable initialized data
        `__DATA_CONST`: Read-only after initialization (e.g., Objective-C metadata)
        `__LINKEDIT`: Metadata used by the dynamic linker (symbols, signatures, etc.)
        """
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Name", stringValue: name, size: 16)
        b.add(label: "VM Address", stringValue: vmaddr.hexDescription, size: 8)
        b.add(label: "VM Size", stringValue: vmsize.description, size: 8)
        b.add(label: "File Offset", stringValue: fileOffset.description, size: 8)
        b.add(label: "File Size", stringValue: fileSize.description, size: 8)
        b.add(label: "Max Protections", stringValue: maxProt.description, size: 4)
        b.add(label: "Initial Protections", stringValue: initProt.description, size: 4)
        b.add(label: "Number of Sections", stringValue: nsects.description, size: 4)
        b.add(label: "Flags", stringValue: flags.description, size: 4)
        b.add(
            label: "Sections", stringValue: "\(nsects.description) Sections", offset: 72,
            size: Int(nsects) * Section64.size,
            children: sections.enumerated().map { (index: Int, section: Section64) in
                .init(
                    label: "Section \(index.description)", stringValue: section.description,
                    offset: 72 + index * Section64.size, size: 4, children: section.fields,
                    obj: self)
            })
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
