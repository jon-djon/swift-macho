//
//  LC_LOADFVMLIB.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_LOADFVMLIB: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_LOADFVMLIB
    public let header: LoadCommandHeader
    public let strOffset: UInt32    // offset to name string (from command start)
    public let minorVersion: UInt32 // library's minor version number
    public let headerAddr: UInt32   // library's header address
    public let name: String
    public let range: Range<Int>

    public var nameOffset: Int { self.range.lowerBound + Int(self.strOffset) }
}

extension LC_LOADFVMLIB {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self.strOffset = try UInt32(parsing: &input, endianness: endianness)
        self.minorVersion = try UInt32(parsing: &input, endianness: endianness)
        self.headerAddr = try UInt32(parsing: &input, endianness: endianness)

        try input.seek(toAbsoluteOffset: self.range.lowerBound)
        try input.seek(toRelativeOffset: self.strOffset)
        self.name = try String(parsingNulTerminated: &input)
    }
}

extension LC_LOADFVMLIB: Displayable {
    public var description: String { "Load Fixed VM Shared Library" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Name Offset", stringValue: strOffset.description, size: 4)
        b.add(label: "Minor Version", stringValue: minorVersion.description, size: 4)
        b.add(label: "Header Address", stringValue: headerAddr.hexDescription, size: 4)
        b.add(label: "Name", stringValue: name, offset: Int(strOffset), size: name.count)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
