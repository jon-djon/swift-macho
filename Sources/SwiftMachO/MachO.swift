import BinaryParsing
import Foundation

public struct MachO: Parseable {
    public let magic: BinaryMagic
    public let header: MachOHeader
    public let loadCommands: [LoadCommandValue]

    public let range: Range<Int>
    // public var file: MachOFile?  // TODO: need to decide if the MachO should maintain a reference to the file

    public var rawCommands: [LoadCommand] {
        loadCommands.map { $0.command }
    }
}

extension MachO {
    public var entitlements: [String]? {
        guard let (_, signature) = getSignature() else { return nil }
        return signature.entitlements
    }

    // TODO: Update this to throw if out of bounds
    public func getAbsoluteOffset(_ offset: Int) -> Int {
        return range.lowerBound + offset
    }
}

// Commands that require a second-pass seek into the file's LinkEdit region to load their
// associated data. Stored between passes so the first pass can complete all header reads
// before any seeks are performed.
private enum DeferredCommand {
    case codeSignature(LC_CODE_SIGNATURE)
    case functionStarts(LC_FUNCTION_STARTS)
    case encryptionInfo(LC_ENCRYPTION_INFO)
    case encryptionInfo64(LC_ENCRYPTION_INFO_64)
    case symtab(LC_SYMTAB)
    case dysymtab(LC_DYSYMTAB)
    case segmentSplitInfo(LC_SEGMENT_SPLIT_INFO)
    case dyldChainedFixups(LC_DYLD_CHAINED_FIXUPS)
    case dataInCode(LC_DATA_IN_CODE)
    case dylibCodeSignDRS(LC_DYLIB_CODE_SIGN_DRS)
    case linkerOptimizationHint(LC_LINKER_OPTIMIZATION_HINT)
    case dyldExportsTrie(LC_DYLD_EXPORTS_TRIE)
    case atomInfo(LC_ATOM_INFO)
    case functionVariantFixups(LC_FUNCTION_VARIANT_FIXUPS)

    var commandID: LoadCommandHeader.ID {
        switch self {
        case .codeSignature(let c): c.header.id
        case .functionStarts(let c): c.header.id
        case .encryptionInfo(let c): c.header.id
        case .encryptionInfo64(let c): c.header.id
        case .symtab(let c): c.header.id
        case .dysymtab(let c): c.header.id
        case .segmentSplitInfo(let c): c.header.id
        case .dyldChainedFixups(let c): c.header.id
        case .dataInCode(let c): c.header.id
        case .dylibCodeSignDRS(let c): c.header.id
        case .linkerOptimizationHint(let c): c.header.id
        case .dyldExportsTrie(let c): c.header.id
        case .atomInfo(let c): c.header.id
        case .functionVariantFixups(let c): c.header.id
        }
    }

    var commandOffset: Int {
        switch self {
        case .codeSignature(let c): c.range.lowerBound
        case .functionStarts(let c): c.range.lowerBound
        case .encryptionInfo(let c): c.range.lowerBound
        case .encryptionInfo64(let c): c.range.lowerBound
        case .symtab(let c): c.range.lowerBound
        case .dysymtab(let c): c.range.lowerBound
        case .segmentSplitInfo(let c): c.range.lowerBound
        case .dyldChainedFixups(let c): c.range.lowerBound
        case .dataInCode(let c): c.range.lowerBound
        case .dylibCodeSignDRS(let c): c.range.lowerBound
        case .linkerOptimizationHint(let c): c.range.lowerBound
        case .dyldExportsTrie(let c): c.range.lowerBound
        case .atomInfo(let c): c.range.lowerBound
        case .functionVariantFixups(let c): c.range.lowerBound
        }
    }

    func resolve(
        input: inout ParserSpan,
        machORange: ParserRange,
        endianness: Endianness,
        is64Bit: Bool
    ) throws -> LoadCommandValue {
        switch self {
        case .codeSignature(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_CODE_SIGNATURE(cmd, try CodeSignatureSuperBlob(parsing: &span))

        case .functionStarts(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_FUNCTION_STARTS(cmd, try FunctionStarts(parsing: &span))

        case .encryptionInfo(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_ENCRYPTION_INFO(cmd, try LinkEditRaw(parsing: &span, endianness: endianness))

        case .encryptionInfo64(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_ENCRYPTION_INFO_64(cmd, try LinkEditRaw(parsing: &span, endianness: endianness))

        case .symtab(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.symbolTableOffset)
            var span = try input.sliceSpan(
                byteCount: (is64Bit ? Symbol.size64 : Symbol.size32) * Int(cmd.numSymbols))
            let symbols: [Symbol] = try Array(parsing: &span, count: Int(cmd.numSymbols)) { input in
                var symbolSpan = try input.sliceSpan(
                    byteCount: is64Bit ? Symbol.size64 : Symbol.size32)
                return try Symbol(parsing: &symbolSpan, endianness: endianness, is64it: is64Bit)
            }
            let strings: [String] = try symbols.map { symbol in
                try input.seek(toRange: machORange)
                try input.seek(toRelativeOffset: cmd.stringTableOffset + symbol.n_strx)
                return try String(parsingNulTerminated: &input)
            }
            return .LC_SYMTAB(cmd, symbols, strings)

        case .dysymtab(let cmd):
            let indirectSymbols: [IndirectSymbol]
            if cmd.numIndirectSymbols > 0 {
                try input.seek(toRange: machORange)
                try input.seek(toRelativeOffset: cmd.indirectSymbolOffset)
                var span = try input.sliceSpan(byteCount: 4 * Int(cmd.numIndirectSymbols))
                indirectSymbols = try Array(
                    parsing: &span, count: Int(cmd.numIndirectSymbols)
                ) { input in
                    var entrySpan = try input.sliceSpan(byteCount: 4)
                    return try IndirectSymbol(parsing: &entrySpan, endianness: endianness)
                }
            } else {
                indirectSymbols = []
            }
            return .LC_DYSYMTAB(cmd, indirectSymbols)

        case .segmentSplitInfo(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_SEGMENT_SPLIT_INFO(cmd, try LinkEditRaw(parsing: &span, endianness: endianness))

        case .dyldChainedFixups(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_DYLD_CHAINED_FIXUPS(cmd, try ChainedFixupsData(parsing: &span, endianness: endianness))

        case .dataInCode(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            let entries = try Array(parsing: &span, count: Int(cmd.size) / DataInCode.size) { input in
                var entrySpan = try input.sliceSpan(byteCount: DataInCode.size)
                return try DataInCode(parsing: &entrySpan, endianness: endianness)
            }
            return .LC_DATA_IN_CODE(cmd, entries)

        case .dylibCodeSignDRS(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_DYLIB_CODE_SIGN_DRS(cmd, try LinkEditRaw(parsing: &span, endianness: endianness))

        case .linkerOptimizationHint(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_LINKER_OPTIMIZATION_HINT(cmd, try LinkEditRaw(parsing: &span, endianness: endianness))

        case .dyldExportsTrie(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_DYLD_EXPORTS_TRIE(cmd, try LinkEditRaw(parsing: &span, endianness: endianness))

        case .atomInfo(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_ATOM_INFO(cmd, try LinkEditRaw(parsing: &span, endianness: endianness))

        case .functionVariantFixups(let cmd):
            try input.seek(toRange: machORange)
            try input.seek(toRelativeOffset: cmd.offset)
            var span = try input.sliceSpan(byteCount: Int(cmd.size))
            return .LC_FUNCTION_VARIANT_FIXUPS(cmd, try LinkEditRaw(parsing: &span, endianness: endianness))
        }
    }
}

// Outcome of the first pass for a single load command. Commands whose data lives
// outside the load command region (LinkEdit commands) are stored as .deferred and
// resolved in a second pass after all headers have been read.
private enum ParseResult {
    case immediate(LoadCommandValue)
    case deferred(DeferredCommand)

    var commandID: LoadCommandHeader.ID {
        switch self {
        case .immediate(let v): v.command.header.id
        case .deferred(let d): d.commandID
        }
    }

    var commandOffset: Int {
        switch self {
        case .immediate(let v): v.command.range.lowerBound
        case .deferred(let d): d.commandOffset
        }
    }
}

extension MachO: ExpressibleByParsing {

    public init(parsing input: inout ParserSpan) throws {

        // The passed in input should already be set to the given macho range
        let machORange = input.parserRange
        self.range = input.parserRange.range

        guard
            let magic = try? BinaryMagic(parsing: &input, endianness: .big),
            !magic.isFat
        else { throw MachOError.unsupportedMachO("MachO") }
        self.magic = magic
        var span = try input.sliceSpan(byteCount: self.magic.headerSize)
        self.header = try MachOHeader(parsing: &span, magic: self.magic)

        let endianness = self.magic.endian
        let is64Bit = self.magic.is64Bit

        // First pass: parse all load command headers and bodies. Commands that only need
        // data from within their own command bytes are resolved to LoadCommandValue
        // immediately (.immediate). Commands whose data lives in the LinkEdit region
        // (a separate area of the file pointed to by offset/size fields) are stored as
        // .deferred for resolution in the second pass below.
        var parseResults: [ParseResult] = []
        parseResults.reserveCapacity(Int(self.header.ncmds))

        for i in 0..<Int(self.header.ncmds) {
            let cmdOffset = input.parserRange.lowerBound
            var cmdHeader: LoadCommandHeader? = nil
            do {
                let hdr = try LoadCommandHeader(parsing: &input, endianness: endianness)
                cmdHeader = hdr

                // Roll back to the start of this command and slice the full command span.
                try input.seek(toAbsoluteOffset: input.startPosition - 8)
                var span = try input.sliceSpan(byteCount: hdr.cmdSize)

                let result: ParseResult = switch hdr.id {
                // --- Deferred: data lives outside the load command in the LinkEdit region ---
                case .LC_CODE_SIGNATURE:
                    .deferred(.codeSignature(try LC_CODE_SIGNATURE(parsing: &span, endianness: endianness)))
                case .LC_FUNCTION_STARTS:
                    .deferred(.functionStarts(try LC_FUNCTION_STARTS(parsing: &span, endianness: endianness)))
                case .LC_ENCRYPTION_INFO:
                    .deferred(.encryptionInfo(try LC_ENCRYPTION_INFO(parsing: &span, endianness: endianness)))
                case .LC_ENCRYPTION_INFO_64:
                    .deferred(.encryptionInfo64(try LC_ENCRYPTION_INFO_64(parsing: &span, endianness: endianness)))
                case .LC_SYMTAB:
                    .deferred(.symtab(try LC_SYMTAB(parsing: &span, endianness: endianness)))
                case .LC_DYSYMTAB:
                    .deferred(.dysymtab(try LC_DYSYMTAB(parsing: &span, endianness: endianness)))
                case .LC_SEGMENT_SPLIT_INFO:
                    .deferred(.segmentSplitInfo(try LC_SEGMENT_SPLIT_INFO(parsing: &span, endianness: endianness)))
                case .LC_DYLD_CHAINED_FIXUPS:
                    .deferred(.dyldChainedFixups(try LC_DYLD_CHAINED_FIXUPS(parsing: &span, endianness: endianness)))
                case .LC_DATA_IN_CODE:
                    .deferred(.dataInCode(try LC_DATA_IN_CODE(parsing: &span, endianness: endianness)))
                case .LC_DYLIB_CODE_SIGN_DRS:
                    .deferred(.dylibCodeSignDRS(try LC_DYLIB_CODE_SIGN_DRS(parsing: &span, endianness: endianness)))
                case .LC_LINKER_OPTIMIZATION_HINT:
                    .deferred(.linkerOptimizationHint(try LC_LINKER_OPTIMIZATION_HINT(parsing: &span, endianness: endianness)))
                case .LC_DYLD_EXPORTS_TRIE:
                    .deferred(.dyldExportsTrie(try LC_DYLD_EXPORTS_TRIE(parsing: &span, endianness: endianness)))
                case .LC_ATOM_INFO:
                    .deferred(.atomInfo(try LC_ATOM_INFO(parsing: &span, endianness: endianness)))
                case .LC_FUNCTION_VARIANT_FIXUPS:
                    .deferred(.functionVariantFixups(try LC_FUNCTION_VARIANT_FIXUPS(parsing: &span, endianness: endianness)))

                // --- Immediate: all data is within the load command bytes ---
                case .LC_SEGMENT:
                    .immediate(.LC_SEGMENT(try LC_SEGMENT(parsing: &span, endianness: endianness)))
                case .LC_SYMSEG:
                    .immediate(.LC_SYMSEG(try LC_SYMSEG(parsing: &span, endianness: endianness)))
                case .LC_THREAD:
                    .immediate(.LC_THREAD(try LC_THREAD(parsing: &span, endianness: endianness)))
                case .LC_UNIXTHREAD:
                    .immediate(.LC_UNIXTHREAD(try LC_UNIXTHREAD(parsing: &span, endianness: endianness)))
                case .LC_LOADFVMLIB:
                    .immediate(.LC_LOADFVMLIB(try LC_LOADFVMLIB(parsing: &span, endianness: endianness)))
                case .LC_IDFVMLIB:
                    .immediate(.LC_IDFVMLIB(try LC_IDFVMLIB(parsing: &span, endianness: endianness)))
                case .LC_IDENT:
                    .immediate(.LC_IDENT(try LC_IDENT(parsing: &span, endianness: endianness)))
                case .LC_FVMFILE:
                    .immediate(.LC_FVMFILE(try LC_FVMFILE(parsing: &span, endianness: endianness)))
                case .LC_PREPAGE:
                    .immediate(.LC_PREPAGE(try LC_PREPAGE(parsing: &span, endianness: endianness)))
                case .LC_LOAD_DYLIB:
                    .immediate(.LC_LOAD_DYLIB(try LC_LOAD_DYLIB(parsing: &span, endianness: endianness)))
                case .LC_LOAD_DYLINKER:
                    .immediate(.LC_LOAD_DYLINKER(try LC_LOAD_DYLINKER(parsing: &span, endianness: endianness)))
                case .LC_ID_DYLINKER:
                    .immediate(.LC_ID_DYLINKER(try LC_ID_DYLINKER(parsing: &span, endianness: endianness)))
                case .LC_PREBOUND_DYLIB:
                    .immediate(.LC_PREBOUND_DYLIB(try LC_PREBOUND_DYLIB(parsing: &span, endianness: endianness)))
                case .LC_ROUTINES:
                    .immediate(.LC_ROUTINES(try LC_ROUTINES(parsing: &span, endianness: endianness)))
                case .LC_SUB_FRAMEWORK:
                    .immediate(.LC_SUB_FRAMEWORK(try LC_SUB_FRAMEWORK(parsing: &span, endianness: endianness)))
                case .LC_SUB_UMBRELLA:
                    .immediate(.LC_SUB_UMBRELLA(try LC_SUB_UMBRELLA(parsing: &span, endianness: endianness)))
                case .LC_SUB_CLIENT:
                    .immediate(.LC_SUB_CLIENT(try LC_SUB_CLIENT(parsing: &span, endianness: endianness)))
                case .LC_SUB_LIBRARY:
                    .immediate(.LC_SUB_LIBRARY(try LC_SUB_LIBRARY(parsing: &span, endianness: endianness)))
                case .LC_TWOLEVEL_HINTS:
                    .immediate(.LC_TWOLEVEL_HINTS(try LC_TWOLEVEL_HINTS(parsing: &span, endianness: endianness)))
                case .LC_PREBIND_CKSUM:
                    .immediate(.LC_PREBIND_CKSUM(try LC_PREBIND_CKSUM(parsing: &span, endianness: endianness)))
                case .LC_LOAD_WEAK_DYLIB:
                    .immediate(.LC_LOAD_WEAK_DYLIB(try LC_LOAD_WEAK_DYLIB(parsing: &span, endianness: endianness)))
                case .LC_SEGMENT_64:
                    .immediate(.LC_SEGMENT_64(try LC_SEGMENT_64(parsing: &span, endianness: endianness)))
                case .LC_ROUTINES_64:
                    .immediate(.LC_ROUTINES_64(try LC_ROUTINES_64(parsing: &span, endianness: endianness)))
                case .LC_UUID:
                    .immediate(.LC_UUID(try LC_UUID(parsing: &span, endianness: endianness)))
                case .LC_RPATH:
                    .immediate(.LC_RPATH(try LC_RPATH(parsing: &span, endianness: endianness)))
                case .LC_REEXPORT_DYLIB:
                    .immediate(.LC_REEXPORT_DYLIB(try LC_REEXPORT_DYLIB(parsing: &span, endianness: endianness)))
                case .LC_LAZY_LOAD_DYLIB:
                    .immediate(.LC_LAZY_LOAD_DYLIB(try LC_LAZY_LOAD_DYLIB(parsing: &span, endianness: endianness)))
                case .LC_DYLD_INFO:
                    .immediate(.LC_DYLD_INFO(try LC_DYLD_INFO(parsing: &span, endianness: endianness)))
                case .LC_DYLD_INFO_ONLY:
                    .immediate(.LC_DYLD_INFO_ONLY(try LC_DYLD_INFO_ONLY(parsing: &span, endianness: endianness)))
                case .LC_LOAD_UPWARD_DYLIB:
                    .immediate(.LC_LOAD_UPWARD_DYLIB(try LC_LOAD_UPWARD_DYLIB(parsing: &span, endianness: endianness)))
                case .LC_VERSION_MIN_MACOSX:
                    .immediate(.LC_VERSION_MIN_MACOSX(try LC_VERSION_MIN_MACOSX(parsing: &span, endianness: endianness)))
                case .LC_VERSION_MIN_IPHONEOS:
                    .immediate(.LC_VERSION_MIN_IPHONEOS(try LC_VERSION_MIN_IPHONEOS(parsing: &span, endianness: endianness)))
                case .LC_DYLD_ENVIRONMENT:
                    .immediate(.LC_DYLD_ENVIRONMENT(try LC_DYLD_ENVIRONMENT(parsing: &span, endianness: endianness)))
                case .LC_MAIN:
                    .immediate(.LC_MAIN(try LC_MAIN(parsing: &span, endianness: endianness)))
                case .LC_SOURCE_VERSION:
                    .immediate(.LC_SOURCE_VERSION(try LC_SOURCE_VERSION(parsing: &span, endianness: endianness)))
                case .LC_LINKER_OPTION:
                    .immediate(.LC_LINKER_OPTION(try LC_LINKER_OPTION(parsing: &span, endianness: endianness)))
                case .LC_VERSION_MIN_TVOS:
                    .immediate(.LC_VERSION_MIN_TVOS(try LC_VERSION_MIN_TVOS(parsing: &span, endianness: endianness)))
                case .LC_VERSION_MIN_WATCHOS:
                    .immediate(.LC_VERSION_MIN_WATCHOS(try LC_VERSION_MIN_WATCHOS(parsing: &span, endianness: endianness)))
                case .LC_NOTE:
                    .immediate(.LC_NOTE(try LC_NOTE(parsing: &span, endianness: endianness)))
                case .LC_BUILD_VERSION:
                    .immediate(.LC_BUILD_VERSION(try LC_BUILD_VERSION(parsing: &span, endianness: endianness)))
                case .LC_FILESET_ENTRY:
                    .immediate(.LC_FILESET_ENTRY(try LC_FILESET_ENTRY(parsing: &span, endianness: endianness)))
                case .LC_FUNCTION_VARIANTS:
                    .immediate(.LC_FUNCTION_VARIANTS(try LC_FUNCTION_VARIANTS(parsing: &span, endianness: endianness)))
                case .LC_TARGET_TRIPLE:
                    .immediate(.LC_TARGET_TRIPLE(try LC_TARGET_TRIPLE(parsing: &span, endianness: endianness)))
                }

                parseResults.append(result)
            } catch let e as LoadCommandParsingError {
                throw e
            } catch {
                throw LoadCommandParsingError(
                    commandIndex: i,
                    commandID: cmdHeader?.id,
                    commandOffset: cmdOffset,
                    underlyingError: error
                )
            }
        }

        // Second pass: resolve deferred commands by seeking into the LinkEdit region.
        // Immediate commands are passed through unchanged, preserving original order.
        var loadCommands: [LoadCommandValue] = []
        loadCommands.reserveCapacity(parseResults.count)

        for (i, result) in parseResults.enumerated() {
            do {
                switch result {
                case .immediate(let value):
                    loadCommands.append(value)
                case .deferred(let cmd):
                    loadCommands.append(
                        try cmd.resolve(
                            input: &input,
                            machORange: machORange,
                            endianness: endianness,
                            is64Bit: is64Bit))
                }
            } catch let e as LoadCommandParsingError {
                throw e
            } catch {
                throw LoadCommandParsingError(
                    commandIndex: i,
                    commandID: result.commandID,
                    commandOffset: result.commandOffset,
                    underlyingError: error
                )
            }
        }

        self.loadCommands = loadCommands
    }
}

extension MachO {
    public func getMachoOffset(_ range: Range<Int>) -> Range<Int> {
        range.lowerBound - self.range.lowerBound..<range.upperBound - self.range.lowerBound
    }

    public static func isMachO(data: Data) -> Bool {
        let magic = data.withParserSpan { input in
            return try? BinaryMagic(parsing: &input, endianness: .little)
        }
        return magic?.isFat == false
    }

    public func getLoadCommandByType(_ type: LoadCommandHeader.ID) -> LoadCommand? {
        return self.rawCommands.first(where: { $0.header.id == type })
    }

    public func getLoadCommandsByType(_ type: LoadCommandHeader.ID) -> [LoadCommand] {
        return self.rawCommands.filter { $0.header.id == type }
    }

    public func getSignature() -> (LC_CODE_SIGNATURE, CodeSignatureSuperBlob)? {
        guard
            let lc = loadCommands.first(where: {
                switch $0 {
                case .LC_CODE_SIGNATURE(_, _): true
                default: false
                }
            }),
            case .LC_CODE_SIGNATURE(let cmd, let signature) = lc
        else { return nil }

        return (cmd, signature)
    }

    public func getCodeDirectory() -> CodeSignatureCodeDirectory? {
        guard
            let (_, signature) = getSignature(),
            let cd = signature.blobs.first(where: {
                switch $0 {
                case .CodeDirectory(_, _): true
                default: false
                }
            }),
            case .CodeDirectory(_, let _cd) = cd
        else { return nil }

        return _cd
    }

    public func getRequirements() -> CodeSignatureCodeRequirements? {
        guard
            let (_, signature) = getSignature(),
            let cr = signature.blobs.first(where: {
                switch $0 {
                case .CodeRequirements(_, _): true
                default: false
                }
            }),
            case .CodeRequirements(_, let _cr) = cr
        else { return nil }

        return _cr
    }

    public func getEntitlementsDER() -> CodeSignatureCodeEntitlementsDER? {
        guard
            let (_, signature) = getSignature(),
            let ce = signature.blobs.first(where: {
                switch $0 {
                case .CodeEntitlementsDER(_, _): true
                default: false
                }
            }),
            case .CodeEntitlementsDER(_, let _ce) = ce
        else { return nil }

        return _ce
    }

    public func getEntitlements() -> CodeSignatureCodeEntitlements? {
        guard
            let (_, signature) = getSignature(),
            let ce = signature.blobs.first(where: {
                switch $0 {
                case .CodeEntitlements(_, _): true
                default: false
                }
            }),
            case .CodeEntitlements(_, let _ce) = ce
        else { return nil }

        return _ce
    }

    public func getRawSignature() -> CodeSignatureBlobWrapper? {
        guard
            let (_, signature) = getSignature(),
            let bw = signature.blobs.first(where: {
                switch $0 {
                case .BlobWrapper(_, _): true
                default: false
                }
            }),
            case .BlobWrapper(_, let _bw) = bw
        else { return nil }

        return _bw
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
            case .LC_SEGMENT_64(let cmd) = lc
        else { return nil }

        return cmd
    }
}

extension MachO: Displayable {
    public var title: String { "MachO \(header.cpu.type.description)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Magic", stringValue: magic.description, offset: 0, size: 4, children: nil,
                obj: self)
        ]
    }
    public var children: [Displayable]? {
        [header] + loadCommands
    }
}
