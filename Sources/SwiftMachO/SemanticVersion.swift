//
//  SemanticVersion.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//
import Foundation
import BinaryParsing

public struct SemanticVersion: Parseable, CustomStringConvertible {
    let rawValue: UInt32
    
    public let range: Range<Int>

    public static let mask: UInt32 = 0b1111
    
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }
    
    public var major: Int {
        // get bytes 17-32
        Int((rawValue >> 16))
    }
    
    public var minor: Int {
        // get bytes 9-16
        Int((rawValue >> 8) & Self.mask)
    }
    
    public var patch: Int {
        // get the last 8 bytes
        Int(rawValue & Self.mask)
    }
}

extension SemanticVersion {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        self.rawValue = try UInt32(parsing: &input, endianness: endianness)
    }
}
