//
//  LoadCommand.swift
//  swift-macho
//
//  Created by jon on 9/29/25.
//
import Foundation
import BinaryParsing


public struct LoadCommandHeader {
    public let id: LoadCommandHeader.ID
    public let cmdSize: UInt32    

    @CaseName
    public enum ID: UInt32, CaseIterable {
        case LC_SEGMENT = 0x01
        case LC_SYMTAB
        case LC_SYMSEG
        case LC_THREAD
        case LC_UNIXTHREAD
        case LC_LOADFVMLIB
        case LC_IDFVMLIB
        case LC_IDENT
        case LC_FVMFILE
        case LC_PREPAGE
        case LC_DYSYMTAB
        case LC_LOAD_DYLIB
        case LC_LOAD_DYLINKER
        case LC_ID_DYLINKER
        case LC_PREBOUND_DYLIB
        case LC_ROUTINES
        case LC_SUB_FRAMEWORK
        case LC_SUB_UMBRELLA
        case LC_SUB_CLIENT
        case LC_SUB_LIBRARY
        case LC_TWOLEVEL_HINTS
        case LC_PREBIND_CKSUM
        case LC_LOAD_WEAK_DYLIB = 0x80000018 // (0x18 | LC_REQ_DYLD)
        case LC_SEGMENT_64 = 0x19
        case LC_ROUTINES_64
        case LC_UUID
        case LC_RPATH = 0x8000001C // (0x1c | LC_REQ_DYLD)
        case LC_CODE_SIGNATURE = 0x1d
        case LC_SEGMENT_SPLIT_INFO
        case LC_REEXPORT_DYLIB = 0x8000001F // (0x1f | LC_REQ_DYLD)
        case LC_LAZY_LOAD_DYLIB = 0x20
        case LC_ENCRYPTION_INFO
        case LC_DYLD_INFO
        case LC_DYLD_INFO_ONLY = 0x80000022 // (0x22 | LC_REQ_DYLD)
        case LC_LOAD_UPWARD_DYLIB = 0x80000023 // (0x23 | LC_REQ_DYLD)
        case LC_VERSION_MIN_MACOSX = 0x24
        case LC_VERSION_MIN_IPHONEOS
        case LC_FUNCTION_STARTS
        case LC_DYLD_ENVIRONMENT
        case LC_MAIN = 0x80000028 // (0x28 | LC_REQ_DYLD)
        case LC_DATA_IN_CODE = 0x29
        case LC_SOURCE_VERSION
        case LC_DYLIB_CODE_SIGN_DRS
        case LC_ENCRYPTION_INFO_64
        case LC_LINKER_OPTION
        case LC_LINKER_OPTIMIZATION_HINT
        case LC_VERSION_MIN_TVOS
        case LC_VERSION_MIN_WATCHOS
        case LC_NOTE
        case LC_BUILD_VERSION
        case LC_DYLD_EXPORTS_TRIE = 0x80000033 // (0x33 | LC_REQ_DYLD)
        case LC_DYLD_CHAINED_FIXUPS = 0x80000034 // (0x34 | LC_REQ_DYLD)
        case LC_FILESET_ENTRY = 0x80000035 // (0x35 | LC_REQ_DYLD)
        case LC_ATOM_INFO = 0x36
        case LC_FUNCTION_VARIANTS
        case LC_FUNCTION_VARIANT_FIXUPS
        case LC_TARGET_TRIPLE
    }
}

extension LoadCommandHeader {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.id = try LoadCommandHeader.ID(parsing: &input, endianness: endianness)
        self.cmdSize = try UInt32(parsing: &input, endianness: endianness)
    }
}
