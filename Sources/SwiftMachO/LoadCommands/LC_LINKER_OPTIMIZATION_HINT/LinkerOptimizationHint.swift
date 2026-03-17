//
//  LinkerOptimizationHint.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LinkerOptimizationHint: Parseable {
    // TODO: Not sure if this is correct or not????
    public let kind: Kind

    public let range: Range<Int>

    @CaseName
    public enum Kind: UInt32 {
        case LOH_ARM64_ADRP_ADRP = 1
        case LOH_ARM64_ADRP_LDR = 2
        case LOH_ARM64_ADRP_ADD_LDR = 3
        case LOH_ARM64_ADRP_LDR_GOT_LDR = 4
        case LOH_ARM64_ADRP_ADD_STR = 5
        case LOH_ARM64_ADRP_LDR_GOT_STR = 6
        case LOH_ARM64_ADRP_ADD = 7
        case LOH_ARM64_ADRP_LDR_GOT = 8
    }
}

extension LinkerOptimizationHint {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.kind = try LinkerOptimizationHint.Kind(parsing: &input, endianness: .little )
    }
}
