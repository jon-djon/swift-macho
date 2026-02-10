//
//  LC_BUILD_VERSION.swift
//  swift-macho
//
//  Created by jon on 2/4/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_BUILD_VERSION_Tests {
    // LC_BUILD_VERSION with platform=macOS, minOS=15.0.0, sdk=15.2.0, 2 tools (ld, swift)
    // Header: cmd=0x32 (50), cmdsize=0x30 (48)
    // Platform: 0x01 (PLATFORM_MACOS)
    // MinOS: 0x000F0000 (15.0.0)
    // SDK: 0x000F0200 (15.2.0)
    // ntools: 0x02
    // Tool 1: tool=0x03 (TOOL_LD), version=0x03E80000 (1000.0.0)
    // Tool 2: tool=0x02 (TOOL_SWIFT), version=0x06020000 (1538.0.0)
    let data = Data([
        0x32, 0x00, 0x00, 0x00,  // cmd = LC_BUILD_VERSION (0x32)
        0x28, 0x00, 0x00, 0x00,  // cmdsize = 40
        0x01, 0x00, 0x00, 0x00,  // platform = PLATFORM_MACOS (1)
        0x00, 0x00, 0x0F, 0x00,  // minos = 15.0.0
        0x00, 0x02, 0x0F, 0x00,  // sdk = 15.2.0
        0x02, 0x00, 0x00, 0x00,  // ntools = 2
        // Tool 1: ld
        0x03, 0x00, 0x00, 0x00,  // tool = TOOL_LD (3)
        0x00, 0x00, 0xE8, 0x03,  // version = 1000.0.0
        // Tool 2: swift
        0x02, 0x00, 0x00, 0x00,  // tool = TOOL_SWIFT (2)
        0x00, 0x00, 0x02, 0x06,  // version = 1538.0.0
    ])

    // LC_BUILD_VERSION with no tools
    let dataNoTools = Data([
        0x32, 0x00, 0x00, 0x00,  // cmd = LC_BUILD_VERSION (0x32)
        0x18, 0x00, 0x00, 0x00,  // cmdsize = 24
        0x07, 0x00, 0x00, 0x00,  // platform = PLATFORM_IOSSIMULATOR (7)
        0x00, 0x00, 0x11, 0x00,  // minos = 17.0.0
        0x00, 0x02, 0x11, 0x00,  // sdk = 17.2.0
        0x00, 0x00, 0x00, 0x00,  // ntools = 0
    ])

    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00])

    @Test
    func LC_BUILD_VERSION_WithTools() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_BUILD_VERSION(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_BUILD_VERSION)
            #expect(f.header.cmdSize == 40)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.platform == .PLATFORM_MACOS)
            #expect(f.minOS.major == 15)
            #expect(f.minOS.minor == 0)
            #expect(f.minOS.patch == 0)
            #expect(f.sdk.major == 15)
            #expect(f.sdk.minor == 2)
            #expect(f.sdk.patch == 0)
            #expect(f.ntools == 2)
            #expect(f.tools.count == 2)
            #expect(f.tools[0].tool == .TOOL_LD)
            #expect(f.tools[0].version.major == 1000)
            #expect(f.tools[1].tool == .TOOL_SWIFT)
            #expect(f.tools[1].version.major == 1538)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_BUILD_VERSION_NoTools() throws {
        try dataNoTools.withParserSpan { span in
            let f = try SwiftMachO.LC_BUILD_VERSION(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_BUILD_VERSION)
            #expect(f.header.cmdSize == 24)
            #expect(f.platform == .PLATFORM_IOSSIMULATOR)
            #expect(f.minOS.major == 17)
            #expect(f.minOS.minor == 0)
            #expect(f.sdk.major == 17)
            #expect(f.sdk.minor == 2)
            #expect(f.ntools == 0)
            #expect(f.tools.isEmpty)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_BUILD_VERSION_InvalidCommand() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_BUILD_VERSION(parsing: &span, endianness: .little)
            }
        }
    }
}
