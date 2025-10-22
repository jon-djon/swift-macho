//
//  LC_FUNCTION_STARTS.swift
//  swift-macho
//
//  Created by jon on 9/29/25.
//

import Foundation
import BinaryParsing

public struct LC_FUNCTION_STARTS: LoadCommand, LoadCommandLinkEdit {
    public let range: Range<Int>
    public let header: LoadCommandHeader
    public let offset: UInt32
    public let size: UInt32
    
    // Deferred parsing
    public var starts: FunctionStarts? = nil
}

extension LC_FUNCTION_STARTS {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_FUNCTION_STARTS else {
            throw MachOError.LoadCommandError("Invalid LC_FUNCTION_STARTS")
        }
        self.offset = try UInt32(parsingLittleEndian: &input)
        self.size = try UInt32(parsingLittleEndian: &input)
    }
}

public struct FunctionStarts: Parseable {
    public let range: Range<Int>
    public let starts: [Int]
    
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        var starts: [Int] = []
        while !input.isEmpty {
            starts.append(try Int(parsingLEB128: &input))
        }
        self.starts = starts
    }
}


extension LC_FUNCTION_STARTS: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Offset", stringValue: offset.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: size.description, offset: 12, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
