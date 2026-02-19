//
//  LC_DYSYMTAB.swift
//  swift-macho
//
//  Created by jon on 2/16/26.
//

import Foundation
import Testing
import BinaryParsing
@testable import SwiftMachO

struct LC_DYSYMTAB_Tests {

    let allFieldsData = Data([
        0x0B, 0x00, 0x00, 0x00, // cmd = LC_DYSYMTAB
        0x50, 0x00, 0x00, 0x00, // cmdsize = 80
        0x01, 0x00, 0x00, 0x00, // localSymbolIndex
        0x02, 0x00, 0x00, 0x00, // numLocalSymbols
        0x03, 0x00, 0x00, 0x00, // externalSymbolIndex
        0x04, 0x00, 0x00, 0x00, // numExternalSymbols
        0x05, 0x00, 0x00, 0x00, // undefinedSymbolIndex
        0x06, 0x00, 0x00, 0x00, // numUndefinedSymbols
        0x07, 0x00, 0x00, 0x00, // tocOffset
        0x08, 0x00, 0x00, 0x00, // numToc
        0x09, 0x00, 0x00, 0x00, // moduleTableOffset
        0x0A, 0x00, 0x00, 0x00, // numModuleTable
        0x0B, 0x00, 0x00, 0x00, // externalReferenceSymbolOffset
        0x0C, 0x00, 0x00, 0x00, // numExternalReferenceSymbols
        0x0D, 0x00, 0x00, 0x00, // indirectSymbolOffset
        0x0E, 0x00, 0x00, 0x00, // numIndirectSymbols
        0x0F, 0x00, 0x00, 0x00, // externalRelocationOffset
        0x10, 0x00, 0x00, 0x00, // numExternalRelocations
        0x11, 0x00, 0x00, 0x00, // localRelocationOffset
        0x12, 0x00, 0x00, 0x00, // numLocalRelocations
    ])
    
    let zeroedData = Data(repeating: 0, count: 80)

    @Test
    func LC_DYSYMTAB_AllFields() throws {
        try allFieldsData.withParserSpan { span in
            let f = try SwiftMachO.LC_DYSYMTAB(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_DYSYMTAB)
            #expect(f.header.cmdSize == 80)
            #expect(f.localSymbolIndex == 1)
            #expect(f.numLocalSymbols == 2)
            #expect(f.externalSymbolIndex == 3)
            #expect(f.numExternalSymbols == 4)
            #expect(f.undefinedSymbolIndex == 5)
            #expect(f.numUndefinedSymbols == 6)
            #expect(f.tocOffset == 7)
            #expect(f.numToc == 8)
            #expect(f.moduleTableOffset == 9)
            #expect(f.numModuleTable == 10)
            #expect(f.externalReferenceSymbolOffset == 11)
            #expect(f.numExternalReferenceSymbols == 12)
            #expect(f.indirectSymbolOffset == 13)
            #expect(f.numIndirectSymbols == 14)
            #expect(f.externalRelocationOffset == 15)
            #expect(f.numExternalRelocations == 16)
            #expect(f.localRelocationOffset == 17)
            #expect(f.numLocalRelocations == 18)
            #expect(span.count == 0)
        }
    }
    
    @Test
    func LC_DYSYMTAB_Zeroed() throws {
        // We need to set the cmd and cmdsize manually for the zeroed data
        var mutableZeroedData = zeroedData
        mutableZeroedData[0] = 0x0B
        mutableZeroedData[4] = 0x50

        try mutableZeroedData.withParserSpan { span in
            let f = try SwiftMachO.LC_DYSYMTAB(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_DYSYMTAB)
            #expect(f.header.cmdSize == 80)
            #expect(f.localSymbolIndex == 0)
            #expect(f.numLocalSymbols == 0)
            #expect(f.externalSymbolIndex == 0)
            #expect(f.numExternalSymbols == 0)
            #expect(f.undefinedSymbolIndex == 0)
            #expect(f.numUndefinedSymbols == 0)
            #expect(f.tocOffset == 0)
            #expect(f.numToc == 0)
            #expect(f.moduleTableOffset == 0)
            #expect(f.numModuleTable == 0)
            #expect(f.externalReferenceSymbolOffset == 0)
            #expect(f.numExternalReferenceSymbols == 0)
            #expect(f.indirectSymbolOffset == 0)
            #expect(f.numIndirectSymbols == 0)
            #expect(f.externalRelocationOffset == 0)
            #expect(f.numExternalRelocations == 0)
            #expect(f.localRelocationOffset == 0)
            #expect(f.numLocalRelocations == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func LC_DYSYMTAB_InvalidCommand() throws {
        let bad = Data([0x50, 0x00, 0x00, 0x00, 0x50, 0x00, 0x00, 0x00])
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_DYSYMTAB(parsing: &span, endianness: .little)
            }
        }
    }
}
