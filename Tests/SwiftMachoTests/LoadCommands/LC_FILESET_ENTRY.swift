//
//  LC_FILESET_ENTRY.swift
//  swift-macho
//
//  Created by jon on 2/4/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_FILESET_ENTRY_Tests {
    // LC_FILESET_ENTRY for a kernel extension
    // Header: cmd=0x80000035 (LC_FILESET_ENTRY), cmdsize=56
    // vmaddr=0xFFFFFF8000100000, fileoff=0x100000
    // entryIdOffset=32, reserved=0
    // Entry ID string: "com.apple.kext.example" at offset 32
    let data = Data([
        0x35, 0x00, 0x00, 0x80,  // cmd = LC_FILESET_ENTRY (0x80000035)
        0x38, 0x00, 0x00, 0x00,  // cmdsize = 56
        0x00, 0x00, 0x10, 0x00,  // vmaddr (low)
        0x80, 0xFF, 0xFF, 0xFF,  // vmaddr (high) = 0xFFFFFF8000100000
        0x00, 0x00, 0x10, 0x00,  // fileoff (low)
        0x00, 0x00, 0x00, 0x00,  // fileoff (high) = 0x100000
        0x20, 0x00, 0x00, 0x00,  // entryIdOffset = 32
        0x00, 0x00, 0x00, 0x00,  // reserved = 0
        // Entry ID string at offset 32: "com.apple.kext.example\0"
        0x63, 0x6F, 0x6D, 0x2E,  // "com."
        0x61, 0x70, 0x70, 0x6C,  // "appl"
        0x65, 0x2E, 0x6B, 0x65,  // "e.ke"
        0x78, 0x74, 0x2E, 0x65,  // "xt.e"
        0x78, 0x61, 0x6D, 0x70,  // "xamp"
        0x6C, 0x65, 0x00, 0x00,  // "le\0\0"
    ])

    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00])

    @Test
    func LC_FILESET_ENTRY_Parse() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_FILESET_ENTRY(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_FILESET_ENTRY)
            #expect(f.header.cmdSize == 56)
            #expect(f.vmaddr == 0xFFFFFF8000100000)
            #expect(f.fileoff == 0x100000)
            #expect(f.entryIdOffset == 32)
            #expect(f.reserved == 0)
            #expect(f.entryId == "com.apple.kext.example")
        }
    }

    @Test
    func LC_FILESET_ENTRY_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_FILESET_ENTRY(parsing: &span, endianness: .little)
            }
        }
    }
}
