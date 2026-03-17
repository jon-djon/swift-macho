//
//  SegmentFlags.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation

@AutoOptionSet
public struct SegmentFlags: OptionSet, Sendable {
    // public static let NONE = SegmentFlags(rawValue: 0)
    public static let HIGH_VM = SegmentFlags(rawValue: 0x0000_0001)
    public static let FIXED_VM_LIBRARY = SegmentFlags(rawValue: 0x0000_0002)
    public static let NO_RELOCATIONS = SegmentFlags(rawValue: 0x0000_0004)
    public static let PROTECTED_V1 = SegmentFlags(rawValue: 0x0000_0008)
    public static let READ_ONLY = SegmentFlags(rawValue: 0x0000_0010)
}
