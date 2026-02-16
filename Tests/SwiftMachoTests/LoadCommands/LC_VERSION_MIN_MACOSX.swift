//
//  LC_VERSION_MIN_MACOSX.swift
//  swift-macho
//
//  Created by jon on 2/11/26.
//

import BinaryParsing
import Foundation
import Testing

@testable import SwiftMachO

struct LC_VERSION_MIN_MACOSX_Tests {
    // LC_VERSION_MIN_MACOSX with version=10.13.0, sdk=10.15.6
    // Header: cmd=0x24 (36), cmdsize=0x10 (16)
    // Version: 0x000A0D00 (10.13.0)
    // SDK: 0x000A0F06 (10.15.6)
    let data = Data([
        0x24, 0x00, 0x00, 0x00,  // cmd = LC_VERSION_MIN_MACOSX (0x24)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x0D, 0x0A, 0x00,  // version = 10.13.0
        0x06, 0x0F, 0x0A, 0x00,  // sdk = 10.15.6
    ])

    // LC_VERSION_MIN_MACOSX with version=12.0.0, sdk=12.3.0
    // Version: 0x000C0000 (12.0.0)
    // SDK: 0x000C0300 (12.3.0)
    let dataV12 = Data([
        0x24, 0x00, 0x00, 0x00,  // cmd = LC_VERSION_MIN_MACOSX (0x24)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x00, 0x0C, 0x00,  // version = 12.0.0
        0x00, 0x03, 0x0C, 0x00,  // sdk = 12.3.0
    ])

    // Wrong command ID
    let bad = Data([
        0x50, 0x00, 0x00, 0x00,  // cmd = invalid (0x50)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x0D, 0x0A, 0x00,
        0x06, 0x0F, 0x0A, 0x00,
    ])

    @Test
    func LC_VERSION_MIN_MACOSX_Valid() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_VERSION_MIN_MACOSX(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_VERSION_MIN_MACOSX)
            #expect(f.header.cmdSize == 16)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.version.major == 10)
            #expect(f.version.minor == 13)
            #expect(f.version.patch == 0)
            #expect(f.version.description == "10.13.0")
            #expect(f.sdk.major == 10)
            #expect(f.sdk.minor == 15)
            #expect(f.sdk.patch == 6)
            #expect(f.sdk.description == "10.15.6")
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_VERSION_MIN_MACOSX_V12() throws {
        try dataV12.withParserSpan { span in
            let f = try SwiftMachO.LC_VERSION_MIN_MACOSX(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_VERSION_MIN_MACOSX)
            #expect(f.header.cmdSize == 16)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.version.major == 12)
            #expect(f.version.minor == 0)
            #expect(f.version.patch == 0)
            #expect(f.version.description == "12.0.0")
            #expect(f.sdk.major == 12)
            #expect(f.sdk.minor == 3)
            #expect(f.sdk.patch == 0)
            #expect(f.sdk.description == "12.3.0")
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_VERSION_MIN_MACOSX_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_VERSION_MIN_MACOSX(parsing: &span, endianness: .little)
            }
        }
    }
}
