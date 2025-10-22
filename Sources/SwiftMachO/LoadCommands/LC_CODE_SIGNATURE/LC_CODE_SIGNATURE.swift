//
//  LC_CODE_SIGNATURE.swift
//  swift-macho
//
//  Created by jon on 9/29/25.
//

import Foundation
import BinaryParsing

public struct LC_CODE_SIGNATURE: LoadCommand, LoadCommandLinkEdit {
    public let range: Range<Int>
    public let header: LoadCommandHeader
    
    public let offset: UInt32  // Offset is relative to the beginning of the MachO
    public let size: UInt32
    
    // Deferred Parsing
    public var signature: CodeSignatureSuperBlob? = nil
}

extension LC_CODE_SIGNATURE {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_CODE_SIGNATURE else {
            throw MachOError.LoadCommandError("Invalid LC_CODE_SIGNATURE ID")
        }
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_CODE_SIGNATURE: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Offset", stringValue: offset.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: size.description, offset: 12, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? {
        guard let signature = signature else { return nil }
        return [signature]
    }
}
