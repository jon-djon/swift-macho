import Foundation
import BinaryParsing


public struct MachO: Parseable {
    public let magic: Magic
    public let header: MachOHeader
    public let loadCommands: [LoadCommand]
    
    public let range: Range<Int>
    
    public var signature: CodeSignatureSuperBlob? = nil
    
    @CaseName
    public enum Magic: UInt32 {
        case macho32 = 0xfeedface
        case macho64 = 0xfeedfacf
        case macho32Swapped = 0xcefaedfe
        case macho64Swapped = 0xcffaedfe

        public var is64Bit: Bool {
            switch self {
            case .macho64, .macho64Swapped: true
            default: false
            }
        }
        
        public var endian: Endianness {
            switch self {
            case .macho32Swapped, .macho64Swapped: .little
            default: .big
            }
        }
        
        public var headerSize: Int {
            is64Bit ? 28 : 24
        }
    }
    
    // TODO: Update this to throw if out of bounds
    public func getAbsoluteOffset(_ offset: Int) -> Int {
        return range.lowerBound + offset
    }
}

extension MachO: ExpressibleByParsing {
    public init(parsing input: inout ParserSpan) throws {
        print("Macho Range \(input.parserRange)")
        
        // The passed in input should already be set to the given macho range
        let machORange = input.parserRange
        self.range = input.parserRange.lowerBound..<input.parserRange.upperBound
        
        // try #magicNumber("FE", parsing: &input)
        self.magic = try Magic(parsingBigEndian: &input)
        var span = try input.sliceSpan(byteCount: self.magic.headerSize)
        self.header = try MachOHeader(parsing: &span, magic: self.magic)
        
        let endianness = self.magic.endian
        let is64Bit = self.magic.is64Bit
        
        // First pass is the get all of the command info
        // Some commands (LinkEdit) contain an offset/size that points to other places inside the machO, those get parsed in the next pass
        var loadCommands:[LoadCommand] = try Array(parsing: &input, count: Int(self.header.ncmds)) { input in
            // Grab the header
            let header = try LoadCommandHeader(parsing: &input, endianness: endianness)
            
            // Rollback the input start position and grab the span for the command
            try input.seek(toAbsoluteOffset: input.startPosition - 8)
            var span = try input.sliceSpan(byteCount: header.cmdSize)
            
            switch header.id {
            case .LC_CODE_SIGNATURE: return try LC_CODE_SIGNATURE(parsing: &span, endianness: endianness)
            case .LC_UUID: return try LC_UUID(parsing: &span, endianness: endianness)
            case .LC_FUNCTION_STARTS: return try LC_FUNCTION_STARTS(parsing: &span, endianness: endianness)
            case .LC_LOAD_DYLIB: return try LC_LOAD_DYLIB(parsing: &span, endianness: endianness)
            case .LC_LOAD_WEAK_DYLIB: return try LC_LOAD_WEAK_DYLIB(parsing: &span, endianness: endianness)
            case .LC_DYLD_ENVIRONMENT: return try LC_DYLD_ENVIRONMENT(parsing: &span, endianness: endianness)
            case .LC_DYLD_INFO_ONLY: return try LC_DYLD_INFO_ONLY(parsing: &span, endianness: endianness)
            case .LC_ENCRYPTION_INFO: return try LC_ENCRYPTION_INFO(parsing: &span, endianness: endianness)
            case .LC_ENCRYPTION_INFO_64: return try LC_ENCRYPTION_INFO_64(parsing: &span, endianness: endianness)
            case .LC_SEGMENT: return try LC_SEGMENT(parsing: &span, endianness: endianness)
            case .LC_SYMTAB: return try LC_SYMTAB(parsing: &span, endianness: endianness)
            case .LC_SYMSEG: return try LC_SYMSEG(parsing: &span, endianness: endianness)
            case .LC_THREAD:return try LC_THREAD(parsing: &span, endianness: endianness)
            case .LC_UNIXTHREAD: return try LC_UNIXTHREAD(parsing: &span, endianness: endianness)
            case .LC_LOADFVMLIB: return try LC_LOADFVMLIB(parsing: &span, endianness: endianness)
            case .LC_IDFVMLIB: return try LC_IDFVMLIB(parsing: &span, endianness: endianness)
            case .LC_IDENT: return try LC_IDENT(parsing: &span, endianness: endianness)
            case .LC_FVMFILE: return try LC_FVMFILE(parsing: &span, endianness: endianness)
            case .LC_PREPAGE: return try LC_PREPAGE(parsing: &span, endianness: endianness)
            case .LC_DYSYMTAB: return try LC_DYSYMTAB(parsing: &span, endianness: endianness)
            case .LC_LOAD_DYLINKER: return try LC_LOAD_DYLINKER(parsing: &span, endianness: endianness)
            case .LC_ID_DYLINKER: return try LC_ID_DYLINKER(parsing: &span, endianness: endianness)
            case .LC_PREBOUND_DYLIB: return try LC_PREBOUND_DYLIB(parsing: &span, endianness: endianness)
            case .LC_ROUTINES: return try LC_ROUTINES(parsing: &span, endianness: endianness)
            case .LC_SUB_FRAMEWORK: return try LC_SUB_FRAMEWORK(parsing: &span, endianness: endianness)
            case .LC_SUB_UMBRELLA: return try LC_SUB_UMBRELLA(parsing: &span, endianness: endianness)
            case .LC_SUB_CLIENT: return try LC_SUB_CLIENT(parsing: &span, endianness: endianness)
            case .LC_SUB_LIBRARY: return try LC_SUB_LIBRARY(parsing: &span, endianness: endianness)
            case .LC_TWOLEVEL_HINTS: return try LC_TWOLEVEL_HINTS(parsing: &span, endianness: endianness)
            case .LC_PREBIND_CKSUM: return try LC_PREBIND_CKSUM(parsing: &span, endianness: endianness)
            case .LC_SEGMENT_64: return try LC_SEGMENT_64(parsing: &span, endianness: endianness)
            case .LC_ROUTINES_64: return try LC_ROUTINES_64(parsing: &span, endianness: endianness)
            case .LC_RPATH: return try LC_RPATH(parsing: &span, endianness: endianness)
            case .LC_SEGMENT_SPLIT_INFO: return try LC_SEGMENT_SPLIT_INFO(parsing: &span, endianness: endianness)
            case .LC_REEXPORT_DYLIB: return try LC_REEXPORT_DYLIB(parsing: &span, endianness: endianness)
            case .LC_LAZY_LOAD_DYLIB: return try LC_LAZY_LOAD_DYLIB(parsing: &span, endianness: endianness)
            case .LC_DYLD_INFO: return try LC_DYLD_INFO(parsing: &span, endianness: endianness)
            case .LC_LOAD_UPWARD_DYLIB: return try LC_LOAD_UPWARD_DYLIB(parsing: &span, endianness: endianness)
            case .LC_VERSION_MIN_MACOSX: return try LC_VERSION_MIN_MACOSX(parsing: &span, endianness: endianness)
            case .LC_DYLD_CHAINED_FIXUPS: return try LC_DYLD_CHAINED_FIXUPS(parsing: &span, endianness: endianness)
            case .LC_VERSION_MIN_IPHONEOS: return try LC_VERSION_MIN_IPHONEOS(parsing: &span, endianness: endianness)
            case .LC_MAIN: return try LC_MAIN(parsing: &span, endianness: endianness)
            case .LC_DATA_IN_CODE: return try LC_DATA_IN_CODE(parsing: &span, endianness: endianness)
            case .LC_SOURCE_VERSION: return try LC_SOURCE_VERSION(parsing: &span, endianness: endianness)
            case .LC_DYLIB_CODE_SIGN_DRS: return try LC_DYLIB_CODE_SIGN_DRS(parsing: &span, endianness: endianness)
            case .LC_LINKER_OPTION: return try LC_LINKER_OPTION(parsing: &span, endianness: endianness)
            case .LC_LINKER_OPTIMIZATION_HINT: return try LC_LINKER_OPTIMIZATION_HINT(parsing: &span, endianness: endianness)
            case .LC_VERSION_MIN_TVOS: return try LC_VERSION_MIN_TVOS(parsing: &span, endianness: endianness)
            case .LC_VERSION_MIN_WATCHOS: return try LC_VERSION_MIN_WATCHOS(parsing: &span, endianness: endianness)
            case .LC_NOTE: return try LC_NOTE(parsing: &span, endianness: endianness)
            case .LC_BUILD_VERSION: return try LC_BUILD_VERSION(parsing: &span, endianness: endianness)
            case .LC_DYLD_EXPORTS_TRIE: return try LC_DYLD_EXPORTS_TRIE(parsing: &span, endianness: endianness)
            case .LC_FILESET_ENTRY: return try LC_FILESET_ENTRY(parsing: &span, endianness: endianness)
            case .LC_ATOM_INFO: return try LC_ATOM_INFO(parsing: &span, endianness: endianness)
            case .LC_FUNCTION_VARIANTS: return try LC_FUNCTION_VARIANTS(parsing: &span, endianness: endianness)
            case .LC_FUNCTION_VARIANT_FIXUPS: return try LC_FUNCTION_VARIANT_FIXUPS(parsing: &span, endianness: endianness)
            case .LC_TARGET_TRIPLE: return try LC_TARGET_TRIPLE(parsing: &span, endianness: endianness)
            }
        }
        
        // Second pass to fill in deferred parsing items
        for i in loadCommands.indices {
            switch loadCommands[i].header.id {
            case .LC_CODE_SIGNATURE:
                if var cmd = loadCommands[i] as? LC_CODE_SIGNATURE {
                    try input.seek(toRange: machORange)
                    try input.seek(toRelativeOffset: cmd.offset)
                    var span = try input.sliceSpan(byteCount: Int(cmd.size))
                    
                    cmd.signature = try CodeSignatureSuperBlob(parsing: &span)
                    
                    loadCommands[i] = cmd
                }
            case .LC_FUNCTION_STARTS:
                if var cmd = loadCommands[i] as? LC_FUNCTION_STARTS {
                    try input.seek(toRange: machORange)
                    try input.seek(toRelativeOffset: cmd.offset)
                    var span = try input.sliceSpan(byteCount: Int(cmd.size))
                    
                    cmd.starts = try FunctionStarts(parsing: &span)
                    
                    loadCommands[i] = cmd
                }
            case .LC_SYMTAB:
                if var cmd = loadCommands[i] as? LC_SYMTAB {
                    try input.seek(toRange: machORange)
                    try input.seek(toRelativeOffset: cmd.symbolTableOffset)
                    var span = try input.sliceSpan(byteCount: Int(cmd.symbolTableSize))
                    
                    let symbols:[Symbol] = try Array(parsing: &span, count: Int(cmd.numSymbols)) { input in
                        var symbolSpan = try input.sliceSpan(byteCount: is64Bit ? Symbol.size64 : Symbol.size32)
                        return try Symbol(parsing: &symbolSpan, endianness: endianness, is64it: is64Bit)
                    }
                    
                    let strings: [String] = try symbols.map { symbol in
                        try input.seek(toRange: machORange)
                        try input.seek(toRelativeOffset: cmd.stringTableOffset+symbol.n_strx)
                        return try String(parsingNulTerminated: &input)
                    }
                    
                    cmd.symbols = symbols
                    cmd.strings = strings
                    
                    loadCommands[i] = cmd
                }
            default: break
            }
        }
        
        self.loadCommands = loadCommands
    }
}


extension MachO {
    public func getMachoOffset(_ range: Range<Int>) -> Range<Int> {
        range.lowerBound - self.range.lowerBound ..< range.upperBound - self.range.lowerBound
    }
    
    public static func isMachO(data: Data) -> Bool {
        let magic = try? data.withParserSpan { input in
            return try? Magic(parsing: &input, endianness: .little)
        }
        return magic != nil
    }
    
//    public func getSignature() -> (LC_CODE_SIGNATURE, CodeSignatureSuperBlob)? {
//        guard
//            let value = loadCommandsValues.first(where: {
//                switch $0 {
//                case .LC_CODE_SIGNATURE(let cmd, let signature): true
//                default: false
//                }
//            }),
//            case .LC_CODE_SIGNATURE(let cmd, let signature) = value,
//            let lc_signature = cmd as? LC_CODE_SIGNATURE
//        else { return nil }
//        
//        return (lc_signature, signature)
//    }
    
//    public func getCodeDirectory() -> CodeDirectory? {
//        guard
//            let (cmd,signature) = getSignature(),
//            let cdSlot = signature.slots.first(where: { $0.type == .cdCodeDirectorySlot }),
//            case .CodeDirectoryValue(let cd) = cdSlot.value
//        else { return nil }
//        
//        return nil
//    }
    
//    public func getSegmentByName(_ name: String) -> LC_SEGMENT_64? {
//        guard
//            let value = loadCommandsValues.first(where: {
//                switch $0 {
//                case .LC(let cmd, let signature): true
//                default: false
//                }
//            }),
//            case .LC_CODE_SIGNATURE(let cmd, let signature) = value,
//            let lc_signature = cmd as? LC_CODE_SIGNATURE
//        else { return nil }
//        
//        return (lc_signature, signature)
//    }
}


extension MachO: Displayable {
    public var title: String { "MachO" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Magic", stringValue: magic.description, offset: 0, size: 4, children: nil, obj: self)
        ]
    }
    public var children: [Displayable]? {
        [header] + loadCommands
    }
}
