//
//  LC_SYMTAB.swift
//  swift-macho
//
//  Created by jon on 2/9/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_SYMTAB_Tests {
    // LC_SYMTAB with symbol table and string table
    // Header: cmd=0x02 (2), cmdsize=0x18 (24)
    // symbolTableOffset: 0x1000 (4096)
    // numSymbols: 0x0A (10)
    // stringTableOffset: 0x2000 (8192)
    // stringTableSize: 0x0100 (256)
    let data = Data([
        0x02, 0x00, 0x00, 0x00,  // cmd = LC_SYMTAB (0x02)
        0x18, 0x00, 0x00, 0x00,  // cmdsize = 24
        0x00, 0x10, 0x00, 0x00,  // symbolTableOffset = 0x1000
        0x0A, 0x00, 0x00, 0x00,  // numSymbols = 10
        0x00, 0x20, 0x00, 0x00,  // stringTableOffset = 0x2000
        0x00, 0x01, 0x00, 0x00,  // stringTableSize = 0x100
    ])

    // LC_SYMTAB with no symbols
    let dataNoSymbols = Data([
        0x02, 0x00, 0x00, 0x00,  // cmd = LC_SYMTAB (0x02)
        0x18, 0x00, 0x00, 0x00,  // cmdsize = 24
        0x00, 0x00, 0x00, 0x00,  // symbolTableOffset = 0
        0x00, 0x00, 0x00, 0x00,  // numSymbols = 0
        0x00, 0x00, 0x00, 0x00,  // stringTableOffset = 0
        0x00, 0x00, 0x00, 0x00,  // stringTableSize = 0
    ])

    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00])

    @Test
    func LC_SYMTAB_WithSymbols() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_SYMTAB(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_SYMTAB)
            #expect(f.header.cmdSize == 24)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.symbolTableOffset == 0x1000)
            #expect(f.numSymbols == 10)
            #expect(f.stringTableOffset == 0x2000)
            #expect(f.stringTableSize == 0x100)
            #expect(f.symbolTableSize == 160) // 10 symbols * 16 bytes each
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_SYMTAB_NoSymbols() throws {
        try dataNoSymbols.withParserSpan { span in
            let f = try SwiftMachO.LC_SYMTAB(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_SYMTAB)
            #expect(f.header.cmdSize == 24)
            #expect(f.symbolTableOffset == 0)
            #expect(f.numSymbols == 0)
            #expect(f.stringTableOffset == 0)
            #expect(f.stringTableSize == 0)
            #expect(f.symbolTableSize == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_SYMTAB_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_SYMTAB(parsing: &span, endianness: .little)
            }
        }
    }
}
