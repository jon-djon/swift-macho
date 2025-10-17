//
//  LC_LOAD_WEAK_DYLIB.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_LOAD_WEAK_DYLIB: LoadCommand {
    public let header: LoadCommandHeader
    public let range: Range<Int>
    public let strOffset: UInt32
    public let timestamp: UInt32
    public let currentVersion: SemanticVersion
    public let compatibilityVersion: SemanticVersion
    public let name: String
    
    public var nameOffset: Int { self.range.lowerBound+Int(self.strOffset) }
}

extension LC_LOAD_WEAK_DYLIB {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_LOAD_WEAK_DYLIB else {
            throw MachOError.LoadCommandError("Invalid LC_LOAD_WEAK_DYLIB")
        }
        
        self.strOffset = try UInt32(parsing: &input, endianness: endianness)
        self.timestamp = try UInt32(parsing: &input, endianness: endianness)
        
        var span = try input.sliceSpan(byteCount: 4)
        self.currentVersion = try SemanticVersion(parsing: &span, endianness: endianness)
        
        span = try input.sliceSpan(byteCount: 4)
        self.compatibilityVersion = try SemanticVersion(parsing: &span, endianness: endianness)
        
        try input.seek(toAbsoluteOffset: self.range.lowerBound)
        try input.seek(toRelativeOffset: self.strOffset)
        self.name = try String(parsingNulTerminated: &input)
    }
}

extension LC_LOAD_WEAK_DYLIB: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Name Offset", stringValue: strOffset.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Timestamp", stringValue: timestamp.description, offset: 12, size: 4, children: nil, obj: self),
            .init(label: "Current Version", stringValue: currentVersion.description, offset: 16, size: 4, children: nil, obj: self),
            .init(label: "Compatibility Version", stringValue: compatibilityVersion.description, offset: 20, size: 4, children: nil, obj: self),
            .init(label: "Name", stringValue: name, offset: Int(strOffset), size: name.count, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
