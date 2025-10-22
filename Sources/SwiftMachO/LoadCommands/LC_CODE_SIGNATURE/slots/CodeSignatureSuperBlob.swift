//
//  CodeSignatureSuperBlob.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//
import Foundation
import BinaryParsing

public struct CodeSignatureSuperBlob: Parseable {
    public let magic: Magic
    public let length: UInt32
    public let count: UInt32
    public let slots: [SuperBlobValueSlot]
    
    public let range: Range<Int>
    
    
    public struct SuperBlobValueSlot {
        public let range: ParserRange
        public let type: DirectoryType
        public let offset: UInt32
        
        // Deferred parsing
        public var value: SlotValue?
        
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
    
    @CaseName
    public enum Magic: UInt32, CustomStringConvertible {
        case CodeDirectory = 0xFADE0C02
        case CodeRequirement = 0xFADE0C00
        case CodeRequirements = 0xFADE0C01
        case CodeEntitlements = 0xFADE7171
        case CodeCodeEntitlementsDER = 0xFADE7172
        case SuperBlob = 0xFADE0CC0
        case BlobWrapper = 0xFADE0B01
    }
}

extension CodeSignatureSuperBlob {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        self.magic = try CodeSignatureSuperBlob.Magic(parsing: &input, endianness: .big)
        guard magic == .SuperBlob else {
            throw MachOError.badMagicValue("CodeSignatureSuperBlob unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.count = try UInt32(parsing: &input, endianness: .big)
        var slots: [CodeSignatureSuperBlob.SuperBlobValueSlot] = try Array(parsing: &input, count: Int(self.count)) { input in
            try CodeSignatureSuperBlob.SuperBlobValueSlot(parsing: &input, endianness: .big)
        }
        
        for i in slots.indices {
            switch slots[i].type {
            case .cdCodeDirectorySlot:
                try input.seek(toAbsoluteOffset: self.range.lowerBound+Int(slots[i].offset))
                slots[i].value = CodeSignatureSuperBlob.SuperBlobValueSlot.SlotValue.CodeDirectory(try CodeDirectory(parsing: &input))
            default: break
            }
        }
        
        self.slots = slots
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
        case .cdCodeDirectorySlot: return SlotValue.CodeDirectory(try CodeDirectory(parsing: &machoSpan))
        default: return nil
        }
    }
}

extension CodeSignatureSuperBlob.SuperBlobValueSlot {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange
        self.type = try CodeSignatureSuperBlob.SuperBlobValueSlot.DirectoryType(parsing: &input, endianness: .big)
        self.offset = try UInt32(parsing: &input, endianness: .big)
        
        // Should this be where the different slots are parsed?
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
            .init(label: "Slots", stringValue: count.description, offset: 12, size: 8*slots.count,
                  children: slots.enumerated().map { (index: Int, slot: CodeSignatureSuperBlob.SuperBlobValueSlot) in
                          .init(label: "Slot \(index+1)", stringValue: slot.type.description, offset: 12+(index*8), size: 8, children: [
                            .init(label: "Type", stringValue: slot.type.description, offset: 12+(index*8), size: 4, children: nil, obj: self),
                            .init(label: "Offset", stringValue: slot.offset.description, offset: 12+(index*8)+4, size: 4, children: nil, obj: self),
                          ], obj: self)
                  },
                  obj: self
            ),
        ]
    }
    public var children: [Displayable]? {
        slots.compactMap { slot in
            switch slot.value {
            case .CodeDirectory(let cd): cd
            default: nil
            }
        }
    }
}
