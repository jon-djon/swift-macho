//
//  SplitSegInfoFixup.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

/// An individual fixup location from split segment info
public struct SplitSegInfoFixup: Parseable {
    public let kind: SplitSegInfoV2Kind
    public let fromSectionIndex: UInt
    public let fromSectionOffset: UInt
    public let toSectionIndex: UInt
    public let toSectionOffset: UInt

    public let range: Range<Int>
}

extension SplitSegInfoFixup: Displayable {
    public var title: String { "Fixup" }
    public var description: String {
        "\(kind.description): section \(fromSectionIndex):\(fromSectionOffset.hexDescription) -> section \(toSectionIndex):\(toSectionOffset.hexDescription)"
    }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Kind", stringValue: kind.description, offset: 0, size: 0, children: nil,
                obj: self),
            .init(
                label: "From Section Index", stringValue: fromSectionIndex.description, offset: 0,
                size: 0, children: nil, obj: self),
            .init(
                label: "From Section Offset", stringValue: fromSectionOffset.hexDescription,
                offset: 0, size: 0, children: nil, obj: self),
            .init(
                label: "To Section Index", stringValue: toSectionIndex.description, offset: 0,
                size: 0, children: nil, obj: self),
            .init(
                label: "To Section Offset", stringValue: toSectionOffset.hexDescription, offset: 0,
                size: 0, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
