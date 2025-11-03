//
//  EntitlementRoot.swift
//  swift-macho
//
//  Created by jon on 10/31/25.
//

import SwiftASN1

public struct EntitlementRoot: DERParseable {
    public let version: Int
    public let dictionary: EntitlementDictionary
    
    public init(derEncoded: ASN1Node) throws {
        let result = try DER.sequence(derEncoded, identifier: ASN1Identifier(tagWithNumber: 16, tagClass: .application)) { nodes in
            let version = try Int(derEncoded: &nodes)
            let dictionary = try EntitlementDictionary(derEncoded: &nodes)
            return (version, dictionary)
        }
        self.version = result.0
        self.dictionary = result.1
    }
}


extension EntitlementRoot {
    public var fields: [DisplayableField] {
        [
            .init(label: "Version", stringValue: version.description, offset: 8, size: 0, children: nil, obj: nil),
            .init(label: "Values", stringValue: "\(dictionary.pairs.count)", offset: 8,size: 0, children: dictionary.pairs.map {
                .init(label: $0.key.stringValue, stringValue:$0.value.stringValue, offset: 8, size: 0, children: nil, obj: nil)
            }, obj: nil)
        ]
    }
}
