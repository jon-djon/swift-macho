//
//  DisplayableField.swift
//  swift-macho
//
//  Created by jon on 10/15/25.
//

import Foundation

public struct DisplayableField: Identifiable {
    public let id: UUID = UUID()
    public let label: String
    public let stringValue: String
    public let offset: Int
    public let size: Int
    public let isAbsoluteOffset: Bool = false
    public let children: [DisplayableField]?
    
    public let obj: Parseable?
    
    public var absoluteOffset: Int {
        guard let obj = self.obj else { return 0 }
        
        if isAbsoluteOffset {
            return offset
        } else {
            return obj.range.lowerBound + offset
        }
    }
    
    public var range: Range<Int> {
        absoluteOffset..<absoluteOffset + size
    }
}


