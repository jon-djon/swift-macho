//
//  LC_NOTE.swift
//  swift-macho
//
//  Created by jon on 2/21/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_NOTE_Tests {
    // LC_NOTE: data_owner="com.apple", offset=0x1000, size=256
    let allFieldsData = Data([
        0x31, 0x00, 0x00, 0x00,                          // cmd = LC_NOTE (0x31)
        0x28, 0x00, 0x00, 0x00,                          // cmdsize = 40
        0x63, 0x6F, 0x6D, 0x2E, 0x61, 0x70, 0x70, 0x6C, // "com.appl"
        0x65, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // "e\0\0\0\0\0\0\0"
        0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // offset = 0x1000
        0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // size = 256
    ])

    // Zeroed payload with valid cmd/cmdsize
    let zeroedData: Data = {
        var d = Data(repeating: 0, count: 40)
        d[0] = 0x31
        d[4] = 0x28
        return d
    }()

    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00])

    @Test
    func LC_NOTE_AllFields() throws {
        try allFieldsData.withParserSpan { span in
            let f = try SwiftMachO.LC_NOTE(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_NOTE)
            #expect(f.header.cmdSize == 40)
            #expect(f.dataOwner == "com.apple")
            #expect(f.offset == 0x1000)
            #expect(f.size == 256)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_NOTE_Zeroed() throws {
        try zeroedData.withParserSpan { span in
            let f = try SwiftMachO.LC_NOTE(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_NOTE)
            #expect(f.header.cmdSize == 40)
            #expect(f.dataOwner == "")
            #expect(f.offset == 0)
            #expect(f.size == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_NOTE_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_NOTE(parsing: &span, endianness: .little)
            }
        }
    }
}
