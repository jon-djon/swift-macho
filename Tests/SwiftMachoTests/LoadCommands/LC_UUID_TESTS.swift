//
//  LC_UUID_TESTS.swift
//  swift-macho
//
//  Created by jon on 10/28/25.
//



import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_UUID_Tests {
    let data = Data([27,0,0,0,24,0,0,0,214,122,178,59,33,6,62,31,152,35,197,229,117,157,133,164,])
    
    let bad = Data([50,0,0,0,40,0,0,0,])
    
    @Test
    func LC_UUID() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_UUID(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_UUID)
            #expect(f.header.cmdSize == 24)
            #expect(f.range == 0..<Int(f.header.cmdSize))
            #expect(f.uuid.description == "D67AB23B-2106-3E1F-9823-C5E5759D85A4")
            #expect(span.count == 0)
        }
        
        _ = data.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_UUID(parsing: &span, endianness: .big)
            }
        }
        
        _ = bad.withParserSpan { span in
            #expect(throws: SwiftMachO.MachOError.self) {
                _ = try SwiftMachO.LC_UUID(parsing: &span, endianness: .little)
            }
        }
    }
}
