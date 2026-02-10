//
//  LC_SUB_UMBRELLA.swift
//  swift-macho
//
//  Created by jon on 2/9/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_SUB_UMBRELLA_Tests {
    // LC_SUB_UMBRELLA with umbrella name "Foundation"
    // Header: cmd=0x11 (17), cmdsize=0x18 (24)
    // strOffset=0x0C (12), name="Foundation"
    let data = Data([
        0x12, 0x00, 0x00, 0x00,  // cmd = LC_SUB_UMBRELLA (0x11)
        0x18, 0x00, 0x00, 0x00,  // cmdsize = 24
        0x0C, 0x00, 0x00, 0x00,  // strOffset = 12
        0x46, 0x6F, 0x75, 0x6E,  // "Foun"
        0x64, 0x61, 0x74, 0x69,  // "dati"
        0x6F, 0x6E, 0x00, 0x00,  // "on\0\0"
    ])
    
    // LC_SUB_UMBRELLA with short name "UI"
    let dataShort = Data([
        0x12, 0x00, 0x00, 0x00,  // cmd = LC_SUB_UMBRELLA (0x11)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x0C, 0x00, 0x00, 0x00,  // strOffset = 12
        0x55, 0x49, 0x00, 0x00,  // "UI\0\0"
    ])
    
    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00])
    
    @Test
    func LC_SUB_UMBRELLA_Foundation() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_SUB_UMBRELLA(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_SUB_UMBRELLA)
            #expect(f.header.cmdSize == 24)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.strOffset == 12)
            #expect(f.name == "Foundation")
            #expect(f.nameOffset == 12)
        }
    }

    @Test
    func LC_SUB_UMBRELLA_ShortName() throws {
        try dataShort.withParserSpan { span in
            let f = try SwiftMachO.LC_SUB_UMBRELLA(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_SUB_UMBRELLA)
            #expect(f.header.cmdSize == 16)
            #expect(f.strOffset == 12)
            #expect(f.name == "UI")
        }
    }

    @Test
    func LC_SUB_UMBRELLA_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_SUB_UMBRELLA(parsing: &span, endianness: .little)
            }
        }
    }
}
