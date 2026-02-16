//
//  LC_SEGMENT.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct Section32: Parseable {
    public let sectionName: String  // 16 [UInt8]
    public let segmentName: String  // 16 [UInt8]
    public let address: UInt32
    public let size: UInt32
    public let offset: UInt32
    public let alignment: UInt32
    public let relocOffset: UInt32
    public let nRelocs: UInt32
    public let flags: UInt32
    public let reserved1: UInt32
    public let reserved2: UInt32

    public let range: Range<Int>

    public static let size: Int = 68
}

extension Section32 {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        var span = try input.sliceSpan(byteCount: 16)
        self.sectionName = String(parsingUTF8: &span)
        span = try input.sliceSpan(byteCount: 16)
        self.segmentName = String(parsingUTF8: &span)

        self.address = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.alignment = try UInt32(parsing: &input, endianness: endianness)
        self.relocOffset = try UInt32(parsing: &input, endianness: endianness)
        self.nRelocs = try UInt32(parsing: &input, endianness: endianness)
        self.flags = try UInt32(parsing: &input, endianness: endianness)
        self.reserved1 = try UInt32(parsing: &input, endianness: endianness)
        self.reserved2 = try UInt32(parsing: &input, endianness: endianness)
    }
}

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
        self.name = String(parsingUTF8: &span)

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
    public var title: String { "\(Self.self) TODO" }
    public var description: String { """
        Defines a 32-bit segment of the binary that is mapped into memory at runtime.

        Common segments include:
        `__PAGEZERO`: Guard page at address 0 to catch NULL pointer dereferences
        `__TEXT`: Executable code and read-only data
        `__DATA`: Writable initialized data
        `__DATA_CONST`: Read-only after initialization (e.g., Objective-C metadata)
        `__LINKEDIT`: Metadata used by the dynamic linker (symbols, signatures, etc.)
        """ }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Name", stringValue: name, offset: 8, size: 16, children: nil, obj: self),
            .init(label: "VM Address", stringValue: vmaddr.description, offset: 24, size: 4, children: nil, obj: self),
            .init(label: "VM Size", stringValue: vmsize.description, offset: 28, size: 4, children: nil, obj: self),
            .init(label: "File Offset", stringValue: fileOffset.description, offset: 32, size: 4, children: nil, obj: self),
            .init(label: "File Size", stringValue: fileSize.description, offset: 36, size: 4, children: nil, obj: self),
            .init(label: "Max Protections", stringValue: maxProt.description, offset: 40, size: 4, children: nil, obj: self),
            .init(label: "Initial Protections", stringValue: initProt.description, offset: 44, size: 4, children: nil, obj: self),
            .init(label: "Number of Sections", stringValue: nsects.description, offset: 48, size: 4, children: nil, obj: self),
            .init(label: "Flags", stringValue: flags.description, offset: 52, size: 4, children: nil, obj: self),
            .init(label: "Sections", stringValue: "\(nsects.description) Sections", offset: 56, size: Int(nsects)*Section32.size,
                  children: sections.enumerated().map { (index: Int, section: Section32) in
                          .init(label: "Section \(index.description)", stringValue: section.description, offset: 56+index*Section32.size, size: 4, children: section.fields, obj: self)
                  },
                  obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}

extension Section32: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "\(segmentName).\(sectionName)" }
    public var fields: [DisplayableField] {
        [
          .init(label: "Section Name", stringValue: sectionName, offset: 0, size: 16, children: nil, obj: self),
          .init(label: "Segment Name", stringValue: segmentName, offset: 16, size: 16, children: nil, obj: self),
          .init(label: "Address", stringValue: address.description, offset: 32, size: 4, children: nil, obj: self),
          .init(label: "Size", stringValue: size.description, offset: 36, size: 4, children: nil, obj: self),
          .init(label: "Offset", stringValue: offset.description, offset: 40, size: 4, children: nil, obj: self),
          .init(label: "Alignment", stringValue: alignment.description, offset: 44, size: 4, children: nil, obj: self),
          .init(label: "Relocations Offset", stringValue: sectionName, offset: 48, size: 4, children: nil, obj: self),
          .init(label: "Number of Relocations", stringValue: nRelocs.description, offset: 52, size: 4, children: nil, obj: self),
          .init(label: "Flags", stringValue: flags.description, offset: 56, size: 4, children: nil, obj: self),
          .init(label: "Reserved 1", stringValue: reserved1.description, offset: 60, size: 4, children: nil, obj: self),
          .init(label: "Reserved 2", stringValue: reserved2.description, offset: 64, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
