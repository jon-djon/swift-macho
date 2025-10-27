//
//  CodeSignatureTypes.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation

@CaseName
public enum CodeSignatureBlobMagic: UInt32 {
    case CodeDirectory = 0xFADE0C02
    case CodeRequirement = 0xFADE0C00
    case CodeRequirements = 0xFADE0C01
    case CodeEntitlements = 0xFADE7171
    case CodeEntitlementsDER = 0xFADE7172
    case SuperBlob = 0xFADE0CC0
    case BlobWrapper = 0xFADE0B01
}

@CaseName
public enum CodeSignatureHashType: UInt8 {
    case NO_HASH = 0
    case SHA1 = 1
    case SHA256 = 2
    case SHA256_TRUNCATED = 3
    case SHA384 = 4
    case SHA512 = 5
}



// https://github.com/apple/llvm-project/blob/4156d51ba7021cdcf016ec1af6f5f296e43f82d6/llvm/include/llvm/BinaryFormat/MachO.h#L2215
// https://opensource.apple.com/source/xnu/xnu-4570.61.1/osfmk/kern/cs_blobs.h.auto.html
@AutoOptionSet
public struct MachOCodeSignatureCodeDirectoryFlags: OptionSet, Sendable {
    //  public static let NONE = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000000)
    public static let CS_VALID = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000001)
    public static let CS_ADHOC = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000002)
    public static let CS_GET_TASK_ALLOW = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000004)
    public static let CS_INSTALLER = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000008)
    public static let CS_FORCED_LV = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000010)
    public static let CS_INVALID_ALLOWED = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000020)
    public static let CS_HARD = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000100)
    public static let CS_KILL = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000200)
    public static let CS_CHECK_EXPIRATION = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000400)
    public static let CS_RESTRICT = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000800)
    public static let CS_ENFORCEMENT = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00001000)
    public static let CS_REQUIRE_LV = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00002000)
    public static let CS_ENTITLEMENTS_VALIDATED = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00004000)
    public static let CS_NVRAM_UNRESTRICTED = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00008000)
    public static let CS_RUNTIME = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00010000) // Hardened Runtime
    public static let CS_LINKER_SIGNED = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x20000)
    
    // ADHOC | HARD | KILL | CHECK_EXPIRATION | RESTRICT | ENFORCEMENT | REQUIRE_LV | RUNTIME
    public static let CS_ALLOWED_MACHO = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000002 | 0x00000100 | 0x00000200 | 0x00000400 | 0x00000800 | 0x00001000 | 0x00002000 | 0x00010000)

    public static let CS_EXEC_SET_HARD = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00100000)
    public static let CS_EXEC_SET_KILL = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00200000)
    public static let CS_EXEC_SET_ENFORCEMENT = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00400000)
    public static let CS_EXEC_INHERIT_SIP = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00800000)
    public static let CS_KILLED = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x01000000)
    public static let CS_DYLD_PLATFORM = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x02000000)
    public static let CS_PLATFORM_BINARY = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x04000000)
    public static let CS_PLATFORM_PATH = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x08000000)
    public static let CS_DEBUGGED = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x10000000)
    public static let CS_SIGNED = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x20000000)
    public static let CS_DEV_CODE = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x40000000)
    public static let CS_DATAVAULT_CONTROLLER = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x80000000)
        
        // GET_TASK_ALLOW | INSTALLER | DATAVAULT_CONTROLLER | NVRAM_UNRESTRICTED
    public static let CS_ENTITLEMENT_FLAGS = MachOCodeSignatureCodeDirectoryFlags(rawValue: 0x00000004 | 0x00000008 | 0x80000000 | 0x00008000)
}


// https://github.com/apple-oss-distributions/Security/blob/main/OSX/libsecurity_codesigning/lib/codedirectory.h
@CaseName
public enum CodeSignatureCodeDirectoryType: UInt32 {
    case CodeDirectorySlot = 0
    case InfoSlot = 1
    case RequirementsSlot = 2
    case ResourceDirSlot = 3
    case TopDirectorySlot = 4
    case EntitlementSlot = 5
    case RepSpecificSlot = 6
    case EntitlementDERSlot = 7
    case LaunchConstraintSelf = 8
    case LaunchConstraintParent = 9
    case LaunchConstraintResponsible = 10
    case AlternateCodeDirectorySlots = 0x1000
    case AlternateCodeDirectoryLimit = 0x1005
    case SignatureSlot = 0x10000
}

