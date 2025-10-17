//
//  LC_DYLD_ENVIRONMENT.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_DYLD_ENVIRONMENT: LoadCommand {
    public let header: LoadCommandHeader
    public let range: Range<Int>
    
    public let strOffset: UInt32
    public let name: String
    
    public var nameOffset: Int { self.range.lowerBound+Int(self.strOffset) }
}

extension LC_DYLD_ENVIRONMENT {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_DYLD_ENVIRONMENT else {
            throw MachOError.LoadCommandError("Invalid LC_DYLD_ENVIRONMENT")
        }
        
        self.strOffset = try UInt32(parsing: &input, endianness: endianness)
        
        try input.seek(toAbsoluteOffset: self.range.lowerBound+Int(self.strOffset))
        var span = input.extractRemaining()
        self.name = String(parsingUTF8: &span)
    }
}

extension LC_DYLD_ENVIRONMENT: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Name Offset", stringValue: strOffset.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Name", stringValue: name, offset: Int(strOffset), size: name.count, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
