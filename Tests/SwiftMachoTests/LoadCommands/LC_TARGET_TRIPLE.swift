//
//  LC_TARGET_TRIPLE.swift
//  swift-macho
//
//  Created by jon on 2/16/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_TARGET_TRIPLE_Tests {

    func generateTestData(with triple: String) -> Data {
        var tripleData = triple.data(using: .utf8)!
        tripleData.append(0) // Null terminator

        // Align to 4-byte boundary
        let remainder = tripleData.count % 4
        if remainder != 0 {
            tripleData.append(Data(count: 4 - remainder))
        }

        var data = Data()
        let cmdsize = UInt32(8 + tripleData.count)
        data.append(contentsOf: [0x39, 0x00, 0x00, 0x00]) // cmd = LC_TARGET_TRIPLE
        
        // Append cmdsize as little-endian
        withUnsafeBytes(of: cmdsize.littleEndian) {
            data.append(contentsOf: $0)
        }
        
        data.append(tripleData)
        
        return data
    }
    
    @Test
    func LC_TARGET_TRIPLE_Valid() throws {
        let triple = "arm64-apple-macosx14.0"
        let data = generateTestData(with: triple)
        
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_TARGET_TRIPLE(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_TARGET_TRIPLE)
            #expect(f.triple == triple)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_TARGET_TRIPLE_InvalidCommand() throws {
        let bad = Data([0x50, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00])
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_TARGET_TRIPLE(parsing: &span, endianness: .little)
            }
        }
    }
}
