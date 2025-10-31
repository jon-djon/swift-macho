//
//  LC_SEGMENT_64.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing


@AutoOptionSet
public struct VM_PROT: OptionSet, Sendable {
    // public static let VM_PROT_NONE = VM_PROT(rawValue: 0x00000000)
    public static let VM_PROT_READ = VM_PROT(rawValue: 0x00000001)
    public static let VM_PROT_WRITE = VM_PROT(rawValue: 0x00000002)
    public static let VM_PROT_EXECUTE = VM_PROT(rawValue: 0x00000004)
    public static let VM_PROT_DEFAULT = VM_PROT(rawValue: 0x00000003)
    public static let VM_PROT_RORW_TP = VM_PROT(rawValue: 0x00000004)
    public static let VM_PROT_NO_CHANGE_LEGACY = VM_PROT(rawValue: 0x00000008)
    public static let VM_PROT_NO_CHANGE = VM_PROT(rawValue: 0x01000000)
    public static let VM_PROT_COPY = VM_PROT(rawValue: 0x00000010)
    public static let VM_PROT_WANTS_COPY = VM_PROT(rawValue: 0x00000010)
    public static let VM_PROT_IS_MASK = VM_PROT(rawValue: 0x00000040)
    public static let VM_PROT_STRIP_READ = VM_PROT(rawValue: 0x00000080)
    public static let VM_PROT_EXECUTE_ONLY = VM_PROT(rawValue: 0x00000084)
    public static let VM_PROT_TPRO = VM_PROT(rawValue: 0x00000200)
    public static let VM_PROT_ALLEXEC = VM_PROT(rawValue: 0x00000004)
}

@AutoOptionSet
public struct SegmentFlags: OptionSet, Sendable {
    // public static let NONE = SegmentFlags(rawValue: 0)
    public static let HIGH_VM = SegmentFlags(rawValue: 0x00000001)
    public static let FIXED_VM_LIBRARY = SegmentFlags(rawValue: 0x00000002)
    public static let NO_RELOCATIONS = SegmentFlags(rawValue: 0x00000004)
    public static let PROTECTED_V1 = SegmentFlags(rawValue: 0x00000008)
    public static let READ_ONLY = SegmentFlags(rawValue: 0x00000010)
}

public struct Section64: Parseable {
    public let sectionName: String  // 16 [UInt8]
    public let segmentName: String  // 16 [UInt8]
    public let address: UInt64
    public let size: UInt64
    public let offset: UInt32
    public let alignment: UInt32
    public let relocOffset: UInt32
    public let nRelocs: UInt32
    //public let flags: SectionFlags
    public let flags: UInt32
    public let reserved1: UInt32
    public let reserved2: UInt32
    public let reserved3: UInt32
    
    public let range: Range<Int>
    
    public static let size: Int = 80
    
    // https://github.com/blacktop/go-macho/blob/master/types/section.go#L74
    // TBD
    public struct SectionFlags: CustomStringConvertible {
        public let type: SectionType
        public let attributes: SectionAttributes
        
        public var description: String {
            "TBD"
        }
        
        // https://llvm.org/doxygen/namespacellvm_1_1MachO.html#a48b52b2439385a6f96a6e50defb27409aef454b668afac80edb50282845c9fcc9
        @AutoOptionSet
        public struct SectionType: OptionSet, Sendable {
            public static let REGULAR: SectionType = SectionType(rawValue: 0x00000000)
            public static var ZERO_FILL: SectionType { .init(rawValue: 0x00000001) }
            public static var CSTRING_LITERALS: SectionType { .init(rawValue: 0x00000002) }
            public static var BYTE_LITERALS4: SectionType { .init(rawValue: 0x000000003) }
            public static var BYTE_LITERALS8: SectionType { .init(rawValue: 0x00000004) }
            public static var LITERAL_POINTERS: SectionType { .init(rawValue: 0x00000005) }
        }
        
        @AutoOptionSet
        public struct SectionAttributes: OptionSet, Sendable {
            public static let PURE_INSTRUCTIONS = SectionAttributes(rawValue: 0x00000000)
        }
        
        init(_ value: UInt32) {
            self.type = SectionType(rawValue: value & 0x000000ff)
            self.attributes = SectionAttributes(rawValue: value & 0xffffff00)
        }
    }
}

extension Section64 {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        var span = try input.sliceSpan(byteCount: 16)
        self.sectionName = String(parsingUTF8: &span)
        span = try input.sliceSpan(byteCount: 16)
        self.segmentName = String(parsingUTF8: &span)
        
        self.address = try UInt64(parsing: &input, endianness: endianness)
        self.size = try UInt64(parsing: &input, endianness: endianness)
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.alignment = try UInt32(parsing: &input, endianness: endianness)
        self.relocOffset = try UInt32(parsing: &input, endianness: endianness)
        self.nRelocs = try UInt32(parsing: &input, endianness: endianness)
        self.flags = try UInt32(parsing: &input, endianness: endianness)
        self.reserved1 = try UInt32(parsing: &input, endianness: endianness)
        self.reserved2 = try UInt32(parsing: &input, endianness: endianness)
        self.reserved3 = try UInt32(parsing: &input, endianness: endianness)
    }
}


public struct LC_SEGMENT_64: LoadCommand {
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
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_SEGMENT_64 else {
            throw MachOError.LoadCommandError("Invalid LC_SEGMENT_64")
        }
        var span = try input.sliceSpan(byteCount: 16)
        self.name = String(parsingUTF8: &span)
        
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
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Name", stringValue: name, offset: 8, size: 16, children: nil, obj: self),
            .init(label: "VM Address", stringValue: vmaddr.hexDescription, offset: 24, size: 8, children: nil, obj: self),
            .init(label: "VM Size", stringValue: vmsize.description, offset: 32, size: 8, children: nil, obj: self),
            .init(label: "File Offset", stringValue: fileOffset.description, offset: 40, size: 8, children: nil, obj: self),
            .init(label: "File Size", stringValue: fileSize.description, offset: 48, size: 8, children: nil, obj: self),
            .init(label: "Max Protections", stringValue: maxProt.description, offset: 56, size: 4, children: nil, obj: self),
            .init(label: "Initial Protections", stringValue: initProt.description, offset: 60, size: 4, children: nil, obj: self),
            .init(label: "Number of Sections", stringValue: nsects.description, offset: 64, size: 4, children: nil, obj: self),
            .init(label: "Flags", stringValue: flags.description, offset: 68, size: 4, children: nil, obj: self),
            .init(label: "Sections", stringValue: "\(nsects.description) Sections", offset: 72, size: Int(nsects)*Section64.size,
                  children: sections.enumerated().map { (index: Int, section: Section64) in
                          .init(label: "Section \(index.description)", stringValue: section.description, offset: 72+index*Section64.size, size: 4, children: section.fields, obj: self)
                  },
                  obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}

extension Section64: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "\(segmentName).\(sectionName)" }
    public var fields: [DisplayableField] {
        [
          .init(label: "Section Name", stringValue: sectionName, offset: 0, size: 16, children: nil, obj: self),
          .init(label: "Segment Name", stringValue: segmentName, offset: 16, size: 16, children: nil, obj: self),
          .init(label: "Address", stringValue: address.description, offset: 32, size: 8, children: nil, obj: self),
          .init(label: "Size", stringValue: size.description, offset: 40, size: 8, children: nil, obj: self),
          .init(label: "Offset", stringValue: offset.description, offset: 48, size: 8, children: nil, obj: self),
          .init(label: "Alignment", stringValue: alignment.description, offset: 52, size: 4, children: nil, obj: self),
          .init(label: "Relocations Offset", stringValue: sectionName, offset: 56, size: 4, children: nil, obj: self),
          .init(label: "Number of Relocations", stringValue: nRelocs.description, offset: 60, size: 4, children: nil, obj: self),
          .init(label: "Flags", stringValue: flags.description, offset: 64, size: 4, children: nil, obj: self),
          .init(label: "Reserved 1", stringValue: reserved1.description, offset: 8, size: 4, children: nil, obj: self),
          .init(label: "Reserved 2", stringValue: reserved2.description, offset: 72, size: 4, children: nil, obj: self),
          .init(label: "Reserved 3", stringValue: reserved3.description, offset: 76, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
