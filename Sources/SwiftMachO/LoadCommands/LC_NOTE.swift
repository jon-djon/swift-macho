//
//  LC_NOTE.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_NOTE: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_NOTE
    public let header: LoadCommandHeader
    public let range: Range<Int>

    internal let _dataOwner: InlineArray<16, UInt8>
    public let offset: UInt64  // file offset of note data
    public let size: UInt64    // length of note data in file

    public var dataOwner: String {
        var bytes: [UInt8] = []
        for i in 0..<16 {
            let b = _dataOwner[i]
            if b == 0 { break }
            bytes.append(b)
        }
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }
}

extension LC_NOTE {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self._dataOwner = try InlineArray<16, UInt8>(parsing: &input)
        self.offset = try UInt64(parsing: &input, endianness: endianness)
        self.size = try UInt64(parsing: &input, endianness: endianness)
    }
}

extension LC_NOTE: Displayable {
    public var description: String { "Note" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Data Owner", stringValue: dataOwner, size: 16)
        b.add(label: "Offset", stringValue: offset.hexDescription, size: 8)
        b.add(label: "Size", stringValue: size.description, size: 8)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
