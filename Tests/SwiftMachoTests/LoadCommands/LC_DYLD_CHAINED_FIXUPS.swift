//
//  LC_DYLD_CHAINED_FIXUPS.swift
//  swift-macho
//
//  Created by jon on 2/9/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_DYLD_CHAINED_FIXUPS_Tests {
    // LC_DYLD_CHAINED_FIXUPS with chained fixups data
    // Header: cmd=0x80000034, cmdsize=0x10 (16)
    // offset=0x8000 (32768), size=0x500 (1280)
    let data = Data([
        0x34, 0x00, 0x00, 0x80,  // cmd = LC_DYLD_CHAINED_FIXUPS (0x80000034)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x80, 0x00, 0x00,  // offset = 0x8000
        0x00, 0x05, 0x00, 0x00,  // size = 0x500
    ])
    
    // LC_DYLD_CHAINED_FIXUPS with small fixups data
    let dataSmall = Data([
        0x34, 0x00, 0x00, 0x80,  // cmd = LC_DYLD_CHAINED_FIXUPS (0x80000034)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x10, 0x00, 0x00,  // offset = 0x1000
        0x40, 0x00, 0x00, 0x00,  // size = 0x40
    ])
    
    // LC_DYLD_CHAINED_FIXUPS with no fixups (size = 0)
    let dataNoFixups = Data([
        0x34, 0x00, 0x00, 0x80,  // cmd = LC_DYLD_CHAINED_FIXUPS (0x80000034)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x00, 0x00, 0x00,  // offset = 0
        0x00, 0x00, 0x00, 0x00,  // size = 0
    ])
    
    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00])
    
    @Test
    func LC_DYLD_CHAINED_FIXUPS_WithData() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_DYLD_CHAINED_FIXUPS(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_DYLD_CHAINED_FIXUPS)
            #expect(f.header.cmdSize == 16)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.offset == 0x8000)
            #expect(f.size == 0x500)
            #expect(span.count == 0)
        }
    }
    
    @Test
    func LC_DYLD_CHAINED_FIXUPS_SmallData() throws {
        try dataSmall.withParserSpan { span in
            let f = try SwiftMachO.LC_DYLD_CHAINED_FIXUPS(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_DYLD_CHAINED_FIXUPS)
            #expect(f.header.cmdSize == 16)
            #expect(f.offset == 0x1000)
            #expect(f.size == 0x40)
            #expect(span.count == 0)
        }
    }
    
    @Test
    func LC_DYLD_CHAINED_FIXUPS_NoFixups() throws {
        try dataNoFixups.withParserSpan { span in
            let f = try SwiftMachO.LC_DYLD_CHAINED_FIXUPS(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_DYLD_CHAINED_FIXUPS)
            #expect(f.header.cmdSize == 16)
            #expect(f.offset == 0)
            #expect(f.size == 0)
            #expect(span.count == 0)
        }
    }
    
    @Test
    func LC_DYLD_CHAINED_FIXUPS_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_DYLD_CHAINED_FIXUPS(parsing: &span, endianness: .little)
            }
        }
    }
}
