import Foundation
import BinaryParsing


public struct MachO: Parseable {
    public let magic: Magic
    public let header: MachOHeader
    public let loadCommands: [LoadCommandValue]
    
    public let range: Range<Int>
    
    public var rawCommands: [LoadCommand] {
        loadCommands.map { $0.command }
    }
    
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
}

extension MachO {
    public var entitlements: [String]? {
        guard let (_,signature) = getSignature() else { return nil }
        return signature.entitlements
    }
    
    // TODO: Update this to throw if out of bounds
    public func getAbsoluteOffset(_ offset: Int) -> Int {
        return range.lowerBound + offset
    }
}


extension MachO: ExpressibleByParsing {
    public init(parsing input: inout ParserSpan) throws {
        // The passed in input should already be set to the given macho range
        let machORange = input.parserRange
        self.range = input.parserRange.range
        
        // try #magicNumber("FE", parsing: &input)
        guard
            let magic = try? Magic(parsing: &input, endianness: .big)
        else { throw MachOError.unsupportedMachO("MachO") }
        self.magic = magic
        var span = try input.sliceSpan(byteCount: self.magic.headerSize)
        self.header = try MachOHeader(parsing: &span, magic: self.magic)
        
        let endianness = self.magic.endian
        let is64Bit = self.magic.is64Bit
        
        // First pass is the get all of the command info
        // Some commands (LinkEdit) contain an offset/size that points to other places inside the machO, those get parsed in the next pass
        let cmds:[LoadCommand] = try Array(parsing: &input, count: Int(self.header.ncmds)) { input in
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
        var loadCommands: [LoadCommandValue] = []
        for loadCommand in cmds {
//            print(loadCommand.header.id.description)
            switch loadCommand.header.id {
            case .LC_CODE_SIGNATURE:
                guard let cmd = loadCommand as? LC_CODE_SIGNATURE else { throw MachOError.unknownError }
                    
                try input.seek(toRange: machORange)
                try input.seek(toRelativeOffset: cmd.offset)
                var span = try input.sliceSpan(byteCount: Int(cmd.size))
                
                loadCommands.append(LoadCommandValue.LC_CODE_SIGNATURE(cmd, try CodeSignatureSuperBlob(parsing: &span)))
            case .LC_UUID:
                guard let cmd = loadCommand as? LC_UUID else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_UUID(cmd))
            case .LC_FUNCTION_STARTS:
                guard let cmd = loadCommand as? LC_FUNCTION_STARTS else { throw MachOError.unknownError }
                try input.seek(toRange: machORange)
                try input.seek(toRelativeOffset: cmd.offset)
                var span = try input.sliceSpan(byteCount: Int(cmd.size))
                
                loadCommands.append(LoadCommandValue.LC_FUNCTION_STARTS(cmd, try FunctionStarts(parsing: &span)))
            case .LC_LOAD_DYLIB:
                guard let cmd = loadCommand as? LC_LOAD_DYLIB else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_LOAD_DYLIB(cmd))
            case .LC_LOAD_WEAK_DYLIB:
                guard let cmd = loadCommand as? LC_LOAD_WEAK_DYLIB else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_LOAD_WEAK_DYLIB(cmd))
            case .LC_DYLD_ENVIRONMENT:
                guard let cmd = loadCommand as? LC_DYLD_ENVIRONMENT else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_DYLD_ENVIRONMENT(cmd))
            case .LC_DYLD_INFO_ONLY:
                guard let cmd = loadCommand as? LC_DYLD_INFO_ONLY else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_DYLD_INFO_ONLY(cmd))
            case .LC_ENCRYPTION_INFO:
                guard let cmd = loadCommand as? LC_ENCRYPTION_INFO else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_ENCRYPTION_INFO(cmd))
            case .LC_ENCRYPTION_INFO_64:
                guard let cmd = loadCommand as? LC_ENCRYPTION_INFO_64 else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_ENCRYPTION_INFO_64(cmd))
            case .LC_SEGMENT:
                guard let cmd = loadCommand as? LC_SEGMENT else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_SEGMENT(cmd))
            case .LC_SYMTAB:
                guard let cmd = loadCommand as? LC_SYMTAB else { throw MachOError.unknownError }
                
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
                
                loadCommands.append(LoadCommandValue.LC_SYMTAB(cmd, symbols, strings))
            case .LC_SYMSEG:
                guard let cmd = loadCommand as? LC_SYMSEG else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_SYMSEG(cmd))
            case .LC_THREAD:
                guard let cmd = loadCommand as? LC_THREAD else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_THREAD(cmd))
            case .LC_UNIXTHREAD:
                guard let cmd = loadCommand as? LC_UNIXTHREAD else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_UNIXTHREAD(cmd))
            case .LC_LOADFVMLIB:
                guard let cmd = loadCommand as? LC_LOADFVMLIB else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_LOADFVMLIB(cmd))
            case .LC_IDFVMLIB:
                guard let cmd = loadCommand as? LC_IDFVMLIB else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_IDFVMLIB(cmd))
            case .LC_IDENT:
                guard let cmd = loadCommand as? LC_IDENT else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_IDENT(cmd))
            case .LC_FVMFILE:
                guard let cmd = loadCommand as? LC_FVMFILE else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_FVMFILE(cmd))
            case .LC_PREPAGE:
                guard let cmd = loadCommand as? LC_PREPAGE else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_PREPAGE(cmd))
            case .LC_DYSYMTAB:
                guard let cmd = loadCommand as? LC_DYSYMTAB else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_DYSYMTAB(cmd))
            case .LC_LOAD_DYLINKER:
                guard let cmd = loadCommand as? LC_LOAD_DYLINKER else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_LOAD_DYLINKER(cmd))
            case .LC_ID_DYLINKER:
                guard let cmd = loadCommand as? LC_ID_DYLINKER else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_ID_DYLINKER(cmd))
            case .LC_PREBOUND_DYLIB:
                guard let cmd = loadCommand as? LC_PREBOUND_DYLIB else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_PREBOUND_DYLIB(cmd))
            case .LC_ROUTINES:
                guard let cmd = loadCommand as? LC_ROUTINES else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_ROUTINES(cmd))
            case .LC_SUB_FRAMEWORK:
                guard let cmd = loadCommand as? LC_SUB_FRAMEWORK else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_SUB_FRAMEWORK(cmd))
            case .LC_SUB_UMBRELLA:
                guard let cmd = loadCommand as? LC_SUB_UMBRELLA else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_SUB_UMBRELLA(cmd))
            case .LC_SUB_CLIENT:
                guard let cmd = loadCommand as? LC_SUB_CLIENT else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_SUB_CLIENT(cmd))
            case .LC_SUB_LIBRARY:
                guard let cmd = loadCommand as? LC_SUB_LIBRARY else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_SUB_LIBRARY(cmd))
            case .LC_TWOLEVEL_HINTS:
                guard let cmd = loadCommand as? LC_TWOLEVEL_HINTS else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_TWOLEVEL_HINTS(cmd))
            case .LC_PREBIND_CKSUM:
                guard let cmd = loadCommand as? LC_PREBIND_CKSUM else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_PREBIND_CKSUM(cmd))
            case .LC_SEGMENT_64:
                guard let cmd = loadCommand as? LC_SEGMENT_64 else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_SEGMENT_64(cmd))
            case .LC_ROUTINES_64:
                guard let cmd = loadCommand as? LC_ROUTINES_64 else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_ROUTINES_64(cmd))
            case .LC_RPATH:
                guard let cmd = loadCommand as? LC_RPATH else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_RPATH(cmd))
            case .LC_SEGMENT_SPLIT_INFO:
                guard let cmd = loadCommand as? LC_SEGMENT_SPLIT_INFO else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_SEGMENT_SPLIT_INFO(cmd))
            case .LC_REEXPORT_DYLIB:
                guard let cmd = loadCommand as? LC_REEXPORT_DYLIB else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_REEXPORT_DYLIB(cmd))
            case .LC_LAZY_LOAD_DYLIB:
                guard let cmd = loadCommand as? LC_LAZY_LOAD_DYLIB else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_LAZY_LOAD_DYLIB(cmd))
            case .LC_DYLD_INFO:
                guard let cmd = loadCommand as? LC_DYLD_INFO else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_DYLD_INFO(cmd))
            case .LC_LOAD_UPWARD_DYLIB:
                guard let cmd = loadCommand as? LC_LOAD_UPWARD_DYLIB else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_LOAD_UPWARD_DYLIB(cmd))
            case .LC_VERSION_MIN_MACOSX:
                guard let cmd = loadCommand as? LC_VERSION_MIN_MACOSX else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_VERSION_MIN_MACOSX(cmd))
            case .LC_DYLD_CHAINED_FIXUPS:
                guard let cmd = loadCommand as? LC_DYLD_CHAINED_FIXUPS else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_DYLD_CHAINED_FIXUPS(cmd))
            case .LC_VERSION_MIN_IPHONEOS:
                guard let cmd = loadCommand as? LC_VERSION_MIN_IPHONEOS else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_VERSION_MIN_IPHONEOS(cmd))
            case .LC_MAIN:
                guard let cmd = loadCommand as? LC_MAIN else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_MAIN(cmd))
            case .LC_DATA_IN_CODE:
                guard let cmd = loadCommand as? LC_DATA_IN_CODE else { throw MachOError.unknownError }
                
                try input.seek(toRange: machORange)
                try input.seek(toRelativeOffset: cmd.offset)
                var span = try input.sliceSpan(byteCount: Int(cmd.size))
                
                let datas = try Array(parsing: &span, count: Int(cmd.size) / DataInCode.size) { input in
                    var span = try input.sliceSpan(byteCount: DataInCode.size)
                    return try DataInCode(parsing: &span, endianness: endianness)
                }
                
                loadCommands.append(LoadCommandValue.LC_DATA_IN_CODE(cmd, datas))
            case .LC_SOURCE_VERSION:
                guard let cmd = loadCommand as? LC_SOURCE_VERSION else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_SOURCE_VERSION(cmd))
            case .LC_DYLIB_CODE_SIGN_DRS:
                guard let cmd = loadCommand as? LC_DYLIB_CODE_SIGN_DRS else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_DYLIB_CODE_SIGN_DRS(cmd))
            case .LC_LINKER_OPTION:
                guard let cmd = loadCommand as? LC_LINKER_OPTION else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_LINKER_OPTION(cmd))
            case .LC_LINKER_OPTIMIZATION_HINT:
                guard let cmd = loadCommand as? LC_LINKER_OPTIMIZATION_HINT else { throw MachOError.unknownError }
                
                try input.seek(toRange: machORange)
                try input.seek(toRelativeOffset: cmd.offset)
                var span = try input.sliceSpan(byteCount: Int(cmd.size))
                
                loadCommands.append(LoadCommandValue.LC_LINKER_OPTIMIZATION_HINT(cmd, try LinkEditRaw(parsing: &span, endianness: endianness)))
            case .LC_VERSION_MIN_TVOS:
                guard let cmd = loadCommand as? LC_VERSION_MIN_TVOS else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_VERSION_MIN_TVOS(cmd))
            case .LC_VERSION_MIN_WATCHOS:
                guard let cmd = loadCommand as? LC_VERSION_MIN_WATCHOS else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_VERSION_MIN_WATCHOS(cmd))
            case .LC_NOTE:
                guard let cmd = loadCommand as? LC_NOTE else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_NOTE(cmd))
            case .LC_BUILD_VERSION:
                guard let cmd = loadCommand as? LC_BUILD_VERSION else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_BUILD_VERSION(cmd))
            case .LC_DYLD_EXPORTS_TRIE:
                guard let cmd = loadCommand as? LC_DYLD_EXPORTS_TRIE else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_DYLD_EXPORTS_TRIE(cmd))
            case .LC_FILESET_ENTRY:
                guard let cmd = loadCommand as? LC_FILESET_ENTRY else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_FILESET_ENTRY(cmd))
            case .LC_ATOM_INFO:
                guard let cmd = loadCommand as? LC_ATOM_INFO else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_ATOM_INFO(cmd))
            case .LC_FUNCTION_VARIANTS:
                guard let cmd = loadCommand as? LC_FUNCTION_VARIANTS else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_FUNCTION_VARIANTS(cmd))
            case .LC_FUNCTION_VARIANT_FIXUPS:
                guard let cmd = loadCommand as? LC_FUNCTION_VARIANT_FIXUPS else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_FUNCTION_VARIANT_FIXUPS(cmd))
            case .LC_TARGET_TRIPLE:
                guard let cmd = loadCommand as? LC_TARGET_TRIPLE else { throw MachOError.unknownError }
                loadCommands.append(LoadCommandValue.LC_TARGET_TRIPLE(cmd))
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
        let magic = data.withParserSpan { input in
            return try? Magic(parsing: &input, endianness: .little)
        }
        return magic != nil
    }

    public func getLoadCommandByType(_ type: LoadCommandHeader.ID) -> LoadCommand? {
        return self.rawCommands.first(where: { $0.header.id == type })
    }
    
    public func getSignature() -> (LC_CODE_SIGNATURE, CodeSignatureSuperBlob)? {
        guard
            let lc = loadCommands.first(where: {
                switch $0 {
                case .LC_CODE_SIGNATURE(_,_): true
                default: false
                }
            }),
            case let .LC_CODE_SIGNATURE(cmd, signature) = lc
        else { return nil }
        
        return (cmd,signature)
    }
    
    public func getCodeDirectory() -> CodeSignatureCodeDirectory? {
        guard
            let (_,signature) = getSignature(),
            let cd = signature.blobs.first(where: {
                switch $0 {
                case .CodeDirectory(_,_): true
                default: false
                }
            }),
            case let .CodeDirectory(_, _cd) = cd
        else { return nil }
        
        return _cd
    }
    
    public func getSegmentByName(_ name: String) -> LC_SEGMENT_64? {
        guard
            let lc = loadCommands.first(where: {
                switch $0 {
                case .LC_SEGMENT_64(let cmd):
                    cmd.name == name
                default: false
                }
            }),
            case let .LC_SEGMENT_64(cmd) = lc
        else { return nil }
        
        return cmd
    }
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
