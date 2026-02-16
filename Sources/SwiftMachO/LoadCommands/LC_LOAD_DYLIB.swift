//
//  LC_LOAD_DYLIB.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_LOAD_DYLIB: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_LOAD_DYLIB
    public let header: LoadCommandHeader
    public let range: Range<Int>
    public let strOffset: UInt32
    public let timestamp: UInt32
    public let currentVersion: SemanticVersion
    public let compatibilityVersion: SemanticVersion
    public let name: String

    public var nameOffset: Int { self.range.lowerBound + Int(self.strOffset) }
}

extension LC_LOAD_DYLIB {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

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

extension LC_LOAD_DYLIB: Displayable {
    public var description: String {
        "The LC_LOAD_DYLIB command is to tell the dynamic linker (dyld) which dynamic libraries (dylibs) or frameworks must be loaded at the program's startup."
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Name Offset", stringValue: strOffset.description, size: 4)
        b.add(label: "Timestamp", stringValue: timestamp.description, size: 4)
        b.add(label: "Current Version", stringValue: currentVersion.description, size: 4)
        b.add(label: "Compatibility Version", stringValue: compatibilityVersion.description, size: 4)
        b.add(label: "Name", stringValue: name, offset: Int(strOffset), size: name.count)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
