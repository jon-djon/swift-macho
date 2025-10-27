//
//  CodeSignatureSuperBlob.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//
import Foundation
import BinaryParsing

public struct CodeSignatureSuperBlob: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    public let count: UInt32
    public let blobs: [CodeSignatureBlobValue]
    
    public let range: Range<Int>
    
    
    public var rawBlobs: [CodeSignatureSuperBlob.Blob] {
        self.blobs.map { blob in
            switch blob {
            case .CodeDirectory(let blob, _): blob
            case .CodeRequirement(let blob, _): blob
            case .CodeRequirements(let blob, _): blob
            case .CodeEntitlements(let blob, _): blob
            case .CodeEntitlementsDER(let blob, _): blob
            case .SuperBlob(let blob, _): blob
            case .BlobWrapper(let blob, _): blob
            }
        }
    }
    
    public struct Blob {
        public let type: DirectoryType
        public let offset: UInt32

        public let range: ParserRange
        
        public var description: String {
            type.description
        }
        
        @CaseName
        public enum DirectoryType: UInt32 {
            case cdCodeDirectorySlot = 0
            case cdInfoSlot = 1
            case cdRequirementSlot = 2
            case cdResourceDirectorySlot = 3
            case cdTopDirectorySlot = 4
            case cdEntitlementsSlot = 5
            case cdRepSpecificSlot = 6
            case cdCodeEntitlementsDERSlot = 7
            case cdLaunchConstraintSelf = 8
            case cdLaunchConstraintParent = 9
            case cdLaunchConstraintResponsible = 10
            case cdAlternateCodeDirectorySlots = 0x1000
            case cdAlternateCodeDirectoryLimit = 0x1005
            case cdSignatureSlot = 0x10000
        }
    }
}

extension CodeSignatureSuperBlob {
    public init(parsing input: inout ParserSpan) throws {
        let range = input.parserRange.range
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .SuperBlob else {
            throw MachOError.badMagicValue("CodeSignatureSuperBlob unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.count = try UInt32(parsing: &input, endianness: .big)
        let blobs: [CodeSignatureSuperBlob.Blob] = try Array(parsing: &input, count: Int(self.count)) { input in
            try CodeSignatureSuperBlob.Blob(parsing: &input, endianness: .big)
        }
        
        self.blobs = try blobs.map { blob in
            try input.seek(toAbsoluteOffset: range.lowerBound)
            try input.seek(toRelativeOffset: blob.offset)
            return try CodeSignatureBlobValue(parsing: &input, blob: blob)
        }
        self.range = range
    }
}


extension CodeSignatureSuperBlob.Blob {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange
        self.type = try CodeSignatureSuperBlob.Blob.DirectoryType(parsing: &input, endianness: .big)
        self.offset = try UInt32(parsing: &input, endianness: .big)
    }
}

extension CodeSignatureSuperBlob: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Magic", stringValue: magic.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Length", stringValue: length.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Count", stringValue: count.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Blobs", stringValue: count.description, offset: 12, size: 8*blobs.count,
                   children: rawBlobs.enumerated().map { (index: Int, blob: CodeSignatureSuperBlob.Blob) in
                       .init(label: "Blob \(index+1)", stringValue: blob.type.description, offset: 12+(index*8), size: 8, children: [
                         .init(label: "Type", stringValue: blob.type.description, offset: 12+(index*8), size: 4, children: nil, obj: self),
                         .init(label: "Offset", stringValue: blob.offset.description, offset: 12+(index*8)+4, size: 4, children: nil, obj: self),
                       ], obj: self)
                   },
                   obj: self
             ),
        ]
    }
    public var children: [Displayable]? {
        blobs.compactMap { blob in
             switch blob {
             case .CodeDirectory(_, let cd): cd
             case .CodeRequirement(_, let req): req
             case .CodeRequirements(_, let reqs): reqs
             case .CodeEntitlements(_, let reqs): reqs
             case .CodeEntitlementsDER(_, let reqs): reqs
             case .SuperBlob(_, let reqs): reqs
             case .BlobWrapper(_, let reqs): reqs
             }
         }
    }
}
