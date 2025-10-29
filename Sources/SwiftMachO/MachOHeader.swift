import Foundation
import BinaryParsing

public enum MachOHeaderError: Error, CustomStringConvertible {
    case badMagicValue(UInt32)
    case unknownError

    public var description: String {
        switch self {
        case .badMagicValue(let value):
            return "MachOHeaderError: The file format with magic value '\(value.hexDescription)' is not supported."
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
    
    @CaseName
    public enum FileType: UInt32 {
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
    }
    
    @AutoOptionSet
    public struct Flags: OptionSet, Sendable {
        public static let MH_NOUNDEFS = Flags(rawValue: 0x1)
        public static let MH_INCRLINK = Flags(rawValue: 0x2)
        public static let MH_DYLDLINK = Flags(rawValue: 0x4)
        public static let MH_BINDATLOAD = Flags(rawValue: 0x8)
        public static let MH_PREBOUND = Flags(rawValue: 0x10)
        public static let MH_SPLIT_SEGS = Flags(rawValue: 0x20)
        public static let MH_LAZY_INIT = Flags(rawValue: 0x40)
        public static let MH_TWOLEVEL = Flags(rawValue: 0x80)
        public static let MH_FORCE_FLAT = Flags(rawValue: 0x100)
        public static let MH_NOMULTIDEFS = Flags(rawValue: 0x200)
        public static let MH_NOFIXPREBINDING = Flags(rawValue: 0x400)
        public static let MH_PREBINDABLE = Flags(rawValue: 0x800)
        public static let MH_ALLMODSBOUND = Flags(rawValue: 0x1000)
        public static let MH_SUBSECTIONS_VIA_SYMBOLS = Flags(rawValue: 0x2000)
        public static let MH_CANONICAL = Flags(rawValue: 0x4000)
        public static let MH_WEAK_DEFINES = Flags(rawValue: 0x8000)
        public static let MH_BINDS_TO_WEAK = Flags(rawValue: 0x10000)
        public static let MH_ALLOW_STACK_EXECUTION = Flags(rawValue: 0x20000)
        public static let MH_ROOT_SAFE = Flags(rawValue: 0x40000)
        public static let MH_SETUID_SAFE = Flags(rawValue: 0x80000)
        public static let MH_NO_REEXPORTED_DYLIBS = Flags(rawValue: 0x100000)
        public static let MH_PIE = Flags(rawValue: 0x200000)
        public static let MH_DEAD_STRIPPABLE_DYLIB = Flags(rawValue: 0x400000)
        public static let MH_HAS_TLV_DESCRIPTORS = Flags(rawValue: 0x800000)
        public static let MH_NO_HEAP_EXECUTION = Flags(rawValue: 0x1000000)
        public static let MH_APP_EXTENSION_SAFE = Flags(rawValue: 0x02000000)
        public static let MH_NLIST_OUTOFSYNC_WITH_DYLDINFO = Flags(rawValue: 0x04000000)
        public static let MH_SIM_SUPPORT = Flags(rawValue: 0x08000000)
        public static let MH_DYLIB_IN_CACHE = Flags(rawValue: 0x80000000)
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
            .init(label: "Flags", stringValue: "0x\(flags.rawValue.hexDescription)", offset: 20, size: 4,
                  children: flags.activeFlags.enumerated().map { (index: Int, flag: (Flags, String))  in
                        .init(label: flag.1, stringValue: "0x\(flag.0.rawValue.hexDescription)", offset: 24, size: 4, children: nil, obj: self)
                  },
                  obj: self
            ),
        ]
        if let reserved = reserved {
            fields.append(.init(label: "Reserved", stringValue: "0x\(reserved.hexDescription)", offset: 24, size: 4, children: nil, obj: self))
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
