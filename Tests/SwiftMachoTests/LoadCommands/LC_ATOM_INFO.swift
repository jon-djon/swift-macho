//
//  LC_ATOM_INFO.swift
//  swift-macho
//
//  Created by jon on 2/9/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_ATOM_INFO_Tests {
    // LC_ATOM_INFO with atom info data
    // Header: cmd=0x36 (54), cmdsize=0x10 (16)
    // offset=0x4000 (16384), size=0x100 (256)
    let data = Data([
        0x36, 0x00, 0x00, 0x00,  // cmd = LC_ATOM_INFO (0x36)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x40, 0x00, 0x00,  // offset = 0x4000
        0x00, 0x01, 0x00, 0x00,  // size = 0x100
    ])

    // LC_ATOM_INFO with no atom info (size = 0)
    let dataNoInfo = Data([
        0x36, 0x00, 0x00, 0x00,  // cmd = LC_ATOM_INFO (0x36)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x00, 0x00, 0x00,  // offset = 0
        0x00, 0x00, 0x00, 0x00,  // size = 0
    ])

    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00])

    @Test
    func LC_ATOM_INFO_WithData() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_ATOM_INFO(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_ATOM_INFO)
            #expect(f.header.cmdSize == 16)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.offset == 0x4000)
            #expect(f.size == 0x100)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_ATOM_INFO_NoData() throws {
        try dataNoInfo.withParserSpan { span in
            let f = try SwiftMachO.LC_ATOM_INFO(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_ATOM_INFO)
            #expect(f.header.cmdSize == 16)
            #expect(f.offset == 0)
            #expect(f.size == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_ATOM_INFO_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_ATOM_INFO(parsing: &span, endianness: .little)
            }
        }
    }
}
