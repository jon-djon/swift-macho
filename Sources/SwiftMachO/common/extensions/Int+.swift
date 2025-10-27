//
//  Int+.swift
//  swift-macho
//
//  Created by jon on 9/29/25.
//

extension Int {
    public var hexDescription: String {
        String(format: "%08x", self)
    }
    
    public func align(_ align: Int) -> Int {
        return ((self + align-1) & -align)
    }
}
