//
//  CodeEntitlementsDER.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing
import SwiftASN1

public struct CodeSignatureCodeEntitlementsDER: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    public let entitlements: EntitlementRoot
    
    public let range: Range<Int>
    
    public var description: String {
        "CodeSignatureCodeEntitlementsDER"
    }
    
    public var keys: [String] {
        entitlements.dictionary.pairs.map { $0.key.stringValue }
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
        self.range = start..<start+Int(self.length)
        
        let data = try Data(parsing: &input, byteCount: Int(self.length)-8)
        self.entitlements = try EntitlementRoot(derEncoded: try DER.parse([UInt8](data)))
    }
}

extension CodeSignatureCodeEntitlementsDER: Displayable {
    public var title: String {
        "CodeSignatureCodeEntitlementsDER"
    }
    
    public var fields: [DisplayableField] {
        [
            .init(label: "Magic", stringValue: magic.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Length", stringValue: length.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Entitlements", stringValue: "", offset: 8, size: Int(self.length)-8, children: entitlements.fields, obj: self),
        ]
    }
    
    public var children: [any Displayable]? {
        []
    }
}
