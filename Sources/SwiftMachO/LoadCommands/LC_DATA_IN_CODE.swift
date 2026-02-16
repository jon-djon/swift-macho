//
//  LC_DATA_IN_CODE.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_DATA_IN_CODE: LoadCommand {
    public let header: LoadCommandHeader
    public let range: Range<Int>
    
    public let offset: UInt32
    public let size: UInt32
}


public struct DataInCode {
    public let offset: UInt32
    public let length: UInt16
    public let kind: Kind
    
    public let range: Range<Int>
    
    public static let size: Int = 8
    
    @CaseName
    public enum Kind: UInt16 {
        case data = 1
        case jumpTable8 = 2
        case jumpTable16 = 3
        case jumpTable32 = 4
        case absJumpTable32 = 5
    }
}

extension DataInCode: Parseable {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.length = try UInt16(parsing: &input, endianness: endianness)
        self.kind = try Kind(parsing: &input, endianness: endianness)
    }
}

extension DataInCode: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "The **LC_DATA_IN_CODE** command is a MachO load command that specifies the location and size of the Data-in-Code Table within the binary. The primary purpose of the LC_DATA_IN_CODE command is to identify specific sequences of bytes within the executable's code sections that are not intended to be executed as machine instructions but are instead treated as data." }
    public var fields: [DisplayableField] {
        [
            .init(label: "Offset", stringValue: offset.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Length", stringValue: length.description, offset: 4, size: 2, children: nil, obj: self),
            .init(label: "Kind", stringValue: kind.description, offset: 6, size: 2, children: nil, obj: self),
        ]
        
    }
    public var children: [Displayable]? { nil }
}

extension LC_DATA_IN_CODE {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_DATA_IN_CODE else {
            throw MachOError.LoadCommandError("Invalid LC_DATA_IN_CODE")
        }
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_DATA_IN_CODE: Displayable {
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
