//
//  LC_TWOLEVEL_HINTS.swift
//  swift-macho
//
//  Created by jon on 2/16/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_TWOLEVEL_HINTS_Tests {
    // LC_TWOLEVEL_HINTS with 256 hints
    // Header: cmd=0x13, cmdsize=16
    let dataWithHints = Data([
        0x15, 0x00, 0x00, 0x00,  // cmd = LC_TWOLEVEL_HINTS (0x15)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x80, 0x00, 0x00,  // offset = 0x8000
        0x00, 0x01, 0x00, 0x00,  // nhints = 256
    ])

    // LC_TWOLEVEL_HINTS with no hints
    let dataWithNoHints = Data([
        0x15, 0x00, 0x00, 0x00,  // cmd = LC_TWOLEVEL_HINTS (0x15)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x00, 0x00, 0x00,  // offset = 0
        0x00, 0x00, 0x00, 0x00,  // nhints = 0
    ])

    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00])

    @Test
    func LC_TWOLEVEL_HINTS_WithHints() throws {
        try dataWithHints.withParserSpan { span in
            let f = try SwiftMachO.LC_TWOLEVEL_HINTS(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_TWOLEVEL_HINTS)
            #expect(f.header.cmdSize == 16)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.offset == 0x8000)
            #expect(f.nhints == 256)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_TWOLEVEL_HINTS_NoHints() throws {
        try dataWithNoHints.withParserSpan { span in
            let f = try SwiftMachO.LC_TWOLEVEL_HINTS(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_TWOLEVEL_HINTS)
            #expect(f.header.cmdSize == 16)
            #expect(f.offset == 0)
            #expect(f.nhints == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_TWOLEVEL_HINTS_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_TWOLEVEL_HINTS(parsing: &span, endianness: .little)
            }
        }
    }
}
