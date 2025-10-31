//
//  CodeSignatureLaunchConstraint.swift
//  swift-macho
//
//  Created by jon on 10/30/25.
//
import Foundation
import BinaryParsing
import SwiftASN1

struct EntitlementKeyValuePair: DERParseable {
//    let key: String
//    let value: EntitlementValue
    
    let key: ASN1Any
    let value: ASN1Any
    
    init(derEncoded: ASN1Node) throws {
        let result = try DER.sequence(derEncoded, identifier: ASN1Identifier(tagWithNumber: 12, tagClass: .universal)) { nodes in
            let key = try ASN1Any(derEncoded: &nodes)
            let value = try ASN1Any(derEncoded: &nodes)
//            let valueNode = try DER.decodeItem(&nodes)
//            let value = try EntitlementValue(derEncoded: valueNode)
            
            return (key, value)
        }
        
        self.key = result.0
        self.value = result.1
    }
}
   

struct EntitlementDictionary: DERParseable {
    let pairs: [EntitlementKeyValuePair]
    
    init(derEncoded node: ASN1Node) throws {
        // Parse as a SEQUENCE OF EntitlementKeyValuePair
        self.pairs = try DER.sequence(of: EntitlementKeyValuePair.self, identifier: .sequence, rootNode: node)
    }
}

struct EntitlementRoot: DERParseable {
    let version: Int
    let dictionary: [EntitlementDictionary]
    // let dictionary: EntitlementDictionary
    
    init(derEncoded: ASN1Node) throws {
        let result = try DER.sequence(derEncoded, identifier: Entitlements.applicationTag) { nodes in
            let version = try Int(derEncoded: &nodes)
            
            let dictionary = try DER.sequence(of: EntitlementDictionary.self, identifier: ASN1Identifier(tagWithNumber: 16, tagClass: .contextSpecific), nodes: &nodes)
        
            
            
//            let dictionary = DER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in
//                ASN1Any(derEncoded: node)
//            }
//            DER.decodeDefaultExplicitlyTagged(&<#T##ASN1NodeCollection.Iterator#>, tagNumber: <#T##UInt#>, tagClass: <#T##ASN1Identifier.TagClass#>, defaultValue: <#T##T#>)
//            let dictionary = try DER.decodeDefault(&nodes, defaultValue: nil)
            
//            let dictionary = try DER.explicitlyTagged(&nodes, tagNumber: 16, tagClass: .contextSpecific) { node in
//                ASN1Any(derEncoded: node)
//            }
//            
//            // Dictionary with context tag [16] IMPLICIT
//            let dictNode = try DER.decodeItem(&nodes)
//            guard dictNode.identifier == ASN1Identifier(tagWithNumber: 16, tagClass: .contextSpecific) else {
//                throw ASN1Error.unexpectedFieldType(dictNode.identifier)
//            }
//            let dictionary = try EntitlementDictionary(derEncoded: dictNode)
            
            return (version, dictionary)
        }
        
        self.version = result.0
        self.dictionary = result.1
    }
}

struct Entitlements: DERParseable {
    static let applicationTag = ASN1Identifier(tagWithNumber: 16, tagClass: .application)
    
    let root: EntitlementRoot
    
    init(derEncoded: ASN1Node) throws {
        // Check for APPLICATION 16 tag
        guard derEncoded.identifier == Self.applicationTag else {
            throw ASN1Error.unexpectedFieldType(derEncoded.identifier)
        }
        
        // The content is IMPLICIT, so parse directly as EntitlementRoot
        self.root = try EntitlementRoot(derEncoded: derEncoded)
    }
}


public struct CodeSignatureLaunchConstraint: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    public let der: Data
    
    public let range: Range<Int>
    
    public var description: String {
        "CodeSignatureLaunchConstraint \(length.description) bytes"
    }
}

extension CodeSignatureLaunchConstraint {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .LaunchConstraint else {
            throw MachOError.badMagicValue("CodeSignatureLaunchConstraint unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.der = try Data(parsing: &input, byteCount: Int(self.length)-8)
        self.range = start..<start+Int(length)
    }
}

extension CodeSignatureLaunchConstraint: Displayable {
    public var title: String {
        "CodeSignatureLaunchConstraint"
    }
    
    public var children: [any Displayable]? {
        []
    }
}
