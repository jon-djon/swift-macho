//
//  LC_VERSION_MIN_IPHONEOS.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_VERSION_MIN_IPHONEOS: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_VERSION_MIN_IPHONEOS
    public let header: LoadCommandHeader
    public let version: SemanticVersion
    public let sdk: SemanticVersion
    public let range: Range<Int>
}

extension LC_VERSION_MIN_IPHONEOS {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.version = try SemanticVersion(parsing: &input, endianness: endianness)
        self.sdk = try SemanticVersion(parsing: &input, endianness: endianness)
    }
}

extension LC_VERSION_MIN_IPHONEOS: Displayable {
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Command ID", stringValue: header.id.description, offset: 0, size: 4,
                children: nil, obj: self),
            .init(
                label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4,
                children: nil, obj: self),
            .init(
                label: "Version", stringValue: version.description, offset: 8, size: 4,
                children: nil, obj: self),
            .init(
                label: "SDK", stringValue: sdk.description, offset: 12, size: 4, children: nil,
                obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
