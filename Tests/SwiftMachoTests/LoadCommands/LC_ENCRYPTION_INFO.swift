//
//  LC_ENCRYPTION_INFO.swift
//  swift-macho
//
//  Created by jon on 2/4/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_ENCRYPTION_INFO_Tests {
    // LC_ENCRYPTION_INFO with cryptID = 0 (not encrypted)
    // Header: cmd=0x21 (33), cmdsize=0x14 (20)
    // offset=0x4000, size=0x8000, cryptID=0
    let dataNotEncrypted = Data([
        0x21, 0x00, 0x00, 0x00,  // cmd = LC_ENCRYPTION_INFO (0x21)
        0x14, 0x00, 0x00, 0x00,  // cmdsize = 20
        0x00, 0x40, 0x00, 0x00,  // offset = 0x4000
        0x00, 0x80, 0x00, 0x00,  // size = 0x8000
        0x00, 0x00, 0x00, 0x00,  // cryptID = 0 (not encrypted)
    ])

    // LC_ENCRYPTION_INFO with cryptID = 1 (encrypted/FairPlay)
    let dataEncrypted = Data([
        0x21, 0x00, 0x00, 0x00,  // cmd = LC_ENCRYPTION_INFO (0x21)
        0x14, 0x00, 0x00, 0x00,  // cmdsize = 20
        0x00, 0x40, 0x00, 0x00,  // offset = 0x4000
        0x00, 0x80, 0x00, 0x00,  // size = 0x8000
        0x01, 0x00, 0x00, 0x00,  // cryptID = 1 (encrypted)
    ])

    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00])

    @Test
    func LC_ENCRYPTION_INFO_NotEncrypted() throws {
        try dataNotEncrypted.withParserSpan { span in
            let f = try SwiftMachO.LC_ENCRYPTION_INFO(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_ENCRYPTION_INFO)
            #expect(f.header.cmdSize == 20)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.offset == 0x4000)
            #expect(f.size == 0x8000)
            #expect(f.cryptID == .notEncrypted)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_ENCRYPTION_INFO_Encrypted() throws {
        try dataEncrypted.withParserSpan { span in
            let f = try SwiftMachO.LC_ENCRYPTION_INFO(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_ENCRYPTION_INFO)
            #expect(f.header.cmdSize == 20)
            #expect(f.offset == 0x4000)
            #expect(f.size == 0x8000)
            #expect(f.cryptID == .encrypted)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_ENCRYPTION_INFO_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_ENCRYPTION_INFO(parsing: &span, endianness: .little)
            }
        }
    }
}
