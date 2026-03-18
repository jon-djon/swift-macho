//
//  FunctionVariantsTable.swift
//  swift-macho
//
//  Created by jon on 3/18/26.
//

import BinaryParsing
import Foundation

/// A single function variants runtime table.
/// Each table has a kind (CPU feature set or process/system scope)
/// and an array of entries specifying variant implementations.
public struct FunctionVariantsTable {
    public let kind: Kind
    public let entries: [FunctionVariantsEntry]
    public let range: Range<Int>

    @CaseName
    public enum Kind: UInt32 {
        case perProcess = 1
        case systemWide = 2
        case arm64 = 3
        case x86_64 = 4
    }
}

extension FunctionVariantsTable {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        let kindRaw = try UInt32(parsing: &input, endianness: .little)
        guard let kind = Kind(rawValue: kindRaw) else {
            // Unknown kind — parse count and skip entries
            let count = Int(try UInt32(parsing: &input, endianness: .little))
            for _ in 0..<count {
                _ = try UInt32(parsing: &input, endianness: .little)
                _ = try UInt32(parsing: &input, endianness: .little)
            }
            self.kind = .perProcess
            self.entries = []
            self.range = start..<input.startPosition
            return
        }
        self.kind = kind

        let count = Int(try UInt32(parsing: &input, endianness: .little))
        var entries: [FunctionVariantsEntry] = []
        for _ in 0..<count {
            entries.append(try FunctionVariantsEntry(parsing: &input))
        }
        self.entries = entries
        self.range = start..<input.startPosition
    }
}

extension FunctionVariantsTable: Displayable {
    public var title: String { "FunctionVariantsTable" }
    public var description: String {
        "\(kind.description): \(entries.count) entries"
    }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Kind", stringValue: kind.description, offset: 0, size: 4,
                children: nil, obj: self),
            .init(
                label: "Entries", stringValue: "\(entries.count) entries", offset: 4,
                size: range.count - 4,
                children: entries.enumerated().map { index, entry in
                    .init(
                        label: "Entry \(index)", stringValue: entry.description, offset: 0,
                        size: 8, children: entry.fields, obj: entry)
                }, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
