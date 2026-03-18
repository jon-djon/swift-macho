//
//  FunctionVariantFixup.swift
//  swift-macho
//
//  Created by jon on 3/18/26.
//

import BinaryParsing
import Foundation

/// A single 8-byte internal fixup record for non-exported function variants.
/// Tells dyld to replace the default function pointer at a given segment
/// offset with the best variant from the specified variants table.
public struct FunctionVariantFixup {
    public let segOffset: UInt32
    public let segIndex: UInt8
    public let variantIndex: UInt8
    public let pacAuth: Bool
    public let pacAddress: Bool
    public let pacKey: UInt8
    public let pacDiversity: UInt16
    public let range: Range<Int>
}

extension FunctionVariantFixup {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        self.segOffset = try UInt32(parsing: &input, endianness: .little)

        let raw = try UInt32(parsing: &input, endianness: .little)
        self.segIndex = UInt8(raw & 0xF)
        self.variantIndex = UInt8((raw >> 4) & 0xFF)
        self.pacAuth = (raw >> 12) & 1 != 0
        self.pacAddress = (raw >> 13) & 1 != 0
        self.pacKey = UInt8((raw >> 14) & 0x3)
        self.pacDiversity = UInt16((raw >> 16) & 0xFFFF)

        self.range = start..<input.startPosition
    }
}

extension FunctionVariantFixup: Displayable {
    public var title: String { "FunctionVariantFixup" }
    public var description: String {
        "seg[\(segIndex)] + \(segOffset.hexDescription) → variant \(variantIndex)"
    }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Segment Offset", stringValue: segOffset.hexDescription, offset: 0,
                size: 4, children: nil, obj: self),
            .init(
                label: "Segment Index", stringValue: "\(segIndex)", offset: 4, size: 0,
                children: nil, obj: self),
            .init(
                label: "Variant Index", stringValue: "\(variantIndex)", offset: 4, size: 0,
                children: nil, obj: self),
            .init(
                label: "PAC Auth", stringValue: pacAuth ? "Yes" : "No", offset: 4, size: 0,
                children: nil, obj: self),
            .init(
                label: "PAC Address", stringValue: pacAddress ? "Yes" : "No", offset: 4,
                size: 0, children: nil, obj: self),
            .init(
                label: "PAC Key", stringValue: "\(pacKey)", offset: 4, size: 0,
                children: nil, obj: self),
            .init(
                label: "PAC Diversity", stringValue: String(format: "0x%04X", pacDiversity), offset: 4,
                size: 0, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
