//
//  LC_CODE_SIGNATURE.swift
//  swift-macho
//
//  Created by jon on 10/30/25.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_CODE_SIGNATURE_Tests {
    let launchConstraint = Data([250,222,129,129,0,0,0,150,112,129,139,2,1,1,176,129,133,48,9,12,4,99,99,97,116,2,1,0,48,9,12,4,99,111,109,112,2,1,1,48,98,12,4,114,101,113,115,176,90,48,16,12,11,108,97,117,110,99,104,45,116,121,112,101,2,1,2,48,44,12,18,115,105,103,110,105,110,103,45,105,100,101,110,116,105,102,105,101,114,12,22,99,111,109,46,97,112,112,108,101,46,115,121,115,100,105,97,103,110,111,115,101,100,48,24,12,19,118,97,108,105,100,97,116,105,111,110,45,99,97,116,101,103,111,114,121,2,1,1,48,9,12,4,118,101,114,115,2,1,1,])
    
    let bad = Data([50,0,0,0,40,0,0,0,])
    
    @Test
    func CodeSignatureLaunchConstraint() throws {
        try launchConstraint.withParserSpan { span in
            let f = try SwiftMachO.CodeSignatureLaunchConstraint(parsing: &span)
            #expect(f.magic == .LaunchConstraint)
        }
        
        _ = bad.withParserSpan { span in
            #expect(throws: MachOError.self) {
                _ = try SwiftMachO.LC_LINKER_OPTION(parsing: &span, endianness: .little)
            }
        }
    }
}
