//
//  main.swift
//  launch
//
//  Created by jon on 10/30/25.
//

import Foundation
import SwiftASN1

let launchConstraint = Data([112,129,139,2,1,1,176,129,133,48,9,12,4,99,99,97,116,2,1,0,48,9,12,4,99,111,109,112,2,1,1,48,98,12,4,114,101,113,115,176,90,48,16,12,11,108,97,117,110,99,104,45,116,121,112,101,2,1,2,48,44,12,18,115,105,103,110,105,110,103,45,105,100,101,110,116,105,102,105,101,114,12,22,99,111,109,46,97,112,112,108,101,46,115,121,115,100,105,97,103,110,111,115,101,100,48,24,12,19,118,97,108,105,100,97,116,105,111,110,45,99,97,116,101,103,111,114,121,2,1,1,48,9,12,4,118,101,114,115,2,1,1,])


let applicationTag = ASN1Identifier(tagWithNumber: 16, tagClass: .application)
let rootNode = try DER.parse([UInt8](launchConstraint))
guard rootNode.identifier == applicationTag else {
    throw ASN1Error.unexpectedFieldType(rootNode.identifier)
}
try DER.sequence(rootNode, identifier: applicationTag) { nodes in
    let version = try Int(derEncoded: &nodes)
    print(version)
    print("here")
    
//    let dictionary = try DER.sequence(of: EntitlementDictionary.self, identifier: ASN1Identifier(tagWithNumber: 16, tagClass: .contextSpecific), nodes: &nodes)
}

