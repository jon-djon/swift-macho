//
//  LC_IDENT.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_IDENT: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_IDENT
    public let header: LoadCommandHeader
    /// NUL-terminated identity strings packed in the remaining cmdsize bytes.
    public let identityStrings: [String]

    public let range: Range<Int>
}

extension LC_IDENT {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        var strings: [String] = []
        while input.count > 0 {
            let s = try String(parsingNulTerminated: &input)
            if !s.isEmpty {
                strings.append(s)
            }
        }
        self.identityStrings = strings
    }
}

extension LC_IDENT: Displayable {
    public var description: String { "Obsolete. Contains NUL-terminated identity strings describing the binary's origin." }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        for (i, s) in identityStrings.enumerated() {
            b.add(label: "Identity \(i)", stringValue: s, size: s.utf8.count + 1)
        }
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
