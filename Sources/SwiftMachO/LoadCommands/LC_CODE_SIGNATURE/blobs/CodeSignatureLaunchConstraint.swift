//
//  CodeSignatureLaunchConstraint.swift
//  swift-macho
//
//  Created by jon on 10/30/25.
//
import Foundation
import BinaryParsing
import SwiftASN1


public struct CodeSignatureLaunchConstraint: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    public let constraints: EntitlementRoot
    
    public let range: Range<Int>
    
    public var description: String {
        "CodeSignatureLaunchConstraint \(length.description) bytes"
    }
}

extension CodeSignatureLaunchConstraint {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .LaunchConstraint else {
            throw MachOError.badMagicValue("CodeSignatureLaunchConstraint unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.range = start..<start+Int(length)
        
        let data = try Data(parsing: &input, byteCount: Int(self.length)-8)
        self.constraints = try EntitlementRoot(derEncoded: try DER.parse([UInt8](data)))
    }
}

extension CodeSignatureLaunchConstraint: Displayable {
    public var title: String {
        "CodeSignatureLaunchConstraint"
    }
    
    public var fields: [DisplayableField] {
        [
            .init(label: "Magic", stringValue: magic.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Length", stringValue: length.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Contraints", stringValue: "", offset: 8, size: Int(self.length)-8, children: constraints.fields, obj: self),
        ]
    }
    
    public var children: [any Displayable]? { [] }
}
