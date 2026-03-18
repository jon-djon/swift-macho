//
//  Section64.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct Section64: Parseable {
    public let sectionName: String  // 16 [UInt8]
    public let segmentName: String  // 16 [UInt8]
    public let address: UInt64
    public let size: UInt64
    public let offset: UInt32
    public let alignment: UInt32
    public let relocOffset: UInt32
    public let nRelocs: UInt32
    public let flags: SectionFlags
    public let reserved1: UInt32
    public let reserved2: UInt32
    public let reserved3: UInt32

    public let range: Range<Int>

    public static let size: Int = 80
}

extension Section64 {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        var span = try input.sliceSpan(byteCount: 16)
        self.sectionName = String(parsingUTF8: &span).trimmingCharacters(in: CharacterSet(charactersIn: "\0"))
        span = try input.sliceSpan(byteCount: 16)
        self.segmentName = String(parsingUTF8: &span).trimmingCharacters(in: CharacterSet(charactersIn: "\0"))

        self.address = try UInt64(parsing: &input, endianness: endianness)
        self.size = try UInt64(parsing: &input, endianness: endianness)
        self.offset = try UInt32(parsing: &input, endianness: endianness)
        self.alignment = try UInt32(parsing: &input, endianness: endianness)
        self.relocOffset = try UInt32(parsing: &input, endianness: endianness)
        self.nRelocs = try UInt32(parsing: &input, endianness: endianness)
        self.flags = try SectionFlags(parsing: &input, endianness: endianness)
        self.reserved1 = try UInt32(parsing: &input, endianness: endianness)
        self.reserved2 = try UInt32(parsing: &input, endianness: endianness)
        self.reserved3 = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension Section64: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "\(segmentName).\(sectionName)" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Section Name", stringValue: sectionName, offset: 0, size: 16, children: nil,
                obj: self),
            .init(
                label: "Segment Name", stringValue: segmentName, offset: 16, size: 16,
                children: nil, obj: self),
            .init(
                label: "Address", stringValue: address.hexDescription, offset: 32, size: 8,
                children: nil, obj: self),
            .init(
                label: "Size", stringValue: size.description, offset: 40, size: 8, children: nil,
                obj: self),
            .init(
                label: "Offset", stringValue: offset.description, offset: 48, size: 8,
                children: nil, obj: self),
            .init(
                label: "Alignment", stringValue: alignment.description, offset: 52, size: 4,
                children: nil, obj: self),
            .init(
                label: "Relocations Offset", stringValue: relocOffset.description, offset: 56,
                size: 4,
                children: nil, obj: self),
            .init(
                label: "Number of Relocations", stringValue: nRelocs.description, offset: 60,
                size: 4, children: nil, obj: self),
            .init(
                label: "Flags", stringValue: flags.description, offset: 64, size: 4, children: nil,
                obj: self),
            .init(
                label: "Reserved 1", stringValue: reserved1.description, offset: 68, size: 4,
                children: nil, obj: self),
            .init(
                label: "Reserved 2", stringValue: reserved2.description, offset: 72, size: 4,
                children: nil, obj: self),
            .init(
                label: "Reserved 3", stringValue: reserved3.description, offset: 76, size: 4,
                children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
