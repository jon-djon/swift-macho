//
//  LC_LINKER_OPTIMIZATION_HINT.swift
//  swift-macho
//
//  Created by jon on 10/30/25.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_LINKER_OPTIMIZATION_HINT_Tests {
    // LC_LINKER_OPTIMIZATION_HINT with optimization hints
    // Header: cmd=0x2E (46), cmdsize=0x10 (16)
    // offset=0x15DB8 (89528), size=0x28 (40)
    let data = Data([
        0x2E, 0x00, 0x00, 0x00,  // cmd = LC_LINKER_OPTIMIZATION_HINT (0x2E)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0xB8, 0x5D, 0x01, 0x00,  // offset = 0x15DB8 (89528)
        0x28, 0x00, 0x00, 0x00,  // size = 0x28 (40)
    ])
    
    // LC_LINKER_OPTIMIZATION_HINT with no hints (size = 0)
    let dataNoHints = Data([
        0x2E, 0x00, 0x00, 0x00,  // cmd = LC_LINKER_OPTIMIZATION_HINT (0x2E)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x00, 0x00, 0x00,  // offset = 0
        0x00, 0x00, 0x00, 0x00,  // size = 0
    ])
    
    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00])
    
    @Test
    func LC_LINKER_OPTIMIZATION_HINT_WithHints() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_LINKER_OPTIMIZATION_HINT(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_LINKER_OPTIMIZATION_HINT)
            #expect(f.header.cmdSize == 16)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.offset == 0x15DB8)
            #expect(f.size == 0x28)
            #expect(span.count == 0)
        }
    }
    
    @Test
    func LC_LINKER_OPTIMIZATION_HINT_NoHints() throws {
        try dataNoHints.withParserSpan { span in
            let f = try SwiftMachO.LC_LINKER_OPTIMIZATION_HINT(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_LINKER_OPTIMIZATION_HINT)
            #expect(f.header.cmdSize == 16)
            #expect(f.offset == 0)
            #expect(f.size == 0)
            #expect(span.count == 0)
        }
    }
    
    @Test
    func LC_LINKER_OPTIMIZATION_HINT_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_LINKER_OPTIMIZATION_HINT(parsing: &span, endianness: .little)
            }
        }
    }
}
