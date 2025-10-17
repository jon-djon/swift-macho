import Foundation
import BinaryParsing

public enum MachOHeaderError: Error, CustomStringConvertible {
    case badMagicValue(UInt32)
    case unknownError

    public var description: String {
        switch self {
        case .badMagicValue(let value):
            return "MachOHeaderError: The file format with magic value '\(value.hex)' is not supported."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}


public struct MachOHeader: Parseable {
    public let cpu: CPU
    public let fileType: FileType
    public let ncmds: UInt32
    public let sizeOfCmds: UInt32
    public let flags: Flags
    public let reserved: UInt32?
    
    public let range: Range<Int>
    
    public enum FileType: UInt32, CustomStringConvertible {
        case MH_OBJECT = 1
        case MH_EXECUTE = 2
        case MH_FVMLIB = 3
        case MH_CORE = 4
        case MH_PRELOAD = 5
        case MH_DYLIB = 6
        case MH_DYLINKER = 7
        case MH_BUNDLE = 8
        case MH_DYLIB_STUB = 9
        case MH_DSYM = 10
        case MH_KEXT_BUNDLE = 11
        case MH_FILESET = 12
        case MH_GPU_EXECUTE = 13
        case MH_GPU_DYLIB = 14
        
        public var description: String {
            switch self {
            case .MH_OBJECT: "MH_OBJECT"
            case .MH_EXECUTE: "MH_EXECUTE"
            case .MH_FVMLIB: "MH_FVMLIB"
            case .MH_CORE: "MH_CORE"
            case .MH_PRELOAD: "MH_PRELOAD"
            case .MH_DYLIB: "MH_DYLIB"
            case .MH_DYLINKER: "MH_DYLINKER"
            case .MH_BUNDLE: "MH_BUNDLE"
            case .MH_DYLIB_STUB: "MH_DYLIB_STUB"
            case .MH_DSYM: "MH_DSYM"
            case .MH_KEXT_BUNDLE: "MH_KEXT_BUNDLE"
            case .MH_FILESET: "MH_FILESET"
            case .MH_GPU_EXECUTE: "MH_GPU_EXECUTE"
            case .MH_GPU_DYLIB: "MH_GPU_DYLIB"
            }
        }
    }
    
    public struct Flags: OptionSet {
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public static var MH_NOUNDEFS: Flags { .init(rawValue: 0x1) }
        public static var MH_INCRLINK: Flags { .init(rawValue: 0x2) }
        public static var MH_DYLDLINK: Flags { .init(rawValue: 0x4) }
        public static var MH_BINDATLOAD: Flags { .init(rawValue: 0x8) }
        public static var MH_PREBOUND: Flags { .init(rawValue: 0x10) }
        public static var MH_SPLIT_SEGS: Flags { .init(rawValue: 0x20) }
        public static var MH_LAZY_INIT: Flags { .init(rawValue: 0x40) }
        public static var MH_TWOLEVEL: Flags { .init(rawValue: 0x80) }
        public static var MH_FORCE_FLAT: Flags { .init(rawValue: 0x100) }
        public static var MH_NOMULTIDEFS: Flags { .init(rawValue: 0x200) }
        public static var MH_NOFIXPREBINDING: Flags { .init(rawValue: 0x400) }
        public static var MH_PREBINDABLE: Flags { .init(rawValue: 0x800) }
        public static var MH_ALLMODSBOUND: Flags { .init(rawValue: 0x1000) }
        public static var MH_SUBSECTIONS_VIA_SYMBOLS: Flags { .init(rawValue: 0x2000) }
        public static var MH_CANONICAL: Flags { .init(rawValue: 0x4000) }
        public static var MH_WEAK_DEFINES: Flags { .init(rawValue: 0x8000) }
        public static var MH_BINDS_TO_WEAK: Flags { .init(rawValue: 0x10000) }
        public static var MH_ALLOW_STACK_EXECUTION: Flags { .init(rawValue: 0x20000) }
        public static var MH_ROOT_SAFE: Flags { .init(rawValue: 0x40000) }
        public static var MH_SETUID_SAFE: Flags { .init(rawValue: 0x80000) }
        public static var MH_NO_REEXPORTED_DYLIBS: Flags { .init(rawValue: 0x100000) }
        public static var MH_PIE: Flags { .init(rawValue: 0x200000) }
        public static var MH_DEAD_STRIPPABLE_DYLIB: Flags { .init(rawValue: 0x400000) }
        public static var MH_HAS_TLV_DESCRIPTORS: Flags { .init(rawValue: 0x800000) }
        public static var MH_NO_HEAP_EXECUTION: Flags { .init(rawValue: 0x1000000) }
        public static var MH_APP_EXTENSION_SAFE: Flags { .init(rawValue: 0x02000000) }
        public static var MH_NLIST_OUTOFSYNC_WITH_DYLDINFO: Flags { .init(rawValue: 0x04000000) }
        public static var MH_SIM_SUPPORT: Flags { .init(rawValue: 0x08000000) }
        public static var MH_DYLIB_IN_CACHE: Flags { .init(rawValue: 0x80000000) }

        static public var debugDescriptions: [(Self, String)] {[
            (.MH_NOUNDEFS, "MH_NOUNDEFS"),
            (.MH_INCRLINK, "MH_INCRLINK"),
            (.MH_DYLDLINK, "MH_DYLDLINK"),
            (.MH_BINDATLOAD, "MH_BINDATLOAD"),
            (.MH_PREBOUND, "MH_PREBOUND"),
            (.MH_SPLIT_SEGS, "MH_SPLIT_SEGS"),
            (.MH_LAZY_INIT, "MH_LAZY_INIT"),
            (.MH_TWOLEVEL, "MH_TWOLEVEL"),
            (.MH_FORCE_FLAT, "MH_FORCE_FLAT"),
            (.MH_NOMULTIDEFS, "MH_NOMULTIDEFS"),
            (.MH_NOFIXPREBINDING, "MH_NOFIXPREBINDING"),
            (.MH_PREBINDABLE, "MH_PREBINDABLE"),
            (.MH_ALLMODSBOUND, "MH_ALLMODSBOUND"),
            (.MH_SUBSECTIONS_VIA_SYMBOLS, "MH_SUBSECTIONS_VIA_SYMBOLS"),
            (.MH_CANONICAL, "MH_CANONICAL"),
            (.MH_WEAK_DEFINES, "MH_WEAK_DEFINES"),
            (.MH_BINDS_TO_WEAK, "MH_BINDS_TO_WEAK"),
            (.MH_ALLOW_STACK_EXECUTION, "MH_ALLOW_STACK_EXECUTION"),
            (.MH_ROOT_SAFE, "MH_ROOT_SAFE"),
            (.MH_SETUID_SAFE, "MH_SETUID_SAFE"),
            (.MH_NO_REEXPORTED_DYLIBS, "MH_NO_REEXPORTED_DYLIBS"),
            (.MH_PIE, "MH_PIE"),
            (.MH_DEAD_STRIPPABLE_DYLIB, "MH_DEAD_STRIPPABLE_DYLIB"),
            (.MH_HAS_TLV_DESCRIPTORS, "MH_HAS_TLV_DESCRIPTORS"),
            (.MH_NO_HEAP_EXECUTION, "MH_NO_HEAP_EXECUTION"),
            (.MH_APP_EXTENSION_SAFE, "MH_APP_EXTENSION_SAFE"),
            (.MH_NLIST_OUTOFSYNC_WITH_DYLDINFO, "MH_NLIST_OUTOFSYNC_WITH_DYLDINFO"),
            (.MH_SIM_SUPPORT, "MH_SIM_SUPPORT"),
            (.MH_DYLIB_IN_CACHE, "MH_DYLIB_IN_CACHE")]
        }
        
        public var flags: [(Self, String)] {
            Self.debugDescriptions.filter { contains($0.0) }
        }
        
        public var descriptionList: [String] {
            Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
        }
        
        public var description: String {
            return "(\(descriptionList.joined(separator: ",")))"
        }
    }
}

extension MachOHeader {
    public init(parsing input: inout ParserSpan, magic: MachO.Magic) throws {
        let start = input.parserRange.lowerBound
        self.cpu = try CPU(parsing: &input, endianness: magic.endian)
        self.fileType = try FileType(parsing: &input, endianness: magic.endian)
        self.ncmds = try UInt32(parsing: &input, endianness: magic.endian)
        self.sizeOfCmds = try UInt32(parsing: &input, endianness: magic.endian)
        self.flags = try Flags(parsing: &input, endianness: magic.endian)
        self.reserved = magic.is64Bit ? try UInt32(parsing: &input, endianness: magic.endian) : nil
        self.range = start..<input.parserRange.lowerBound
    }
}

extension MachOHeader: Displayable {
    public var title: String { "MachO Header" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        var fields: [DisplayableField] = [
            .init(label: "CPU", stringValue: cpu.description, offset: 0, size: 8, children: [
                .init(label: "Type", stringValue: cpu.type.description, offset: 0, size: 8, children: nil, obj: self),
                .init(label: "Subtype", stringValue: cpu.subtype.description, offset: 8, size: 8, children: nil, obj: self),
            ], obj: self),
            .init(label: "File Type", stringValue: fileType.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Number of Commands", stringValue: ncmds.description, offset: 12, size: 4, children: nil, obj: self),
            .init(label: "Size of Commands", stringValue: sizeOfCmds.description, offset: 16, size: 4, children: nil, obj: self),
            .init(label: "Flags", stringValue: "0x\(flags.rawValue.hex)", offset: 20, size: 4,
                  children: flags.flags.enumerated().map { (index: Int, flag: (Flags, String))  in
                        .init(label: flag.1, stringValue: "0x\(flag.0.rawValue.hex)", offset: 24, size: 4, children: nil, obj: self)
                  },
                  obj: self
            ),
        ]
        if let reserved = reserved {
            fields.append(.init(label: "Reserved", stringValue: "0x\(reserved.hex)", offset: 24, size: 4, children: nil, obj: self))
        }
        return fields
    }
    public var children: [Displayable]? { nil }
}

extension MachOHeader {
    func getRelativeMachOHeaderOffset() -> Int? {
        return nil
    }
}
