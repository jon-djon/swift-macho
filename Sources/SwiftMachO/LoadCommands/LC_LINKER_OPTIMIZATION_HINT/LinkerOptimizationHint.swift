//
//  LinkerOptimizationHint.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

/// A single linker optimization hint entry from __LINKEDIT.
/// Each hint specifies a kind (ARM64 instruction pattern) and the
/// absolute file offsets of the instructions involved.
public struct LinkerOptimizationHint {
    public let kind: Kind
    public let addresses: [UInt]
    public let range: Range<Int>

    @CaseName
    public enum Kind: UInt8 {
        case LOH_ARM64_ADRP_ADRP = 1
        case LOH_ARM64_ADRP_LDR = 2
        case LOH_ARM64_ADRP_ADD_LDR = 3
        case LOH_ARM64_ADRP_LDR_GOT_LDR = 4
        case LOH_ARM64_ADRP_ADD_STR = 5
        case LOH_ARM64_ADRP_LDR_GOT_STR = 6
        case LOH_ARM64_ADRP_ADD = 7
        case LOH_ARM64_ADRP_LDR_GOT = 8
    }
}

extension LinkerOptimizationHint: Displayable {
    public var title: String { "LinkerOptimizationHint" }
    public var description: String {
        "\(kind.description): \(addresses.map { $0.hexDescription }.joined(separator: ", "))"
    }
    public var fields: [DisplayableField] {
        var fields: [DisplayableField] = [
            .init(
                label: "Kind", stringValue: kind.description, offset: 0, size: 0,
                children: nil, obj: self)
        ]
        for (index, addr) in addresses.enumerated() {
            fields.append(.init(
                label: "Address \(index)", stringValue: addr.hexDescription, offset: 0,
                size: 0, children: nil, obj: self))
        }
        return fields
    }
    public var children: [Displayable]? { nil }
}
