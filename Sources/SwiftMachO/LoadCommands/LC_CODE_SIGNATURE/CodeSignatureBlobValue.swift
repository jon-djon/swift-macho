//
//  CodeSignatureBlobValue.swift
//  swift-macho
//
//  Created by jon on 10/23/25.
//

import Foundation
import BinaryParsing

public enum CodeSignatureBlobValue {
    case CodeDirectory(CodeSignatureSuperBlob.Blob, CodeSignatureCodeDirectory)
    case CodeRequirement(CodeSignatureSuperBlob.Blob, CodeSignatureCodeRequirement)
    case CodeRequirements(CodeSignatureSuperBlob.Blob, CodeSignatureCodeRequirements)
    case CodeEntitlements(CodeSignatureSuperBlob.Blob, CodeSignatureCodeEntitlements)
    case CodeEntitlementsDER(CodeSignatureSuperBlob.Blob, CodeSignatureCodeEntitlementsDER)
    case SuperBlob(CodeSignatureSuperBlob.Blob, CodeSignatureSuperBlob)
    case BlobWrapper(CodeSignatureSuperBlob.Blob, CodeSignatureBlobWrapper)
    
    public var description: String {
        switch self {
        case .CodeDirectory(let blob, let cd): "\(blob.description) - (\(cd.description))"
        case .CodeRequirement(let blob, let r): "\(blob.description) - (\(r.description))"
        case .CodeRequirements(let blob, let r): "\(blob.description) - (\(r.description))"
        case .CodeEntitlements(let blob, let e): "\(blob.description) - (\(e.description))"
        case .CodeEntitlementsDER(let blob, let magic): "\(blob.description) - (\(magic.description))"
        case .SuperBlob(let blob, let magic): "\(blob.description) - (\(magic.description))"
        case .BlobWrapper(let blob, let magic): "\(blob.description) - (\(magic.description))"
        }
    }
}

extension CodeSignatureBlobValue {
    public init(parsing input: inout ParserSpan, blob: CodeSignatureSuperBlob.Blob) throws {
        let startPosition = input.startPosition
        let magic: CodeSignatureBlobMagic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        
        // Reset the input
        try input.seek(toAbsoluteOffset: startPosition)
        
        switch magic {
        case .CodeDirectory:
            self = .CodeDirectory(blob, try CodeSignatureCodeDirectory(parsing: &input))
        case .CodeRequirement:
            self = .CodeRequirement(blob, try CodeSignatureCodeRequirement(parsing: &input, type: .DesignatedRequirementType))
        case .CodeRequirements:
            self = .CodeRequirements(blob, try CodeSignatureCodeRequirements(parsing: &input))
        case .CodeEntitlements:
            self = .CodeEntitlements(blob, try CodeSignatureCodeEntitlements(parsing: &input))
        case .CodeEntitlementsDER:
            self = .CodeEntitlementsDER(blob, try CodeSignatureCodeEntitlementsDER(parsing: &input))
        case .SuperBlob:
            self = .SuperBlob(blob, try CodeSignatureSuperBlob(parsing: &input))
        case .BlobWrapper:
            self = .BlobWrapper(blob, try CodeSignatureBlobWrapper(parsing: &input))
        }
    }
}
