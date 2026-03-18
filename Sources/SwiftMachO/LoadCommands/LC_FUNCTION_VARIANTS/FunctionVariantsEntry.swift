//
//  FunctionVariantsEntry.swift
//  swift-macho
//
//  Created by jon on 3/18/26.
//

import BinaryParsing
import Foundation

/// A single 8-byte entry in a function variants runtime table.
/// Each entry specifies flag requirements and either a function offset
/// or an index to another table for chained dispatch.
public struct FunctionVariantsEntry {
    public let impl: UInt32
    public let anotherTable: Bool
    public let flagBitNums: [UInt8]
    public let range: Range<Int>

    /// Whether this is the default/fallback entry (no flags required)
    public var isDefault: Bool { flagBitNums.isEmpty }
}

extension FunctionVariantsEntry {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        let raw = try UInt32(parsing: &input, endianness: .little)
        self.impl = raw & 0x7FFF_FFFF
        self.anotherTable = (raw >> 31) != 0

        let b0 = try UInt8(parsing: &input)
        let b1 = try UInt8(parsing: &input)
        let b2 = try UInt8(parsing: &input)
        let b3 = try UInt8(parsing: &input)
        self.flagBitNums = [b0, b1, b2, b3].filter { $0 != 0 }

        self.range = start..<input.startPosition
    }
}

extension FunctionVariantsEntry: Displayable {
    public var title: String { "FunctionVariantsEntry" }
    public var description: String {
        let target = anotherTable ? "table[\(impl)]" : impl.hexDescription
        if isDefault {
            return "\(target) (default)"
        }
        let flags = flagBitNums.map { String($0) }.joined(separator: ", ")
        return "\(target) flags: [\(flags)]"
    }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Impl", stringValue: impl.hexDescription, offset: 0, size: 4,
                children: nil, obj: self),
            .init(
                label: "Another Table", stringValue: anotherTable ? "Yes" : "No", offset: 0,
                size: 0, children: nil, obj: self),
            .init(
                label: "Flag Bit Nums",
                stringValue: flagBitNums.isEmpty
                    ? "(none)" : flagBitNums.map { String($0) }.joined(separator: ", "),
                offset: 4, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
