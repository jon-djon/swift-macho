//
//  Untitled.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

// https://alexdremov.me/mystery-of-mach-o-object-file-builders/
// https://www.newosxbook.com/src.php?tree=xnu&file=/EXTERNAL_HEADERS/mach-o/nlist.h
// https://github.com/kudinovdenis/binary-loader/blob/c6bf87691b0ec4c7e46dfb54d002ba8bb1b7ec88/BinaryAnalyzer/MachO/Commands/LC_SYMTAB/SymTabEntry.swift#L48
public struct Symbol: Parseable {
    public let n_strx: UInt32  // index into the string table
    public let n_type: UInt8
    public let n_sect: UInt8  // If type does not have N_SECT, then this defines the section number
    public let n_desc: UInt16
    public let n_val: NVAL  // This is UInt32 for 32 bit binaries

    public let range: Range<Int>

    public enum NVAL: CustomStringConvertible {
        case bit32(UInt32)
        case bit64(UInt64)

        public var description: String {
            switch self {
            case .bit32(let value): value.description
            case .bit64(let value): value.description
            }
        }

        public var size: Int {
            switch self {
            case .bit32: 4
            case .bit64: 8
            }
        }
    }

    public static let N_STAB: UInt8 =
        0xe0 /* if any of these bits set, a symbolic debugging entry */
    public static let N_PEXT: UInt8 = 0x10 /* private external symbol bit */
    public static let N_TYPE: UInt8 = 0x0e /* mask for the type bits */
    public static let N_EXT: UInt8 = 0x01 /* external symbol bit, set for external symbols */

    public static let N_UNDF: UInt8 = 0x0 /* undefined */
    public static let N_ABS: UInt8 = 0x2 /* absolute */
    public static let N_SECT: UInt8 = 0xe /* defined in section */
    public static let N_PBUD: UInt8 = 0xc /* prebound undefined */
    public static let N_INDR: UInt8 = 0xa /* indirect */

    // TODO: Should this be an AutoOptionSet
    //
    @AutoOptionSet(.UInt16)
    public struct SymbolDescriptionFlags: OptionSet, Sendable {
        public static let REFERENCED_DYNAMICALLY: SymbolDescriptionFlags = SymbolDescriptionFlags(
            rawValue: 0x0010)
        public static let N_NO_DEAD_STRIP: SymbolDescriptionFlags = SymbolDescriptionFlags(
            rawValue: 0x0020)
        public static let N_DESC_DISCARDED: SymbolDescriptionFlags = SymbolDescriptionFlags(
            rawValue: 0x0020)
        public static let N_WEAK_REF: SymbolDescriptionFlags = SymbolDescriptionFlags(
            rawValue: 0x0040)
        public static let REF_TO_WEAK: SymbolDescriptionFlags = SymbolDescriptionFlags(
            rawValue: 0x0080)
        public static let N_WEAK_DEF: SymbolDescriptionFlags = SymbolDescriptionFlags(
            rawValue: 0x0080)
        public static let N_ARM_THUMB_DEF: SymbolDescriptionFlags = SymbolDescriptionFlags(
            rawValue: 0x0008)
        public static let N_SYMBOL_RESOLVER: SymbolDescriptionFlags = SymbolDescriptionFlags(
            rawValue: 0x0100)
        public static let N_ALT_ENTRY: SymbolDescriptionFlags = SymbolDescriptionFlags(
            rawValue: 0x0200)
        public static let N_COLD_FUNC: SymbolDescriptionFlags = SymbolDescriptionFlags(
            rawValue: 0x0400)
    }

    public static let REFERENCE_TYPE_MASK: UInt16 = 0x7

    @AutoOptionSet(.UInt8)
    public struct SymbolReferenceFlags: OptionSet, Sendable {
        public static let REFERENCE_FLAG_UNDEFINED_NON_LAZY: SymbolReferenceFlags =
            SymbolReferenceFlags(rawValue: 0)
        public static let REFERENCE_FLAG_UNDEFINED_LAZY: SymbolReferenceFlags =
            SymbolReferenceFlags(rawValue: 1)
        public static let REFERENCE_FLAG_DEFINED: SymbolReferenceFlags = SymbolReferenceFlags(
            rawValue: 2)
        public static let REFERENCE_FLAG_PRIVATE_DEFINED: SymbolReferenceFlags =
            SymbolReferenceFlags(rawValue: 3)
        public static let REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY: SymbolReferenceFlags =
            SymbolReferenceFlags(rawValue: 4)
        public static let REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY: SymbolReferenceFlags =
            SymbolReferenceFlags(rawValue: 5)
    }
    // (n_desc & Symbol.REFERENCE_TYPE_MASK) == Symbol.REFERENCE_FLAG_UNDEFINED_NON_LAZY
    //
    var symbolReferenceFlags: SymbolReferenceFlags {
        return SymbolReferenceFlags(rawValue: UInt8(n_desc & Symbol.REFERENCE_TYPE_MASK))
    }

    var isDebugSymbol: Bool {
        return (n_type & Symbol.N_STAB) != 0  // N_EXT bit
    }

    var isExternal: Bool {
        return (n_type & Symbol.N_EXT) != 0  // N_EXT bit
    }

    var isPrivateExternal: Bool {
        return (n_type & Symbol.N_PEXT) != 0  // N_EXT bit
    }

    var isUndefinedSymbol: Bool {
        return (n_type & Symbol.N_TYPE) != Symbol.N_UNDF
    }

    var isAbsoluteSymbol: Bool {
        return (n_type & Symbol.N_TYPE) != Symbol.N_ABS
    }

    var isDefinedInSection: Bool {
        return (n_type & Symbol.N_TYPE) != Symbol.N_SECT
    }

    var isPreboundUndefinedSymbol: Bool {
        return (n_type & Symbol.N_TYPE) != Symbol.N_PBUD
    }

    var isIndirectSymbol: Bool {
        return (n_type & Symbol.N_TYPE) != Symbol.N_INDR
    }

    var debugSymbolDescription: DEBUGGER_SYMBOL? {
        if isDebugSymbol {
            return DEBUGGER_SYMBOL(rawValue: n_type)
        }
        return nil
    }

    public enum DEBUGGER_SYMBOL: UInt8, CustomStringConvertible {
        case N_NONE = 0x00
        case N_GSYM = 0x20
        case N_FNAME = 0x22
        case N_FUN = 0x24
        case N_STSYM = 0x26
        case N_LCSYM = 0x28
        case N_BNSYM = 0x2e
        case N_AST = 0x32
        case N_OPT = 0x3c
        case N_RSYM = 0x40
        case N_SLINE = 0x44
        case N_ENSYM = 0x4e
        case N_SSYM = 0x60
        case N_SO = 0x64
        case N_OSO = 0x66
        case N_LSYM = 0x80
        case N_BINCL = 0x82
        case N_SOL = 0x84
        case N_PARAMS = 0x86
        case N_VERSION = 0x88
        case N_OLEVEL = 0x8A
        case N_PSYM = 0xa0
        case N_EINCL = 0xa2
        case N_ENTRY = 0xa4
        case N_LBRAC = 0xc0
        case N_EXCL = 0xc2
        case N_RBRAC = 0xe0
        case N_BCOMM = 0xe2
        case N_ECOMM = 0xe4
        case N_ECOML = 0xe8
        case N_LENG = 0xfe
        case N_PC = 0x30

        public var description: String {
            switch self {
            case .N_NONE: return "None"
            case .N_GSYM: return "Global Symbol"
            case .N_FNAME: return "Procedure Name (F77 Kludge)"
            case .N_FUN: return "Procedure / Function"
            case .N_STSYM: return "Static Symbol"
            case .N_LCSYM: return "Local Common (.lcomm) Symbol"
            case .N_BNSYM: return "Beginning of Section Symbol"
            case .N_AST: return "AST File Path"
            case .N_OPT: return "Compiler Optimization / GCC2 Symbol"
            case .N_RSYM: return "Register Symbol"
            case .N_SLINE: return "Source Line Number"
            case .N_ENSYM: return "End of Section Symbol"
            case .N_SSYM: return "Structure Element"
            case .N_SO: return "Main Source File Name"
            case .N_OSO: return "Object File Name"
            case .N_LSYM: return "Local Symbol"
            case .N_BINCL: return "Header File Include (Begin)"
            case .N_SOL: return "Included Source File Name"
            case .N_PARAMS: return "Compiler Parameters"
            case .N_VERSION: return "Compiler Version"
            case .N_OLEVEL: return "Compiler Optimization Level"
            case .N_PSYM: return "Parameter Symbol"
            case .N_EINCL: return "Header File Include (End)"
            case .N_ENTRY: return "Alternate Entry Point"
            case .N_LBRAC: return "Lexical Block (Left Bracket)"
            case .N_EXCL: return "Deleted Include File"
            case .N_RBRAC: return "Lexical Block (Right Bracket)"
            case .N_BCOMM: return "Common Block (Begin)"
            case .N_ECOMM: return "Common Block (End)"
            case .N_ECOML: return "Common Block (End, Local Name)"
            case .N_LENG: return "Entry Length Information"
            case .N_PC: return "Global Pascal Symbol"
            }
        }
    }

    /// Extracts the library ordinal (bits 0-7)
    var libraryOrdinal: Int {
        return Int((n_desc >> 8) & 0xFF)
    }

    var symbolDescriptionFlags: SymbolDescriptionFlags {
        return SymbolDescriptionFlags(rawValue: n_desc)
    }

    public var size: Int {
        switch n_val {
        case .bit32: Symbol.size32
        case .bit64: Symbol.size64
        }
    }

    public static let size64: Int = 16
    public static let size32: Int = 12
}

extension Symbol {
    public init(parsing input: inout ParserSpan, endianness: Endianness, is64it: Bool = false)
        throws
    {
        self.range = input.parserRange.range

        self.n_strx = try UInt32(parsing: &input, endianness: endianness)
        self.n_type = try UInt8(parsing: &input)
        self.n_sect = try UInt8(parsing: &input)

        self.n_desc = try UInt16(parsing: &input, endianness: endianness)

        if is64it {
            self.n_val = NVAL.bit64(try UInt64(parsing: &input, endianness: endianness))
        } else {
            self.n_val = NVAL.bit32(try UInt32(parsing: &input, endianness: endianness))
        }
    }
}

extension Symbol: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "String Table Index", stringValue: n_strx.description, offset: 0, size: 4,
                children: nil, obj: self),
            .init(
                label: "n_type", stringValue: n_type.description, offset: 4, size: 1,
                children: [
                    DisplayableField(
                        label: "Debug Symbol",
                        stringValue: debugSymbolDescription?.description ?? "No",
                        offset: 4,
                        size: 1, children: nil, obj: self),
                    DisplayableField(
                        label: "External", stringValue: isExternal.description, offset: 4,
                        size: 1, children: nil, obj: self),
                    DisplayableField(
                        label: "Private External", stringValue: isPrivateExternal.description,
                        offset: 4,
                        size: 1, children: nil, obj: self),
                    DisplayableField(
                        label: "Undefined Symbol", stringValue: isUndefinedSymbol.description,
                        offset: 4,
                        size: 1, children: nil, obj: self),
                    DisplayableField(
                        label: "Absolute Symbol", stringValue: isAbsoluteSymbol.description,
                        offset: 4,
                        size: 1, children: nil, obj: self),
                    DisplayableField(
                        label: "Defined In Section", stringValue: isDefinedInSection.description,
                        offset: 4,
                        size: 1, children: nil, obj: self),
                    DisplayableField(
                        label: "Prebound Undefined Symbol",
                        stringValue: isPreboundUndefinedSymbol.description,
                        offset: 4,
                        size: 1, children: nil, obj: self),
                    DisplayableField(
                        label: "Indirect Symbol", stringValue: isIndirectSymbol.description,
                        offset: 4,
                        size: 1, children: nil, obj: self),
                ], obj: self),
            .init(
                label: "Section Number", stringValue: n_sect.description, offset: 5, size: 1,
                children: nil, obj: self),
            .init(
                label: "n_desc", stringValue: n_desc.description, offset: 6, size: 2,
                children: [
                    DisplayableField(
                        label: "Library Ordinal", stringValue: libraryOrdinal.description,
                        offset: 6,
                        size: 2, children: nil, obj: self),
                    DisplayableField(
                        label: "Symbol Description Flags",
                        stringValue: symbolDescriptionFlags.description,
                        offset: 6,
                        size: 2, children: nil, obj: self),
                    DisplayableField(
                        label: "Symbol Reference Flags",
                        stringValue: symbolReferenceFlags.description,
                        offset: 6,
                        size: 2, children: nil, obj: self),
                ],
                obj: self),
            .init(
                label: "n_val", stringValue: n_val.size.hexDescription, offset: 8, size: n_val.size,
                children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
