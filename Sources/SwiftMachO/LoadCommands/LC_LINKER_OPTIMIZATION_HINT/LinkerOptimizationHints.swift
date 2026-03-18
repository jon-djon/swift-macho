//
//  LinkerOptimizationHints.swift
//  swift-macho
//
//  Created by jon on 3/18/26.
//

import BinaryParsing
import Foundation

/// Parsed linker optimization hints from __LINKEDIT.
/// The data is a stream of ULEB128-encoded entries, each containing:
/// kind (ULEB128), argCount (ULEB128), addresses (argCount x ULEB128).
/// Parsing stops when the data is exhausted or kind == 0.
public struct LinkerOptimizationHints: Parseable {
    public let hints: [LinkerOptimizationHint]
    public let range: Range<Int>
}

extension LinkerOptimizationHints {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        var hints: [LinkerOptimizationHint] = []

        while !input.isEmpty {
            let start = input.startPosition
            let kindRaw = try UInt(parsingLEB128: &input)
            if kindRaw == 0 { break }

            let argCount = Int(try UInt(parsingLEB128: &input))

            guard let kind = LinkerOptimizationHint.Kind(rawValue: UInt8(kindRaw)) else {
                // Unknown kind — skip addresses
                for _ in 0..<argCount {
                    _ = try UInt(parsingLEB128: &input)
                }
                continue
            }

            var addresses: [UInt] = []
            for _ in 0..<argCount {
                addresses.append(try UInt(parsingLEB128: &input))
            }

            hints.append(LinkerOptimizationHint(
                kind: kind, addresses: addresses,
                range: start..<input.startPosition))
        }

        self.hints = hints
    }
}

extension LinkerOptimizationHints: Displayable {
    public var title: String { "Linker Optimization Hints" }
    public var description: String { "\(hints.count) hints" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Hints", stringValue: "\(hints.count) entries", offset: 0,
                size: range.count,
                children: hints.enumerated().map { index, hint in
                    .init(
                        label: "Hint \(index)", stringValue: hint.description, offset: 0,
                        size: 0, children: hint.fields, obj: hint)
                }, obj: self)
        ]
    }
    public var children: [Displayable]? { nil }
}
