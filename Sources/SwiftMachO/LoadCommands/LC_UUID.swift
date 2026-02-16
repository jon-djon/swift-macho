import BinaryParsing
//
//  LC_UUID.swift
//  swift-macho
//
//  Created by jon on 9/29/25.
//
import Foundation

public struct LC_UUID: LoadCommand {
    public let header: LoadCommandHeader
    public let range: Range<Int>

    internal let _uuid: InlineArray<16, UInt8>

    public var uuid: UUID {
        UUID(
            uuid: (
                _uuid[0], _uuid[1], _uuid[2], _uuid[3],
                _uuid[4], _uuid[5], _uuid[6], _uuid[7],
                _uuid[8], _uuid[9], _uuid[10], _uuid[11],
                _uuid[12], _uuid[13], _uuid[14], _uuid[15]
            ))
    }
}

extension LC_UUID {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_UUID else {
            throw MachOError.LoadCommandError("Invalid LC_UUID")
        }
        self._uuid = try InlineArray<16, UInt8>(parsing: &input)
    }
}

extension LC_UUID: Displayable {
    public var description: String {
        "The primary purpose of the LC_UUID command is to provide a unique, immutable identifier for the MachO binary."
    }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "ID", stringValue: header.id.description, offset: 0, size: 4, children: nil,
                obj: self),
            .init(
                label: "Size", stringValue: header.cmdSize.description, offset: 4, size: 4,
                children: nil, obj: self),
            .init(
                label: "UUID", stringValue: uuid.description, offset: 8, size: 16, children: nil,
                obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
