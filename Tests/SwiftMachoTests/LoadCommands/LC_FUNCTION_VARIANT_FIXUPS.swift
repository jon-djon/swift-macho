//
//  LC_FUNCTION_VARIANT_FIXUPS.swift
//  swift-macho
//
//  Created by jon on 2/16/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_FUNCTION_VARIANT_FIXUPS_Tests {
    // LC_FUNCTION_VARIANT_FIXUPS with some data
    // Header: cmd=0x38, cmdsize=16
    let dataWithFixups = Data([
        0x38, 0x00, 0x00, 0x00,  // cmd = LC_FUNCTION_VARIANT_FIXUPS (0x38)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x90, 0x00, 0x00,  // offset = 0x9000
        0x80, 0x00, 0x00, 0x00,  // size = 128
    ])

    // LC_FUNCTION_VARIANT_FIXUPS with no data
    let dataWithNoFixups = Data([
        0x38, 0x00, 0x00, 0x00,  // cmd = LC_FUNCTION_VARIANT_FIXUPS (0x38)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x00, 0x00, 0x00,  // offset = 0
        0x00, 0x00, 0x00, 0x00,  // size = 0
    ])

    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00])

    @Test
    func LC_FUNCTION_VARIANT_FIXUPS_WithFixups() throws {
        try dataWithFixups.withParserSpan { span in
            let f = try SwiftMachO.LC_FUNCTION_VARIANT_FIXUPS(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_FUNCTION_VARIANT_FIXUPS)
            #expect(f.header.cmdSize == 16)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.offset == 0x9000)
            #expect(f.size == 128)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_FUNCTION_VARIANT_FIXUPS_NoFixups() throws {
        try dataWithNoFixups.withParserSpan { span in
            let f = try SwiftMachO.LC_FUNCTION_VARIANT_FIXUPS(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_FUNCTION_VARIANT_FIXUPS)
            #expect(f.header.cmdSize == 16)
            #expect(f.offset == 0)
            #expect(f.size == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_FUNCTION_VARIANT_FIXUPS_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_FUNCTION_VARIANT_FIXUPS(parsing: &span, endianness: .little)
            }
        }
    }
}
