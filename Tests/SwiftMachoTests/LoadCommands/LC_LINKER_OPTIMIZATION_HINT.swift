//
//  LC_LINKER_OPTIMIZATION_HINT.swift
//  swift-macho
//
//  Created by jon on 10/30/25.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_LINKER_OPTIMIZATION_HINT_Tests {
    let cmdData = Data(Data(Data([46,0,0,0,16,0,0,0,184,93,1,0,40,0,0,0,])))
    
    let le = Data([8,2,224,33,228,33,8,2,212,34,216,34,8,2,140,35,144,35,8,2,236,35,240,35,8,2,184,56,188,56,8,2,232,152,1,236,152,1,0,0,])
    
    let badCmd = Data([50,0,0,0,40,0,0,0,])
    
    @Test
    func LC_LINKER_OPTIMIZATION_HINT() throws {
        try cmdData.withParserSpan { span in
            let f = try SwiftMachO.LC_LINKER_OPTIMIZATION_HINT(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_LINKER_OPTIMIZATION_HINT)
            #expect(f.header.cmdSize == 24)
        }
        
        _ = badCmd.withParserSpan { span in
            #expect(throws: SwiftMachO.MachOError.self) {
                _ = try SwiftMachO.LC_LINKER_OPTIMIZATION_HINT(parsing: &span, endianness: .little)
            }
        }
    }
    
    @Test
    func LinkerOptimizationHint() throws {
        try cmdData.withParserSpan { span in
            let f = try SwiftMachO.LinkerOptimizationHint(parsing: &span, endianness: .little)
        }
    }
}
