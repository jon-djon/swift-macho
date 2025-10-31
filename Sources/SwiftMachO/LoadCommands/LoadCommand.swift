//
//  Untitled.swift
//  swift-macho
//
//  Created by jon on 9/29/25.
//
import Foundation
import BinaryParsing

public protocol LoadCommand: CustomStringConvertible, Displayable, Parseable {
    var header: LoadCommandHeader { get }
}

public protocol LoadCommandLinkEdit {
    var offset: UInt32 { get }
    var size: UInt32 { get }
}

public struct LinkEditRaw: Parseable {
    public let range: Range<Int>
}


extension LinkEditRaw {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
    }
}

extension LinkEditRaw: Displayable {
    public var title: String { "LinkEditRaw" }
    public var description: String { "LinkEditRaw" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Range", stringValue: range.description, offset: 0, size: 0, children: nil, obj: self)
        ]
    }
    public var children: [Displayable]? { nil }
}

public enum LoadCommandValue {
    case LC_SEGMENT(LC_SEGMENT)
    case LC_SYMTAB(LC_SYMTAB, [Symbol], [String])
    case LC_SYMSEG(LC_SYMSEG)
    case LC_THREAD(LC_THREAD)
    case LC_UNIXTHREAD(LC_UNIXTHREAD)
    case LC_LOADFVMLIB(LC_LOADFVMLIB)
    case LC_IDFVMLIB(LC_IDFVMLIB)
    case LC_IDENT(LC_IDENT)
    case LC_FVMFILE(LC_FVMFILE)
    case LC_PREPAGE(LC_PREPAGE)
    case LC_DYSYMTAB(LC_DYSYMTAB)
    case LC_LOAD_DYLIB(LC_LOAD_DYLIB)
    case LC_LOAD_DYLINKER(LC_LOAD_DYLINKER)
    case LC_ID_DYLINKER(LC_ID_DYLINKER)
    case LC_PREBOUND_DYLIB(LC_PREBOUND_DYLIB)
    case LC_ROUTINES(LC_ROUTINES)
    case LC_SUB_FRAMEWORK(LC_SUB_FRAMEWORK)
    case LC_SUB_UMBRELLA(LC_SUB_UMBRELLA)
    case LC_SUB_CLIENT(LC_SUB_CLIENT)
    case LC_SUB_LIBRARY(LC_SUB_LIBRARY)
    case LC_TWOLEVEL_HINTS(LC_TWOLEVEL_HINTS)
    case LC_PREBIND_CKSUM(LC_PREBIND_CKSUM)
    case LC_LOAD_WEAK_DYLIB(LC_LOAD_WEAK_DYLIB)
    case LC_SEGMENT_64(LC_SEGMENT_64)
    case LC_ROUTINES_64(LC_ROUTINES_64)
    case LC_UUID(LC_UUID)
    case LC_RPATH(LC_RPATH)
    case LC_CODE_SIGNATURE(LC_CODE_SIGNATURE, CodeSignatureSuperBlob)
    case LC_SEGMENT_SPLIT_INFO(LC_SEGMENT_SPLIT_INFO)
    case LC_REEXPORT_DYLIB(LC_REEXPORT_DYLIB)
    case LC_LAZY_LOAD_DYLIB(LC_LAZY_LOAD_DYLIB)
    case LC_ENCRYPTION_INFO(LC_ENCRYPTION_INFO)
    case LC_DYLD_INFO(LC_DYLD_INFO)
    case LC_DYLD_INFO_ONLY(LC_DYLD_INFO_ONLY)
    case LC_LOAD_UPWARD_DYLIB(LC_LOAD_UPWARD_DYLIB)
    case LC_VERSION_MIN_MACOSX(LC_VERSION_MIN_MACOSX)
    case LC_VERSION_MIN_IPHONEOS(LC_VERSION_MIN_IPHONEOS)
    case LC_FUNCTION_STARTS(LC_FUNCTION_STARTS, FunctionStarts)
    case LC_DYLD_ENVIRONMENT(LC_DYLD_ENVIRONMENT)
    case LC_MAIN(LC_MAIN)
    case LC_DATA_IN_CODE(LC_DATA_IN_CODE, [DataInCode])
    case LC_SOURCE_VERSION(LC_SOURCE_VERSION)
    case LC_DYLIB_CODE_SIGN_DRS(LC_DYLIB_CODE_SIGN_DRS)
    case LC_ENCRYPTION_INFO_64(LC_ENCRYPTION_INFO_64)
    case LC_LINKER_OPTION(LC_LINKER_OPTION)
    case LC_LINKER_OPTIMIZATION_HINT(LC_LINKER_OPTIMIZATION_HINT, LinkEditRaw)
    case LC_VERSION_MIN_TVOS(LC_VERSION_MIN_TVOS)
    case LC_VERSION_MIN_WATCHOS(LC_VERSION_MIN_WATCHOS)
    case LC_NOTE(LC_NOTE)
    case LC_BUILD_VERSION(LC_BUILD_VERSION)
    case LC_DYLD_EXPORTS_TRIE(LC_DYLD_EXPORTS_TRIE)
    case LC_DYLD_CHAINED_FIXUPS(LC_DYLD_CHAINED_FIXUPS)
    case LC_FILESET_ENTRY(LC_FILESET_ENTRY)
    case LC_ATOM_INFO(LC_ATOM_INFO)
    case LC_FUNCTION_VARIANTS(LC_FUNCTION_VARIANTS)
    case LC_FUNCTION_VARIANT_FIXUPS(LC_FUNCTION_VARIANT_FIXUPS)
    case LC_TARGET_TRIPLE(LC_TARGET_TRIPLE)
}

extension LoadCommandValue {
    public var command: LoadCommand {
        switch self {
        case .LC_CODE_SIGNATURE(let cmd, let signature): cmd
        case .LC_UUID(let cmd): cmd
        case .LC_FUNCTION_STARTS(let cmd, _): cmd
        case .LC_LOAD_DYLIB(let cmd): cmd
        case .LC_LOAD_WEAK_DYLIB(let cmd): cmd
        case .LC_DYLD_ENVIRONMENT(let cmd): cmd
        case .LC_DYLD_INFO_ONLY(let cmd): cmd
        case .LC_ENCRYPTION_INFO(let cmd): cmd
        case .LC_ENCRYPTION_INFO_64(let cmd): cmd
        case .LC_SEGMENT(let cmd): cmd
        case .LC_SYMTAB(let cmd, _, _): cmd
        case .LC_SYMSEG(let cmd): cmd
        case .LC_THREAD(let cmd): cmd
        case .LC_UNIXTHREAD(let cmd): cmd
        case .LC_LOADFVMLIB(let cmd): cmd
        case .LC_IDFVMLIB(let cmd): cmd
        case .LC_IDENT(let cmd): cmd
        case .LC_FVMFILE(let cmd): cmd
        case .LC_PREPAGE(let cmd): cmd
        case .LC_DYSYMTAB(let cmd): cmd
        case .LC_LOAD_DYLINKER(let cmd): cmd
        case .LC_ID_DYLINKER(let cmd): cmd
        case .LC_PREBOUND_DYLIB(let cmd): cmd
        case .LC_ROUTINES(let cmd): cmd
        case .LC_SUB_FRAMEWORK(let cmd): cmd
        case .LC_SUB_UMBRELLA(let cmd): cmd
        case .LC_SUB_CLIENT(let cmd): cmd
        case .LC_SUB_LIBRARY(let cmd): cmd
        case .LC_TWOLEVEL_HINTS(let cmd): cmd
        case .LC_PREBIND_CKSUM(let cmd): cmd
        case .LC_SEGMENT_64(let cmd): cmd
        case .LC_ROUTINES_64(let cmd): cmd
        case .LC_RPATH(let cmd): cmd
        case .LC_SEGMENT_SPLIT_INFO(let cmd): cmd
        case .LC_REEXPORT_DYLIB(let cmd): cmd
        case .LC_LAZY_LOAD_DYLIB(let cmd): cmd
        case .LC_DYLD_INFO(let cmd): cmd
        case .LC_LOAD_UPWARD_DYLIB(let cmd): cmd
        case .LC_VERSION_MIN_MACOSX(let cmd): cmd
        case .LC_DYLD_CHAINED_FIXUPS(let cmd): cmd
        case .LC_VERSION_MIN_IPHONEOS(let cmd): cmd
        case .LC_MAIN(let cmd): cmd
        case .LC_DATA_IN_CODE(let cmd, _): cmd
        case .LC_SOURCE_VERSION(let cmd): cmd
        case .LC_DYLIB_CODE_SIGN_DRS(let cmd): cmd
        case .LC_LINKER_OPTION(let cmd): cmd
        case .LC_LINKER_OPTIMIZATION_HINT(let cmd, _): cmd
        case .LC_VERSION_MIN_TVOS(let cmd): cmd
        case .LC_VERSION_MIN_WATCHOS(let cmd): cmd
        case .LC_NOTE(let cmd): cmd
        case .LC_BUILD_VERSION(let cmd): cmd
        case .LC_DYLD_EXPORTS_TRIE(let cmd): cmd
        case .LC_FILESET_ENTRY(let cmd): cmd
        case .LC_ATOM_INFO(let cmd): cmd
        case .LC_FUNCTION_VARIANTS(let cmd): cmd
        case .LC_FUNCTION_VARIANT_FIXUPS(let cmd): cmd
        case .LC_TARGET_TRIPLE(let cmd): cmd
        }
    }
}


extension LoadCommandValue: Displayable {
    public var range: Range<Int> { command.range }
    public var title: String { command.title }
    public var description: String { command.description }
    public var fields: [DisplayableField] {
        switch self {
        case .LC_SYMTAB(let cmd, let symbols, let strings):
            cmd.fields + [
                .init(label: "Symbols", stringValue: "\(symbols.count) Symbols", offset: 0, size: 0, children: symbols.enumerated().map { index, symbol in
                    .init(label: "Symbol", stringValue: strings[index], offset: 0, size: 0, children: symbol.fields, obj: symbol)
                }, obj: self)
            ]
        case .LC_FUNCTION_STARTS(let cmd, let starts):
            cmd.fields + starts.fields
        case .LC_DATA_IN_CODE(let cmd, let codes):
            cmd.fields + [
                .init(label: "Codes", stringValue: "\(codes.count) Codes", offset: 0, size: 0, children: codes.enumerated().map { index, code in
                        .init(label: "Code \(index)", stringValue: code.kind.description, offset: 0, size: 0, children: code.fields, obj: code)
                }, obj: self)
            ]
        
        default: command.fields
        }
    }
    // LC_SEGMENT_SPLIT_INFO, LC_FUNCTION_STARTS, LC_DATA_IN_CODE, LC_DYLIB_CODE_SIGN_DRS, LC_LINKER_OPTIMIZATION_HINT, LC_DYLD_EXPORTS_TRIE, or LC_DYLD_CHAINED_FIXUPS
    public var children: [Displayable]? {
        switch self {
        case .LC_CODE_SIGNATURE(_, let signature): [signature]
        case .LC_FUNCTION_STARTS(_, let starts): []
        case .LC_LINKER_OPTIMIZATION_HINT(_, let le): [le]
        // case .LC_SEGMENT_SPLIT_INFO(_, let le): [le]
        // case .LC_DATA_IN_CODE(_, let codes): []
//        case .LC_DYLIB_CODE_SIGN_DRS(_, let le): [le]
//        case .LC_DYLD_EXPORTS_TRIE(_, let le): [le]
//        case .LC_DYLD_CHAINED_FIXUPS(_, let le): [le]
        default: command.children
        }
    }
}


