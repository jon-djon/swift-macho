//
//  ParserRange+.swift
//  swift-macho
//
//  Created by jon on 10/15/25.
//

import BinaryParsing

extension ParserRange {
    public var hexDescription: String {
        "\(lowerBound.hexDescription) - \(upperBound.hexDescription)"
    }
    
    public var range: Range<Int> {
        lowerBound..<upperBound
    }
}
