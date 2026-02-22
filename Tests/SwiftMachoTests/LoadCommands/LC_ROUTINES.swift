//
//  LC_ROUTINES.swift
//  swift-macho
//
//  Created by jon on 2/19/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_ROUTINES_Tests {

    let allFieldsData = Data([
        0x10, 0x00, 0x00, 0x00, // cmd = LC_ROUTINES (0x10)
        0x28, 0x00, 0x00, 0x00, // cmdsize = 40
        0x01, 0x00, 0x00, 0x00, // initAddress
        0x02, 0x00, 0x00, 0x00, // initModule
        0x03, 0x00, 0x00, 0x00, // reserved1
        0x04, 0x00, 0x00, 0x00, // reserved2
        0x05, 0x00, 0x00, 0x00, // reserved3
        0x06, 0x00, 0x00, 0x00, // reserved4
        0x07, 0x00, 0x00, 0x00, // reserved5
        0x08, 0x00, 0x00, 0x00, // reserved6
    ])

    @Test
    func LC_ROUTINES_AllFields() throws {
        try allFieldsData.withParserSpan { span in
            let f = try SwiftMachO.LC_ROUTINES(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_ROUTINES)
            #expect(f.header.cmdSize == 40)
            #expect(f.initAddress == 1)
            #expect(f.initModule == 2)
            #expect(f.reserved1 == 3)
            #expect(f.reserved2 == 4)
            #expect(f.reserved3 == 5)
            #expect(f.reserved4 == 6)
            #expect(f.reserved5 == 7)
            #expect(f.reserved6 == 8)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_ROUTINES_Zeroed() throws {
        var zeroedData = Data(repeating: 0, count: 40)
        zeroedData[0] = 0x10
        zeroedData[4] = 0x28

        try zeroedData.withParserSpan { span in
            let f = try SwiftMachO.LC_ROUTINES(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_ROUTINES)
            #expect(f.header.cmdSize == 40)
            #expect(f.initAddress == 0)
            #expect(f.initModule == 0)
            #expect(f.reserved1 == 0)
            #expect(f.reserved2 == 0)
            #expect(f.reserved3 == 0)
            #expect(f.reserved4 == 0)
            #expect(f.reserved5 == 0)
            #expect(f.reserved6 == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_ROUTINES_InvalidCommand() throws {
        let bad = Data([0x50, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00])
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_ROUTINES(parsing: &span, endianness: .little)
            }
        }
    }
}

struct LC_ROUTINES_64_Tests {

    let allFieldsData = Data([
        0x1A, 0x00, 0x00, 0x00, // cmd = LC_ROUTINES_64 (0x1A)
        0x48, 0x00, 0x00, 0x00, // cmdsize = 72
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // initAddress
        0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // initModule
        0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // reserved1
        0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // reserved2
        0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // reserved3
        0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // reserved4
        0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // reserved5
        0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // reserved6
    ])

    @Test
    func LC_ROUTINES_64_AllFields() throws {
        try allFieldsData.withParserSpan { span in
            let f = try SwiftMachO.LC_ROUTINES_64(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_ROUTINES_64)
            #expect(f.header.cmdSize == 72)
            #expect(f.initAddress == 1)
            #expect(f.initModule == 2)
            #expect(f.reserved1 == 3)
            #expect(f.reserved2 == 4)
            #expect(f.reserved3 == 5)
            #expect(f.reserved4 == 6)
            #expect(f.reserved5 == 7)
            #expect(f.reserved6 == 8)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_ROUTINES_64_Zeroed() throws {
        var zeroedData = Data(repeating: 0, count: 72)
        zeroedData[0] = 0x1A
        zeroedData[4] = 0x48

        try zeroedData.withParserSpan { span in
            let f = try SwiftMachO.LC_ROUTINES_64(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_ROUTINES_64)
            #expect(f.header.cmdSize == 72)
            #expect(f.initAddress == 0)
            #expect(f.initModule == 0)
            #expect(f.reserved1 == 0)
            #expect(f.reserved2 == 0)
            #expect(f.reserved3 == 0)
            #expect(f.reserved4 == 0)
            #expect(f.reserved5 == 0)
            #expect(f.reserved6 == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_ROUTINES_64_InvalidCommand() throws {
        let bad = Data([0x50, 0x00, 0x00, 0x00, 0x48, 0x00, 0x00, 0x00])
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_ROUTINES_64(parsing: &span, endianness: .little)
            }
        }
    }
}
