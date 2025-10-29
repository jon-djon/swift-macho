//
//  UInt64+.swift
//  swift-macho
//
//  Created by jon on 10/29/25.
//

extension UInt64 {
    public var hexDescription: String {
        String(format: "%016x", self)
    }
}
