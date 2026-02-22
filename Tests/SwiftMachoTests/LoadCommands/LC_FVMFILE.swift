//
//  LC_FVMFILE.swift
//  swift-macho
//
//  Created by jon on 2/21/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_FVMFILE_Tests {
    // LC_FVMFILE with name "baz" at offset 16
    // cmd=0x09, cmdsize=20, strOffset=16, headerAddr=0x1000, name="baz\0"
    let allFieldsData = Data([
        0x09, 0x00, 0x00, 0x00,  // cmd = LC_FVMFILE (0x09)
        0x14, 0x00, 0x00, 0x00,  // cmdsize = 20
        0x10, 0x00, 0x00, 0x00,  // strOffset = 16
        0x00, 0x10, 0x00, 0x00,  // headerAddr = 0x1000
        0x62, 0x61, 0x7A, 0x00,  // "baz\0"
    ])

    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00])

    @Test
    func LC_FVMFILE_AllFields() throws {
        try allFieldsData.withParserSpan { span in
            let f = try SwiftMachO.LC_FVMFILE(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_FVMFILE)
            #expect(f.header.cmdSize == 20)
            #expect(f.strOffset == 16)
            #expect(f.headerAddr == 0x1000)
            #expect(f.name == "baz")
            #expect(f.nameOffset == 16)
        }
    }

    @Test
    func LC_FVMFILE_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_FVMFILE(parsing: &span, endianness: .little)
            }
        }
    }
}
