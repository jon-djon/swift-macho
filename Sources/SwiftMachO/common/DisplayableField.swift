//
//  DisplayableField.swift
//  swift-macho
//
//  Created by jon on 10/15/25.
//

import Foundation

public struct DisplayableFieldBuilder {
    private var offset: Int = 0
    private var fields: [DisplayableField] = []
    private let obj: Parseable

    public init(obj: Parseable) {
        self.obj = obj
    }

    @discardableResult
    public mutating func add(
        label: String,
        stringValue: String,
        size: Int,
        children: [DisplayableField]? = nil
    ) -> Self {
        fields.append(.init(
            label: label,
            stringValue: stringValue,
            offset: offset,
            size: size,
            children: children,
            obj: obj
        ))
        offset += size
        return self
    }

    @discardableResult
    public mutating func add(
        label: String,
        stringValue: String,
        offset: Int,
        size: Int,
        children: [DisplayableField]? = nil
    ) -> Self {
        fields.append(.init(
            label: label,
            stringValue: stringValue,
            offset: offset,
            size: size,
            children: children,
            obj: obj
        ))
        self.offset = offset + size
        return self
    }

    public func build() -> [DisplayableField] { fields }
}

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


