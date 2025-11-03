//
//  EntitlementKeyValuePair.swift
//  swift-macho
//
//  Created by jon on 10/31/25.
//

import SwiftASN1


public struct EntitlementKeyValuePair: DERParseable {
    public let key: ASN1UTF8String
    public let value: EntitlementValue
    
    public init(derEncoded: ASN1Node) throws {
        let result = try DER.sequence(derEncoded, identifier: ASN1Identifier(tagWithNumber: 16, tagClass: .universal)) { nodes in
            let key = try ASN1UTF8String(derEncoded: &nodes, withIdentifier: .utf8String)
            let value = try EntitlementValue(derEncoded: &nodes)
            return (key, value)
        }
        
        self.key = result.0
        self.value = result.1
    }
}

extension EntitlementKeyValuePair {
    public var stringValue: String {
        "\(key.stringValue): \(value.stringValue)"
    }
}
