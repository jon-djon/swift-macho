//
//  LC_DYLD_INFO_ONLY.swift
//  swift-macho
//
//  Created by jon on 2/9/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_DYLD_INFO_ONLY_Tests {
    // LC_DYLD_INFO_ONLY with all sections populated
    // Header: cmd=0x80000022, cmdsize=0x30 (48)
    // rebaseOff=0x1000, rebaseSize=0x100
    // bindOff=0x1100, bindSize=0x200
    // weakBindOff=0x1300, weakBindSize=0x50
    // lazyBindOff=0x1350, lazyBindSize=0x150
    // exportBindOff=0x1500, exportBindSize=0x300
    let dataWithAllSections = Data([
        0x22, 0x00, 0x00, 0x80,  // cmd = LC_DYLD_INFO_ONLY (0x80000022)
        0x30, 0x00, 0x00, 0x00,  // cmdsize = 48
        0x00, 0x10, 0x00, 0x00,  // rebaseOff = 0x1000
        0x00, 0x01, 0x00, 0x00,  // rebaseSize = 0x100
        0x00, 0x11, 0x00, 0x00,  // bindOff = 0x1100
        0x00, 0x02, 0x00, 0x00,  // bindSize = 0x200
        0x00, 0x13, 0x00, 0x00,  // weakBindOff = 0x1300
        0x50, 0x00, 0x00, 0x00,  // weakBindSize = 0x50
        0x50, 0x13, 0x00, 0x00,  // lazyBindOff = 0x1350
        0x50, 0x01, 0x00, 0x00,  // lazyBindSize = 0x150
        0x00, 0x15, 0x00, 0x00,  // exportBindOff = 0x1500
        0x00, 0x03, 0x00, 0x00,  // exportBindSize = 0x300
    ])

    // LC_DYLD_INFO_ONLY with no sections (all zeros)
    let dataNoSections = Data([
        0x22, 0x00, 0x00, 0x80,  // cmd = LC_DYLD_INFO_ONLY (0x80000022)
        0x30, 0x00, 0x00, 0x00,  // cmdsize = 48
        0x00, 0x00, 0x00, 0x00,  // rebaseOff = 0
        0x00, 0x00, 0x00, 0x00,  // rebaseSize = 0
        0x00, 0x00, 0x00, 0x00,  // bindOff = 0
        0x00, 0x00, 0x00, 0x00,  // bindSize = 0
        0x00, 0x00, 0x00, 0x00,  // weakBindOff = 0
        0x00, 0x00, 0x00, 0x00,  // weakBindSize = 0
        0x00, 0x00, 0x00, 0x00,  // lazyBindOff = 0
        0x00, 0x00, 0x00, 0x00,  // lazyBindSize = 0
        0x00, 0x00, 0x00, 0x00,  // exportBindOff = 0
        0x00, 0x00, 0x00, 0x00,  // exportBindSize = 0
    ])

    // LC_DYLD_INFO_ONLY with only some sections populated
    let dataPartialSections = Data([
        0x22, 0x00, 0x00, 0x80,  // cmd = LC_DYLD_INFO_ONLY (0x80000022)
        0x30, 0x00, 0x00, 0x00,  // cmdsize = 48
        0x00, 0x20, 0x00, 0x00,  // rebaseOff = 0x2000
        0x80, 0x00, 0x00, 0x00,  // rebaseSize = 0x80
        0x00, 0x00, 0x00, 0x00,  // bindOff = 0 (no bind info)
        0x00, 0x00, 0x00, 0x00,  // bindSize = 0
        0x00, 0x00, 0x00, 0x00,  // weakBindOff = 0 (no weak bind)
        0x00, 0x00, 0x00, 0x00,  // weakBindSize = 0
        0x80, 0x20, 0x00, 0x00,  // lazyBindOff = 0x2080
        0x40, 0x00, 0x00, 0x00,  // lazyBindSize = 0x40
        0xC0, 0x20, 0x00, 0x00,  // exportBindOff = 0x20C0
        0x00, 0x01, 0x00, 0x00,  // exportBindSize = 0x100
    ])

    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00])

    @Test
    func LC_DYLD_INFO_ONLY_WithAllSections() throws {
        try dataWithAllSections.withParserSpan { span in
            let f = try SwiftMachO.LC_DYLD_INFO_ONLY(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_DYLD_INFO_ONLY)
            #expect(f.header.cmdSize == 48)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.rebaseOff == 0x1000)
            #expect(f.rebaseSize == 0x100)
            #expect(f.bindOff == 0x1100)
            #expect(f.bindSize == 0x200)
            #expect(f.weakBindOff == 0x1300)
            #expect(f.weakBindSize == 0x50)
            #expect(f.lazyBindOff == 0x1350)
            #expect(f.lazyBindSize == 0x150)
            #expect(f.exportBindOff == 0x1500)
            #expect(f.exportBindSize == 0x300)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_DYLD_INFO_ONLY_NoSections() throws {
        try dataNoSections.withParserSpan { span in
            let f = try SwiftMachO.LC_DYLD_INFO_ONLY(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_DYLD_INFO_ONLY)
            #expect(f.header.cmdSize == 48)
            #expect(f.rebaseOff == 0)
            #expect(f.rebaseSize == 0)
            #expect(f.bindOff == 0)
            #expect(f.bindSize == 0)
            #expect(f.weakBindOff == 0)
            #expect(f.weakBindSize == 0)
            #expect(f.lazyBindOff == 0)
            #expect(f.lazyBindSize == 0)
            #expect(f.exportBindOff == 0)
            #expect(f.exportBindSize == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_DYLD_INFO_ONLY_PartialSections() throws {
        try dataPartialSections.withParserSpan { span in
            let f = try SwiftMachO.LC_DYLD_INFO_ONLY(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_DYLD_INFO_ONLY)
            #expect(f.header.cmdSize == 48)
            #expect(f.rebaseOff == 0x2000)
            #expect(f.rebaseSize == 0x80)
            #expect(f.bindOff == 0)
            #expect(f.bindSize == 0)
            #expect(f.weakBindOff == 0)
            #expect(f.weakBindSize == 0)
            #expect(f.lazyBindOff == 0x2080)
            #expect(f.lazyBindSize == 0x40)
            #expect(f.exportBindOff == 0x20C0)
            #expect(f.exportBindSize == 0x100)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_DYLD_INFO_ONLY_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_DYLD_INFO_ONLY(parsing: &span, endianness: .little)
            }
        }
    }
}
