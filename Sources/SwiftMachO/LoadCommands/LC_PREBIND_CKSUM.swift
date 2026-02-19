//
//  LC_PREBIND_CKSUM.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_PREBIND_CKSUM: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_PREBIND_CKSUM
    public let header: LoadCommandHeader
    public let cksum: UInt32

    public let range: Range<Int>
}

extension LC_PREBIND_CKSUM {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self.cksum = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_PREBIND_CKSUM: Displayable {
    public var description: String { "Contains the checksum computed during the prebinding operation, or zero if not prebound." }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Checksum", stringValue: cksum.hexDescription, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
