//
//  Protocols.swift
//  swift-macho
//
//  Created by jon on 10/15/25.
//

import Foundation
import BinaryParsing

public protocol Parseable {
    var range: Range<Int> { get }
}

extension Parseable {
    public func getAbsoluteFieldRange(_ field: DisplayableField) -> Range<Int> {
        range.lowerBound+field.offset ..< range.lowerBound+field.offset+field.size
    }
}


public protocol Displayable: Parseable {
    var title: String { get }
    var description: String { get }
    var children : [Displayable]? { get }
    var fields: [DisplayableField] { get }
}

extension Displayable {
    public var fields: [DisplayableField]  { [] }
}
