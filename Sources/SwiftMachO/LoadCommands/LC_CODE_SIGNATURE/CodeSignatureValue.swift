//
//  CodeSignatureValue.swift
//  swift-macho
//
//  Created by jon on 10/17/25.
//
import Foundation
import BinaryParsing

public enum CodeSignatureValue: CustomStringConvertible {
    case CodeDirectoryValue(CodeDirectory)
    // case CodeRequirementsValue(CodeRequirements) // TODO
    // case CodeRequirementValue(CodeRequirement)
    // case CodeEntitlementsValue(CodeEntitlements) // TODO
    // case CodeEntitlementsDER(CodeEntitlementsDER) // TODO
    case SuperBlob(CodeSignatureSuperBlob)
    // case BlobWrapper(CodeSignatureBlobWrapper) // TODO
    
    public var description: String {
        switch self {
        case .CodeDirectoryValue: return "CodeDirectory"
        // case .CodeRequirementsValue: return "CodeRequirements"
        // case .CodeRequirementValue: return "CodeRequirement"
        // case .CodeEntitlementsValue: return "CodeEntitlements"
        // case .CodeEntitlementsDER: return "CodeEntitlementsDER"
        case .SuperBlob: return "SuperBlob"
        // case .BlobWrapper: return "BlobWrapper"
        }
    }
}

extension CodeSignatureValue {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        let magic = try MachOCodeSignatureMagic(parsing: &input, endianness: endianness)
        
        switch magic {
//        case .BlobWrapper:
//            self = CodeSignatureValue.BlobWrapper(
//                try CodeSignatureBlobWrapper(macho, offset: offset)
//            )
        case .CodeDirectory:
            self = CodeSignatureValue.CodeDirectoryValue(
                try CodeDirectory(parsing: &input)
            )
//        case .CodeRequirement:
//            return MachOCodeSignatureValue2.CodeRequirementValue(
//                try CodeRequirement(macho, offset: offset)
//            )
//        case .CodeRequirements:
//            self = CodeSignatureValue.CodeRequirementsValue(
//                try CodeRequirements(macho, offset: offset)
//            )
//        case .CodeEntitlements:
//            self = CodeSignatureValue.CodeEntitlementsValue(
//                try CodeEntitlements(macho, offset: offset)
//            )
//        case .CodeEntitlementsDER:
//            self = CodeSignatureValue.CodeEntitlementsDER(
//                try SwiftMachO.CodeEntitlementsDER(macho, offset: offset)
//            )
        case .SuperBlob:
            self = CodeSignatureValue.SuperBlob(
                try CodeSignatureSuperBlob(parsing: &input)
            )
        default: throw MachOError.unknownError
        }
    }
}
