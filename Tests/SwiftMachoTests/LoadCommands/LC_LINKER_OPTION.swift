//
//  LC_LINKER_OPTION.swift
//  swift-macho
//
//  Created by jon on 10/30/25.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_LINKER_OPTION_Tests {
    let data = Data([45,0,0,0,24,0,0,0,1,0,0,0,45,108,115,119,105,102,116,67,111,114,101,0,])
    
    let bad = Data([50,0,0,0,40,0,0,0,])
    
    @Test
    func LC_LINKER_OPTION() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_LINKER_OPTION(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_LINKER_OPTION)
            #expect(f.header.cmdSize == 24)
            #expect(f.count == 1)
            #expect(f.options[0] == (12,"-lswiftCore"))
        }
        
        _ = bad.withParserSpan { span in
            #expect(throws: SwiftMachO.MachOError.self) {
                _ = try SwiftMachO.LC_LINKER_OPTION(parsing: &span, endianness: .little)
            }
        }
    }
}
