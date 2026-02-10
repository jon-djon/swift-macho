//
//  LC_ENCRYPTION_INFO_64.swift
//  swift-macho
//
//  Created by jon on 2/4/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_ENCRYPTION_INFO_64_Tests {
    // LC_ENCRYPTION_INFO_64 with cryptID = 0 (not encrypted)
    // Header: cmd=0x2C (44), cmdsize=0x18 (24)
    // offset=0x4000, size=0x10000, cryptID=0, pad=0
    let dataNotEncrypted = Data([
        0x2C, 0x00, 0x00, 0x00,  // cmd = LC_ENCRYPTION_INFO_64 (0x2C)
        0x18, 0x00, 0x00, 0x00,  // cmdsize = 24
        0x00, 0x40, 0x00, 0x00,  // offset = 0x4000
        0x00, 0x00, 0x01, 0x00,  // size = 0x10000
        0x00, 0x00, 0x00, 0x00,  // cryptID = 0 (not encrypted)
        0x00, 0x00, 0x00, 0x00,  // pad = 0
    ])

    // LC_ENCRYPTION_INFO_64 with cryptID = 1 (encrypted/FairPlay)
    let dataEncrypted = Data([
        0x2C, 0x00, 0x00, 0x00,  // cmd = LC_ENCRYPTION_INFO_64 (0x2C)
        0x18, 0x00, 0x00, 0x00,  // cmdsize = 24
        0x00, 0x40, 0x00, 0x00,  // offset = 0x4000
        0x00, 0x00, 0x01, 0x00,  // size = 0x10000
        0x01, 0x00, 0x00, 0x00,  // cryptID = 1 (encrypted)
        0x00, 0x00, 0x00, 0x00,  // pad = 0
    ])

    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00])

    @Test
    func LC_ENCRYPTION_INFO_64_NotEncrypted() throws {
        try dataNotEncrypted.withParserSpan { span in
            let f = try SwiftMachO.LC_ENCRYPTION_INFO_64(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_ENCRYPTION_INFO_64)
            #expect(f.header.cmdSize == 24)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.offset == 0x4000)
            #expect(f.size == 0x10000)
            #expect(f.cryptID == .notEncrypted)
            #expect(f.pad == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_ENCRYPTION_INFO_64_Encrypted() throws {
        try dataEncrypted.withParserSpan { span in
            let f = try SwiftMachO.LC_ENCRYPTION_INFO_64(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_ENCRYPTION_INFO_64)
            #expect(f.header.cmdSize == 24)
            #expect(f.offset == 0x4000)
            #expect(f.size == 0x10000)
            #expect(f.cryptID == .encrypted)
            #expect(f.pad == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_ENCRYPTION_INFO_64_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_ENCRYPTION_INFO_64(parsing: &span, endianness: .little)
            }
        }
    }
}
