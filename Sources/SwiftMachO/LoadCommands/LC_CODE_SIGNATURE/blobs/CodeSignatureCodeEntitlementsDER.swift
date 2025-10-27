//
//  CodeEntitlementsDER.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing


public struct CodeSignatureCodeEntitlementsDER: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    public let der: Data
    
    public let range: Range<Int>
    
    public var description: String {
        "CodeSignatureCodeEntitlementsDER \(der.count) der bytes"
    }
}

extension CodeSignatureCodeEntitlementsDER {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .CodeEntitlementsDER else {
            throw MachOError.badMagicValue("CodeSignatureCodeEntitlementsDER unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.der = try Data(parsing: &input, byteCount: Int(self.length))
        self.range = start..<start+Int(self.length)
    }
}

extension CodeSignatureCodeEntitlementsDER: Displayable {
    public var title: String {
        "CodeSignatureCodeEntitlementsDER"
    }
    
    public var children: [any Displayable]? {
        []
    }
}
