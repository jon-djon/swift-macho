//
//  LC_LINKER_OPTIMIZATION_HINT.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_LINKER_OPTIMIZATION_HINT: LoadCommand, LoadCommandLinkEdit {
    public static let expectedID: LoadCommandHeader.ID = .LC_LINKER_OPTIMIZATION_HINT
    public let header: LoadCommandHeader
    public let offset: UInt32
    public let size: UInt32

    public let range: Range<Int>
}

extension LC_LINKER_OPTIMIZATION_HINT {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self.offset = try UInt32(parsing: &input, endianness: .little)
        self.size = try UInt32(parsing: &input, endianness: .little)
    }
}

extension LC_LINKER_OPTIMIZATION_HINT: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        addLinkEditFields(to: &b, offsetIsHex: false)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
