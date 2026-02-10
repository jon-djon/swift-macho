//
//  LC_LINKER_OPTION.swift
//  swift-macho
//
//  Created by jon on 10/30/25.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_LINKER_OPTION_Tests {
    // LC_LINKER_OPTION with single option "-lswiftCore"
    // Header: cmd=0x2D (45), cmdsize=0x18 (24)
    // count=1, option="-lswiftCore"
    let data = Data([
        0x2D, 0x00, 0x00, 0x00,  // cmd = LC_LINKER_OPTION (0x2D)
        0x18, 0x00, 0x00, 0x00,  // cmdsize = 24
        0x01, 0x00, 0x00, 0x00,  // count = 1
        0x2D, 0x6C, 0x73, 0x77,  // "-lsw"
        0x69, 0x66, 0x74, 0x43,  // "iftC"
        0x6F, 0x72, 0x65, 0x00,  // "ore\0"
    ])
    
    // Wrong command ID
    let bad = Data([0x32, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00])
    
    @Test
    func LC_LINKER_OPTION_Valid() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_LINKER_OPTION(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_LINKER_OPTION)
            #expect(f.header.cmdSize == 24)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.count == 1)
            #expect(f.options[0] == (12, "-lswiftCore"))
            #expect(span.count == 0)
        }
    }
    
    @Test
    func LC_LINKER_OPTION_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: SwiftMachO.MachOError.self) {
                _ = try SwiftMachO.LC_LINKER_OPTION(parsing: &span, endianness: .little)
            }
        }
    }
}
