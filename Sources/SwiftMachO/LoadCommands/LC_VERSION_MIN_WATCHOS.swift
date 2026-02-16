//
//  LC_VERSION_MIN_WATCHOS.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_VERSION_MIN_WATCHOS: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_VERSION_MIN_WATCHOS
    public let header: LoadCommandHeader
    public let version: SemanticVersion
    public let sdk: SemanticVersion
    public let range: Range<Int>
}

extension LC_VERSION_MIN_WATCHOS {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.version = try SemanticVersion(parsing: &input, endianness: endianness)
        self.sdk = try SemanticVersion(parsing: &input, endianness: endianness)
    }
}

extension LC_VERSION_MIN_WATCHOS: Displayable {
    public var description: String { "" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Version", stringValue: version.description, size: 4)
        b.add(label: "SDK", stringValue: sdk.description, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
