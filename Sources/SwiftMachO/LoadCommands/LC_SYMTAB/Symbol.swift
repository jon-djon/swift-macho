//
//  Untitled.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

// https://alexdremov.me/mystery-of-mach-o-object-file-builders/
// https://www.newosxbook.com/src.php?tree=xnu&file=/EXTERNAL_HEADERS/mach-o/nlist.h
// https://github.com/kudinovdenis/binary-loader/blob/c6bf87691b0ec4c7e46dfb54d002ba8bb1b7ec88/BinaryAnalyzer/MachO/Commands/LC_SYMTAB/SymTabEntry.swift#L48
public struct Symbol: Parseable {
    public let n_strx: UInt32 // index into the string table
    public let n_type: SymbolType
    public let n_sect: UInt8  // If type does not have N_SECT, then this defines the section number
    // public let n_desc: DEBUGGER_SYMBOL
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
    
    @AutoOptionSet(.UInt8)
    public struct SymbolType: OptionSet, Sendable {
        //  public static let N_UNDF = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00)
        public static let N_TYPE = SymbolType(rawValue: 0x0e)
        public static let N_ABS = SymbolType(rawValue: 0x02)
        public static let N_SECT = SymbolType(rawValue: 0xe)
        public static let N_PBUD = SymbolType(rawValue: 0xc)
        public static let N_INDR = SymbolType(rawValue: 0xa)
        public static let N_EXT = SymbolType(rawValue: 0x01)
        public static let N_STAB = SymbolType(rawValue: 0xe0)
    }

    @CaseName
    public enum DEBUGGER_SYMBOL: UInt16 {
        case N_NONE = 0x00
        case N_GSYM  =  0x20    /* global symbol: name,,NO_SECT,type,0 */
        case N_FNAME =   0x22    /* procedure name (f77 kludge): name,,NO_SECT,0,0 */
        case N_FUN  =  0x24    /* procedure: name,,n_sect,linenumber,address */
        case N_STSYM  =  0x26    /* static symbol: name,,n_sect,type,address */
        case N_LCSYM  =  0x28    /* .lcomm symbol: name,,n_sect,type,address */
        case N_BNSYM = 0x2e    /* begin nsect sym: 0,,n_sect,0,address */
        case N_AST  =  0x32    /* AST file path: name,,NO_SECT,0,0 */
        case N_OPT  =  0x3c    /* emitted with gcc2_compiled and in gcc source */
        case N_RSYM  =  0x40    /* register sym: name,,NO_SECT,type,register */
        case N_SLINE  =  0x44    /* src line: 0,,n_sect,linenumber,address */
        case N_ENSYM = 0x4e    /* end nsect sym: 0,,n_sect,0,address */
        case N_SSYM  =  0x60    /* structure elt: name,,NO_SECT,type,struct_offset */
        case N_SO  =  0x64    /* source file name: name,,n_sect,0,address */
        case N_OSO  =  0x66    /* object file name: name,,0,0,st_mtime */
        case N_LSYM  =  0x80    /* local sym: name,,NO_SECT,type,offset */
        case N_BINCL  =  0x82    /* include file beginning: name,,NO_SECT,0,sum */
        case N_SOL  =  0x84    /* #included file name: name,,n_sect,0,address */
        case N_PARAMS = 0x86    /* compiler parameters: name,,NO_SECT,0,0 */
        case N_VERSION = 0x88    /* compiler version: name,,NO_SECT,0,0 */
        case N_OLEVEL = 0x8A    /* compiler -O level: name,,NO_SECT,0,0 */
        case N_PSYM  =  0xa0    /* parameter: name,,NO_SECT,type,offset */
        case N_EINCL  =  0xa2    /* include file end: name,,NO_SECT,0,0 */
        case N_ENTRY =   0xa4    /* alternate entry: name,,n_sect,linenumber,address */
        case N_LBRAC  =  0xc0    /* left bracket: 0,,NO_SECT,nesting level,address */
        case N_EXCL  =  0xc2    /* deleted include file: name,,NO_SECT,0,sum */
        case N_RBRAC  =  0xe0    /* right bracket: 0,,NO_SECT,nesting level,address */
        case N_BCOMM  =  0xe2    /* begin common: name,,NO_SECT,0,0 */
        case N_ECOMM =  0xe4    /* end common: name,,n_sect,0,0 */
        case N_ECOML  =  0xe8    /* end common (local name): 0,,n_sect,0,address */
        case N_LENG  =  0xfe    /* second stab entry with length information */

        /*
         * for the berkeley pascal compiler, pc(1):
         */
        case N_PC   = 0x30    /* global pascal symbol: name,,NO_SECT,subtype,line */
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
    public init(parsing input: inout ParserSpan, endianness: Endianness, is64it: Bool = false) throws {
        self.range = input.parserRange.range
        
        self.n_strx = try UInt32(parsing: &input, endianness: endianness)
        self.n_type = try SymbolType(parsing: &input)
        self.n_sect = try UInt8(parsing: &input)
        
        self.n_desc = try UInt16(parsing: &input, endianness: endianness)
        if let sym = try DEBUGGER_SYMBOL(rawValue: self.n_desc) {
            print(sym.description)
        } else {
            print("Unknown value: \(self.n_desc.description)")
        }
        
//        self.n_desc = try DEBUGGER_SYMBOL(parsing: &input, endianness: endianness)
        if is64it {
            self.n_val = NVAL.bit64(try UInt64(parsing: &input, endianness: endianness))
        } else {
            self.n_val = NVAL.bit32(try UInt32(parsing: &input, endianness: endianness))
        }
    }
}

extension Symbol: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "String Table Index", stringValue: n_strx.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "n_type", stringValue: n_type.description, offset: 4, size: 1, children: n_type.activeFlags.enumerated().map { index,flag in
                    .init(label: "0x\(flag.0.rawValue.description)", stringValue: flag.1, offset: 4, size: 1, children: nil, obj: self)
            }, obj: self),
            .init(label: "Section Number", stringValue: n_sect.description, offset: 5, size: 1, children: nil, obj: self),
            .init(label: "n_desc", stringValue: n_desc.description, offset: 6, size: 2, children: nil, obj: self),
            .init(label: "n_val", stringValue: n_val.size.hexDescription, offset: 8, size: n_val.size, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
