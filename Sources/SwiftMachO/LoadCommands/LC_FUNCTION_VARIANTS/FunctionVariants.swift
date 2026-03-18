//
//  FunctionVariants.swift
//  swift-macho
//
//  Created by jon on 3/18/26.
//

import BinaryParsing
import Foundation

/// Parsed function variants data from __LINKEDIT.
/// The on-disk format is a table count followed by uint32 offsets to each
/// FunctionVariantsRuntimeTable. Each table specifies a kind (CPU features
/// or process/system scope) and variant entries with flag requirements.
public struct FunctionVariants: Parseable {
    public let tables: [FunctionVariantsTable]
    public let range: Range<Int>
}

extension FunctionVariants {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        let baseOffset = input.startPosition

        let tableCount = Int(try UInt32(parsing: &input, endianness: .little))
        var tableOffsets: [UInt32] = []
        for _ in 0..<tableCount {
            tableOffsets.append(try UInt32(parsing: &input, endianness: .little))
        }

        var tables: [FunctionVariantsTable] = []
        for offset in tableOffsets {
            try input.seek(toAbsoluteOffset: baseOffset + Int(offset))
            tables.append(try FunctionVariantsTable(parsing: &input))
        }
        self.tables = tables
    }
}

extension FunctionVariants: Displayable {
    public var title: String { "Function Variants" }
    public var description: String { "\(tables.count) tables" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Tables", stringValue: "\(tables.count) tables", offset: 0,
                size: range.count,
                children: tables.enumerated().map { index, table in
                    .init(
                        label: "Table \(index)", stringValue: table.description, offset: 0,
                        size: table.range.count, children: table.fields, obj: table)
                }, obj: self)
        ]
    }
    public var children: [Displayable]? { nil }
}
