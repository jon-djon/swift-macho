//
//  LC_SEGMENT.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_SEGMENT: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_SEGMENT
    public let header: LoadCommandHeader
    public let name: String
    public let vmaddr: UInt32
    public let vmsize: UInt32
    public let fileOffset: UInt32
    public let fileSize: UInt32
    public let maxProt: VM_PROT
    public let initProt: VM_PROT
    public let nsects: UInt32
    public let flags: SegmentFlags
    public let sections: [Section32]

    public let range: Range<Int>
}

extension LC_SEGMENT {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        var span = try input.sliceSpan(byteCount: 16)
        self.name = String(parsingUTF8: &span).trimmingCharacters(in: CharacterSet(charactersIn: "\0"))

        self.vmaddr = try UInt32(parsing: &input, endianness: endianness)
        self.vmsize = try UInt32(parsing: &input, endianness: endianness)
        self.fileOffset = try UInt32(parsing: &input, endianness: endianness)
        self.fileSize = try UInt32(parsing: &input, endianness: endianness)
        self.maxProt = try VM_PROT(parsing: &input, endianness: endianness)
        self.initProt = try VM_PROT(parsing: &input, endianness: endianness)
        self.nsects = try UInt32(parsing: &input, endianness: endianness)
        self.flags = try SegmentFlags(parsing: &input, endianness: endianness)

        self.sections = try Array(parsing: &input, count: Int(self.nsects)) { input in
            var symbolSpan = try input.sliceSpan(byteCount: Section32.size)
            return try Section32(parsing: &symbolSpan, endianness: endianness)
        }
    }
}

extension LC_SEGMENT: Displayable {
    public var description: String {
        """
        Defines a 32-bit segment of the binary that is mapped into memory at runtime.

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
        b.add(label: "VM Address", stringValue: vmaddr.hexDescription, size: 4)
        b.add(label: "VM Size", stringValue: vmsize.description, size: 4)
        b.add(label: "File Offset", stringValue: fileOffset.description, size: 4)
        b.add(label: "File Size", stringValue: fileSize.description, size: 4)
        b.add(label: "Max Protections", stringValue: maxProt.description, size: 4)
        b.add(label: "Initial Protections", stringValue: initProt.description, size: 4)
        b.add(label: "Number of Sections", stringValue: nsects.description, size: 4)
        b.add(label: "Flags", stringValue: flags.description, size: 4)
        b.add(
            label: "Sections", stringValue: "\(nsects.description) Sections", offset: 56,
            size: Int(nsects) * Section32.size,
            children: sections.enumerated().map { (index: Int, section: Section32) in
                .init(
                    label: "Section \(index.description)", stringValue: section.description,
                    offset: 56 + index * Section32.size, size: 4, children: section.fields,
                    obj: self)
            })
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
