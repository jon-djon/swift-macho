//
//  CodeSignatureSuperBlob.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//
import Foundation
import BinaryParsing


public struct CodeSignatureSuperBlob {
    public let range: ParserRange
    public let magic: Magic
    public let length: UInt32
    public let count: UInt32
    public let slots: [SuperBlobValueSlot]
    
    
    public struct SuperBlobValueSlot {
        public let range: ParserRange
        public let type: DirectoryType
        //TODO:  public let value: UInt32
        public let offset: UInt32
        
        public enum DirectoryType: UInt32, CustomStringConvertible {
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
            
            public var description: String {
                switch self {
                case .cdCodeDirectorySlot: "cdCodeDirectorySlot"
                case .cdInfoSlot: "cdInfoSlot"
                case .cdRequirementSlot: "cdRequirementSlot"
                case .cdResourceDirectorySlot: "cdResourceDirectorySlot"
                case .cdTopDirectorySlot: "cdTopDirectorySlot"
                case .cdEntitlementsSlot: "cdEntitlementsSlot"
                case .cdRepSpecificSlot: "cdRepSpecificSlot"
                case .cdCodeEntitlementsDERSlot: "cdCodeEntitlementsDERSlot"
                case .cdLaunchConstraintSelf: "cdLaunchConstraintSelf"
                case .cdLaunchConstraintParent: "cdLaunchConstraintParent"
                case .cdLaunchConstraintResponsible: "cdLaunchConstraintResponsible"
                case .cdAlternateCodeDirectorySlots: "cdAlternateCodeDirectorySlots"
                case .cdAlternateCodeDirectoryLimit: "cdAlternateCodeDirectoryLimit"
                case .cdSignatureSlot: "cdSignatureSlot"
                }
            }
        }
    }
    
    
    public enum Magic: UInt32, CustomStringConvertible {
        case CodeDirectory = 0xFADE0C02
        case CodeRequirement = 0xFADE0C00
        case CodeRequirements = 0xFADE0C01
        case CodeEntitlements = 0xFADE7171
        case CodeCodeEntitlementsDER = 0xFADE7172
        case SuperBlob = 0xFADE0CC0
        case BlobWrapper = 0xFADE0B01
        
        public var description: String {
            switch self {
            case .CodeDirectory: "CodeDirectory"
            case .CodeRequirement: "CodeRequirement"
            case .CodeRequirements: "CodeRequirements"
            case .CodeEntitlements: "CodeEntitlements"
            case .CodeCodeEntitlementsDER: "CodeCodeEntitlementsDER"
            case .SuperBlob: "SuperBlob"
            case .BlobWrapper: "BlobWrapper"
            }
        }
    }
}

extension CodeSignatureSuperBlob {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange
        self.magic = try CodeSignatureSuperBlob.Magic(parsing: &input, endianness: .big)
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.count = try UInt32(parsing: &input, endianness: .big)
        self.slots = try Array(parsing: &input, count: Int(self.count)) { input in
            try CodeSignatureSuperBlob.SuperBlobValueSlot(parsing: &input, endianness: .big)
        }
    }
}


// MARK: Deferred parsing
extension CodeSignatureSuperBlob.SuperBlobValueSlot {
    public enum SlotValue: CustomStringConvertible {
        case CodeDirectory(CodeDirectory)
//        case CodeRequirementsValue(CodeRequirements)
//        // case CodeRequirementValue(CodeRequirement)
//        case CodeEntitlementsValue(CodeEntitlements)
//        case CodeEntitlementsDER(CodeEntitlementsDER)
//        case SuperBlob(CodeSignatureSuperBlob)
//        case BlobWrapper(CodeSignatureBlobWrapper)
        
        public var description: String {
            switch self {
            case .CodeDirectory(let cd): return "CodeDirectory: \(cd)"
            }
        }
    }
    
    func getSlot(parsing machoSpan: inout ParserSpan) throws -> SlotValue? {
        try machoSpan.seek(toRelativeOffset: offset)
        
        switch type {
        case .cdCodeDirectorySlot: return SlotValue.CodeDirectory(try CodeDirectory(parsing: &machoSpan, endian: .big))
        default: return nil
        }
    }
}

extension CodeSignatureSuperBlob.SuperBlobValueSlot {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange
        self.type = try CodeSignatureSuperBlob.SuperBlobValueSlot.DirectoryType(parsing: &input, endianness: .big)
        self.offset = try UInt32(parsing: &input, endianness: .big)
    }
}
