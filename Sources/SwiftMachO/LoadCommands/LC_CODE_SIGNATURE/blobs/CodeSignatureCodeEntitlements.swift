//
//  CodeEntitlements.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//
import Foundation
import BinaryParsing


public struct CodeSignatureCodeEntitlements: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    public let entitlements: [String:Any]
    
    public let range: Range<Int>
    
    public var description: String {
        "CodeSignatureCodeEntitlements (\(keys.joined(separator: ",")))"
    }
    
    public var keys: [String] {
        Array(entitlements.keys)
    }
}


extension CodeSignatureCodeEntitlements {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .CodeEntitlements else {
            throw MachOError.badMagicValue("CodeSignatureCodeEntitlements unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        let data = try Data(parsing: &input, byteCount: Int(self.length))
        
        guard
            let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil),
            let entitlements = plist as? [String: AnyObject]
        else { throw MachOError.parsingError("MachOSignatureValue.CodeEntitlementsValue") }
        
        self.entitlements = entitlements
        self.range = start..<start+Int(self.length)
    }
}

extension CodeSignatureCodeEntitlements: Displayable {
    public var title: String {
        "CodeSignatureCodeEntitlements"
    }
    
    public var children: [any Displayable]? {
        []
    }
}
