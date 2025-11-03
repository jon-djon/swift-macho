//
//  CodeRequirements.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

@CaseName
public enum MachOCodeSignatureRequirementType: UInt32 {
    case host = 1
    case guest = 2
    case designated = 3
    case library = 4
    case plugin = 5
}

public struct CodeRequirementHeader: Parseable {
    public let type: MachOCodeSignatureRequirementType
    public let offset: UInt32
    
    public let range: Range<Int>
    
    public var description: String {
        type.description
    }
    
    public static let size: Int = 8
}

extension CodeRequirementHeader {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        self.type = try MachOCodeSignatureRequirementType(parsing: &input, endianness: .big)
        self.offset = try UInt32(parsing: &input, endianness: .big)
    }
}



public struct CodeSignatureCodeRequirements: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    public let numRequirements: UInt32
    public let requirements: [(CodeRequirementHeader,CodeSignatureCodeRequirement)]
    
    public let range: Range<Int>
    
    public var description: String {
        "CodeSignatureCodeRequirements - " + requirements.map {
            $0.1.description
        }.joined(separator: "\n")
    }
}


extension CodeSignatureCodeRequirements {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .CodeRequirements else {
            throw MachOError.badMagicValue("CodeSignatureCodeRequirements unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.numRequirements = try UInt32(parsing: &input, endianness: .big)
        
        let headers = try Array(parsing: &input, count: Int(self.numRequirements)) { input in
            var span = try input.sliceSpan(byteCount: CodeRequirementHeader.size)
            return try CodeRequirementHeader(parsing: &span)
        }
        
        var requirements: [(CodeRequirementHeader,CodeSignatureCodeRequirement)] = []
        for r in headers {
            try input.seek(toAbsoluteOffset: start+Int(r.offset))
            requirements.append( (r, try CodeSignatureCodeRequirement(parsing: &input, type: r.type)) )
        }
        self.requirements = requirements
        self.range = start..<start+Int(self.length)
    }
}

extension CodeSignatureCodeRequirements {
    public var requirementStrings: [String] {
        requirements.compactMap {
            try? $0.1.buildExpressionString()
        }
    }
}

extension CodeSignatureCodeRequirements: Displayable {
    public var title: String {
        "CodeSignatureCodeRequirements"
    }
    
    public var fields: [DisplayableField] {
        [
            .init(label: "Magic", stringValue: magic.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Length", stringValue: length.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Requirements", stringValue: "\(requirements.count.description) Requirements", offset: 8, size: Int(self.length)-8, children: requirements.enumerated().map { index,req in
                .init(label: "Requirement \(index)", stringValue: "", offset: 0, size: 4, children: [
                    .init(label: "Type", stringValue: req.0.type.description, offset: 0, size: 4, children: nil, obj: req.0),
                    .init(label: "Offset", stringValue: req.0.offset.description, offset: 4, size: 4, children: nil, obj: req.0),
                    .init(label: "Requirement", stringValue: req.1.description, offset: 0, size: req.1.range.count, children: req.1.fields, obj: req.1),
                ], obj: self)
            }, obj: self),
        ]
    }
    
    public var children: [any Displayable]? { nil }
}
