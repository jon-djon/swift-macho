//
//  FunctionVariantFixups.swift
//  swift-macho
//
//  Created by jon on 3/18/26.
//

import BinaryParsing
import Foundation

/// Parsed function variant fixups data from __LINKEDIT.
/// Contains an array of 8-byte internal fixup records for
/// non-exported variant functions. Each record specifies a segment
/// offset and which variants table to use for replacement.
public struct FunctionVariantFixups: Parseable {
    public let fixups: [FunctionVariantFixup]
    public let range: Range<Int>
}

extension FunctionVariantFixups {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        var fixups: [FunctionVariantFixup] = []

        while !input.isEmpty {
            fixups.append(try FunctionVariantFixup(parsing: &input))
        }

        self.fixups = fixups
    }
}

extension FunctionVariantFixups: Displayable {
    public var title: String { "Function Variant Fixups" }
    public var description: String { "\(fixups.count) fixups" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Fixups", stringValue: "\(fixups.count) entries", offset: 0,
                size: range.count,
                children: fixups.enumerated().map { index, fixup in
                    .init(
                        label: "Fixup \(index)", stringValue: fixup.description, offset: 0,
                        size: 8, children: fixup.fields, obj: fixup)
                }, obj: self)
        ]
    }
    public var children: [Displayable]? { nil }
}
