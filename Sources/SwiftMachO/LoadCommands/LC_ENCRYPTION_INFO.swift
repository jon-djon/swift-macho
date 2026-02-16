//
//  LC_ENCRYPTION_INFO.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

/// Encryption system identifier for LC_ENCRYPTION_INFO commands.
/// A value of 0 indicates the binary is not encrypted, while non-zero values
/// indicate encryption (typically FairPlay DRM for App Store apps).
@CaseName
public enum CryptID: UInt32 {
    case notEncrypted = 0
    case encrypted = 1  // FairPlay DRM
}

public struct LC_ENCRYPTION_INFO: LoadCommand, LoadCommandLinkEdit {
    public static let expectedID: LoadCommandHeader.ID = .LC_ENCRYPTION_INFO
    public let header: LoadCommandHeader
    public let range: Range<Int>

    public let offset: UInt32
    public let size: UInt32
    public let cryptID: CryptID
}

extension LC_ENCRYPTION_INFO {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.size = try UInt32(parsing: &input, endianness: endianness)
        self.cryptID = try CryptID(parsing: &input, endianness: endianness)
    }
}

extension LC_ENCRYPTION_INFO: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String {
        "Contains information about an encrypted segment in a 32-bit binary, including the file offset, size, and encryption system identifier."
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Offset", stringValue: offset.description, size: 4)
        b.add(label: "Size", stringValue: size.description, size: 4)
        b.add(label: "Crypt ID", stringValue: cryptID.description, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
