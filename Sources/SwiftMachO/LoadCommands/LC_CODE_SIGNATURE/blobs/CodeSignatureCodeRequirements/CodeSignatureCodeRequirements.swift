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
    case HostRequirementType = 1
    case GuestRequirementType = 2
    case DesignatedRequirementType = 3
    case LibraryRequirementType = 4
    case PluginRequirementType = 5
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

extension CodeSignatureCodeRequirements: Displayable {
    public var title: String {
        "CodeSignatureCodeRequirements"
    }
    
    public var children: [any Displayable]? {
        []
    }
}
