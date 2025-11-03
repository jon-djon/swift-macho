//
//  ASN1UTF8String+.swift
//  swift-macho
//
//  Created by jon on 10/31/25.
//

import SwiftASN1


extension ASN1UTF8String {
    public var stringValue: String {
        String(bytes: self.bytes, encoding: .utf8) ?? "<unprintable>"
    }
}


