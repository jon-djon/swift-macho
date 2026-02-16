//
//  LC_RPATH.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_RPATH: LoadCommand {
    public let header: LoadCommandHeader
    public let strOffset: UInt32
    public let name: String

    public let range: Range<Int>

    public var nameOffset: Int { self.range.lowerBound + Int(self.strOffset) }
}

extension LC_RPATH {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_RPATH else {
            throw MachOError.LoadCommandError("Invalid LC_RPATH")
        }

        self.strOffset = try UInt32(parsing: &input, endianness: endianness)

        // May need to advance further if offset is past 12
        if self.strOffset > 12 {
            try input.seek(toRelativeOffset: Int(self.strOffset) - 12)
        }

        //        try input.seek(toAbsoluteOffset: self.range.lowerBound+Int(self.strOffset))
        //        var span = input.extractRemaining()
        //        print(span.parserRange.range)
        self.name = String(parsingUTF8: &input)
    }
}

extension LC_RPATH: Displayable {
    public var description: String {
        "LC_RPATH instructs the dynamic linker (dyld) where to search for dynamically linked libraries (dylibs) or frameworks that are referenced using the @rpath subsitution string."
    }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Command ID", stringValue: header.id.description, offset: 0, size: 4,
                children: nil, obj: self),
            .init(
                label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4,
                children: nil, obj: self),
            .init(
                label: "Name Offset", stringValue: strOffset.description, offset: 8, size: 4,
                children: nil, obj: self),
            .init(
                label: "Name", stringValue: name, offset: Int(strOffset), size: name.count,
                children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
