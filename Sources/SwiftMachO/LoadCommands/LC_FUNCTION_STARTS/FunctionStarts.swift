//
//  FunctionStarts.swift
//  swift-macho
//
//  Created by jon on 9/29/25.
//

import BinaryParsing
import Foundation

public struct FunctionStarts: Parseable {
    public let starts: [UInt]  // These are offsets from the start of the text section vmaddress
    private let offsets: [Int]

    public let range: Range<Int>
}

extension FunctionStarts {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        var starts: [UInt] = []
        var offsets: [Int] = []
        while !input.isEmpty {
            offsets.append(input.parserRange.lowerBound)
            starts.append(try UInt(parsingLEB128: &input))  // Seems like there might be a bug here where values are not properly parsed?
        }
        self.starts = starts
        self.offsets = offsets
    }
}

extension FunctionStarts: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Function Starts", stringValue: "Starts \(starts.count)", offset: 0,
                size: range.count,
                children: starts.enumerated().map { index, value in
                    .init(
                        label: "Start \(index)", stringValue: value.hexDescription,
                        offset: offsets[index], size: 0, children: nil, obj: self)
                }, obj: self)
        ]

    }
    public var children: [Displayable]? { nil }
}
