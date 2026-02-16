//
//  LC_SUB_LIBRARY.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_SUB_LIBRARY: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_SUB_LIBRARY
    public let header: LoadCommandHeader
    public let range: Range<Int>
}

extension LC_SUB_LIBRARY {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
    }
}

extension LC_SUB_LIBRARY: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "" }
    public var fields: [DisplayableField] { fieldBuilder().build() }
    public var children: [Displayable]? { nil }
}