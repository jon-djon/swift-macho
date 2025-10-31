//
//  LC_LINKER_OPTIMIZATION_HINT.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_LINKER_OPTIMIZATION_HINT: LoadCommand, LoadCommandLinkEdit {
    public let header: LoadCommandHeader
    public let offset: UInt32
    public let size: UInt32
    
    public let range: Range<Int>
}

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

extension LC_LINKER_OPTIMIZATION_HINT {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_LINKER_OPTIMIZATION_HINT else {
            throw MachOError.LoadCommandError("Invalid LC_LINKER_OPTIMIZATION_HINT")
        }
        self.offset = try UInt32(parsing: &input, endianness: .little)
        self.size = try UInt32(parsing: &input, endianness: .little)
    }
}




extension LC_LINKER_OPTIMIZATION_HINT: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Offset", stringValue: offset.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: size.description, offset: 12, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
