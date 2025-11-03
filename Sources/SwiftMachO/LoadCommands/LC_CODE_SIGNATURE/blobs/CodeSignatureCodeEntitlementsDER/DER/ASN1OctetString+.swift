//
//  ASN1OctetString+.swift
//  swift-macho
//
//  Created by jon on 10/31/25.
//

import SwiftASN1


extension ASN1OctetString {
    public var stringValue: String {
        "\(self.bytes.count) bytes"
    }
}
