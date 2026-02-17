//
//  LC_TARGET_TRIPLE.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

import Foundation
import BinaryParsing

public struct LC_TARGET_TRIPLE: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_TARGET_TRIPLE
    public let header: LoadCommandHeader
    public let range: Range<Int>

    public let triple: String
}

extension LC_TARGET_TRIPLE {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        let commandStart = input.parserRange.lowerBound
        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.triple = try String(parsingNulTerminated: &input)

        // Ensure the full cmdsize is consumed
        let finalPosition = commandStart + Int(self.header.cmdSize)
        try input.seek(toAbsoluteOffset: finalPosition)
        self.range = commandStart..<finalPosition
    }
}

extension LC_TARGET_TRIPLE: Displayable {
    public var description: String { "Target Triple" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Triple", stringValue: triple, size: triple.utf8.count + 1)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}