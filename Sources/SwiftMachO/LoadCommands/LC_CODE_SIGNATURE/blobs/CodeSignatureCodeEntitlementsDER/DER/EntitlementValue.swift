//
//  EntitlementValue.swift
//  swift-macho
//
//  Created by jon on 10/31/25.
//

import SwiftASN1


public enum EntitlementValue: DERParseable {
    case boolean(Bool)  // BOOLEAN
    case data(ASN1OctetString)  // OCTET STRING
    case dateTime(GeneralizedTime)  // GeneralizedTime
    case array([EntitlementValue])
    case string(ASN1UTF8String)  // UTF8String
    case numeric(Int)  // INTEGER
    case dictionary(EntitlementDictionary)
    case node(ASN1Node)
    
    public init(derEncoded node: ASN1Node) throws {
        switch node.identifier {
        case ASN1Identifier.octetString:
            self = .data(try ASN1OctetString(derEncoded: node))
        case ASN1Identifier.sequence:
            self = .array(try DER.sequence(of: EntitlementValue.self, identifier: .sequence, rootNode: node))
        case ASN1Identifier.boolean:
            self = .boolean(try Bool(derEncoded: node))
        case ASN1Identifier.utf8String:
            self = .string(try ASN1UTF8String(derEncoded: node, withIdentifier: .utf8String))
        case ASN1Identifier.generalizedTime:
            self = .dateTime(try GeneralizedTime(derEncoded: node))
        case ASN1Identifier.integer:
            self = .numeric(try Int(derEncoded: node))
        case ASN1Identifier(tagWithNumber: 16, tagClass: .contextSpecific):
            self = .dictionary(try EntitlementDictionary(derEncoded: node))
        default:
            self = .node(node)
        }
    }
}

extension EntitlementValue {
    public var stringValue: String {
        switch self {
        case .data(let data): data.stringValue
        case .array(let values): values.map(\.stringValue).joined(separator: ", ")
        case .boolean(let bool):bool.description
        case .string(let str):str.stringValue
        case .dateTime(let dateTime):dateTime.stringValue
        case .numeric(let i): i.description
        case .dictionary(let e): e.stringValue
        case .node(let node): node.identifier.description
        }
    }
}
