//
//  EntitlementDictionary.swift
//  swift-macho
//
//  Created by jon on 10/31/25.
//

import SwiftASN1


public struct EntitlementDictionary: DERParseable {
    public let pairs: [EntitlementKeyValuePair]
    
    public init(derEncoded: ASN1Node) throws {
        pairs = try DER.sequence(of: EntitlementKeyValuePair.self, identifier: ASN1Identifier(tagWithNumber: 16, tagClass: .contextSpecific), rootNode: derEncoded)
    }
}

extension EntitlementDictionary {
    public var stringValue: String {
        let keyValueStrings = pairs.map(\.stringValue)
        return keyValueStrings.joined(separator: ",")
    }
}
