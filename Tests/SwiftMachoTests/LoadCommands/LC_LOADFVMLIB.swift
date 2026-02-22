//
//  LC_LOADFVMLIB.swift
//  swift-macho
//
//  Created by jon on 2/21/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_LOADFVMLIB_Tests {
    // LC_LOADFVMLIB with name "foo" at offset 20
    // cmd=0x06, cmdsize=24, strOffset=20, minorVersion=1, headerAddr=2, name="foo\0"
    let allFieldsData = Data([
        0x06, 0x00, 0x00, 0x00,  // cmd = LC_LOADFVMLIB (0x06)
        0x18, 0x00, 0x00, 0x00,  // cmdsize = 24
        0x14, 0x00, 0x00, 0x00,  // strOffset = 20
        0x01, 0x00, 0x00, 0x00,  // minorVersion = 1
        0x02, 0x00, 0x00, 0x00,  // headerAddr = 2
        0x66, 0x6F, 0x6F, 0x00,  // "foo\0"
    ])

    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00])

    @Test
    func LC_LOADFVMLIB_AllFields() throws {
        try allFieldsData.withParserSpan { span in
            let f = try SwiftMachO.LC_LOADFVMLIB(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_LOADFVMLIB)
            #expect(f.header.cmdSize == 24)
            #expect(f.strOffset == 20)
            #expect(f.minorVersion == 1)
            #expect(f.headerAddr == 2)
            #expect(f.name == "foo")
            #expect(f.nameOffset == 20)
        }
    }

    @Test
    func LC_LOADFVMLIB_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_LOADFVMLIB(parsing: &span, endianness: .little)
            }
        }
    }
}

struct LC_IDFVMLIB_Tests {
    // LC_IDFVMLIB with name "libfoo" at offset 20
    // cmd=0x07, cmdsize=28, strOffset=20, minorVersion=3, headerAddr=0x1000, name="libfoo\0\0"
    let allFieldsData = Data([
        0x07, 0x00, 0x00, 0x00,  // cmd = LC_IDFVMLIB (0x07)
        0x1C, 0x00, 0x00, 0x00,  // cmdsize = 28
        0x14, 0x00, 0x00, 0x00,  // strOffset = 20
        0x03, 0x00, 0x00, 0x00,  // minorVersion = 3
        0x00, 0x10, 0x00, 0x00,  // headerAddr = 0x1000
        0x6C, 0x69, 0x62, 0x66,  // "libf"
        0x6F, 0x6F, 0x00, 0x00,  // "oo\0\0"
    ])

    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x1C, 0x00, 0x00, 0x00])

    @Test
    func LC_IDFVMLIB_AllFields() throws {
        try allFieldsData.withParserSpan { span in
            let f = try SwiftMachO.LC_IDFVMLIB(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_IDFVMLIB)
            #expect(f.header.cmdSize == 28)
            #expect(f.strOffset == 20)
            #expect(f.minorVersion == 3)
            #expect(f.headerAddr == 0x1000)
            #expect(f.name == "libfoo")
            #expect(f.nameOffset == 20)
        }
    }

    @Test
    func LC_IDFVMLIB_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_IDFVMLIB(parsing: &span, endianness: .little)
            }
        }
    }
}
