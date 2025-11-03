//
//  CertificateMatch.swift
//  swift-macho
//
//  Created by jon on 10/24/25.
//
import Foundation
import BinaryParsing
import SwiftASN1

public struct CertificateMatch: Parseable {
    public let slot: Int32
    public let size: UInt32
    public let fieldData: Data
    public let match: MatchExprSingle
    
    public let range: Range<Int>
    
    public var slotString: String {
        if slot == 0 {
            "leaf"
        } else if slot == -1 {
            "anchor"
        } else {
            slot.description
        }
    }
    
    public var fieldString: String {
        String(decoding: fieldData, as: Unicode.UTF8.self)
    }
    
    public var fieldOID: ASN1ObjectIdentifier? {
        var d: Data = fieldData
        d.insert(UInt8(d.count), at: 0) // Length
        d.insert(UInt8(ASN1Identifier.objectIdentifier.tagNumber), at: 0)
        
        guard
            let node = try? DER.parse(d.map { $0 }),
            let oid = try? ASN1ObjectIdentifier(derEncoded: node, withIdentifier: .objectIdentifier)
        else { return nil }
        
        return oid
    }
}

extension CertificateMatch {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        
        self.slot = try Int32(parsing: &input, endianness :.big)
        self.size = try UInt32(parsing: &input, endianness: .big)
        
        // The type of data here depends on the op
        // opCertField == fieldString
        // opCertGeneric == fieldOID
        // opCertPolicy ?
        // opCertDate ?
        self.fieldData = try Data(parsing: &input, byteCount: Int(self.size))
        
        // Offsets are 4 byte aligned, so may need to skip ahead a bit
        let skip = Int(self.size).align(4) - Int(self.size)
        if skip > 0 {
            try input.seek(toRelativeOffset: skip)
        }
        
        self.match = try MatchExprSingle(parsing: &input)
        
    }
}

extension CertificateMatch: CustomStringConvertible {
    public var description: String {
        "CertificateMatch(\(slotString) \(fieldString), \(match))"
    }
}
