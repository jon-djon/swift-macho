//
//  ResolvedSymbol.swift
//  swift-macho
//
//  Created by jon on 3/16/26.
//

import Foundation

public struct ResolvedSymbol {
    public let symbol: Symbol
    public let name: String
    public let stringRange: Range<Int>

    public init(symbol: Symbol, name: String, stringRange: Range<Int>) {
        self.symbol = symbol
        self.name = name
        self.stringRange = stringRange
    }
}

extension ResolvedSymbol: Displayable {
    public var range: Range<Int> { symbol.range }
    public var title: String { "Symbol" }
    public var description: String { name }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Name", stringValue: name, offset: 0, size: 4,
                children: nil, obj: self)
        ] + symbol.fields
    }
    public var children: [Displayable]? { nil }
}
