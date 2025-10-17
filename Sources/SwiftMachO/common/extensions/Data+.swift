//
//  Data+.swift
//  swift-macho
//
//  Created by jon on 10/15/25.
//

import Foundation
import CryptoKit

extension Data {
    public var hexDescription: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    public var swiftDataString: String {
        // Data([65, 66, 68, 67])
        return "Data([" + reduce("") {$0 + "\($1),"} + "])"
    }
    
    public func hexString(in range: Range<Int>) -> String {
        let subdata = self[range]
        return subdata.map { String(format: "%02x", $0) }.joined()
    }
}

extension Data {
    public var sha256: String {
        let hashed = SHA256.hash(data: self)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    public var sha1: String {
        let hashed = Insecure.SHA1.hash(data: self)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    public var sha384: String {
        let hashed = SHA384.hash(data: self)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    public var sha512: String {
        let hashed = SHA512.hash(data: self)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
