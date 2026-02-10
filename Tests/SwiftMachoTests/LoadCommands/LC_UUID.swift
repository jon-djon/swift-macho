//
//  LC_UUID.swift
//  swift-macho
//
//  Created by jon on 10/28/25.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_UUID_Tests {
    // LC_UUID with UUID D67AB23B-2106-3E1F-9823-C5E5759D85A4
    // Header: cmd=0x1B (27), cmdsize=0x18 (24)
    let data = Data([
        0x1B, 0x00, 0x00, 0x00,  // cmd = LC_UUID (0x1B)
        0x18, 0x00, 0x00, 0x00,  // cmdsize = 24
        0xD6, 0x7A, 0xB2, 0x3B,  // uuid bytes 0-3
        0x21, 0x06, 0x3E, 0x1F,  // uuid bytes 4-7
        0x98, 0x23, 0xC5, 0xE5,  // uuid bytes 8-11
        0x75, 0x9D, 0x85, 0xA4,  // uuid bytes 12-15
    ])
    
    // Wrong command ID
    let bad = Data([0x32, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00])
    
    @Test
    func LC_UUID_Valid() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_UUID(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_UUID)
            #expect(f.header.cmdSize == 24)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.uuid.description == "D67AB23B-2106-3E1F-9823-C5E5759D85A4")
            #expect(span.count == 0)
        }
    }
    
    @Test
    func LC_UUID_WrongEndianness() throws {
        _ = data.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_UUID(parsing: &span, endianness: .big)
            }
        }
    }
    
    @Test
    func LC_UUID_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: SwiftMachO.MachOError.self) {
                _ = try SwiftMachO.LC_UUID(parsing: &span, endianness: .little)
            }
        }
    }
}
