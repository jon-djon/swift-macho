//
//  CodeSignatureTypes.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation


public enum MachOCodeSignatureMagic: UInt32, CustomStringConvertible {
    case CodeDirectory = 0xFADE0C02
    // case CodeRequirement = 0xFADE0C00
    case CodeRequirements = 0xFADE0C01
    case CodeEntitlements = 0xFADE7171
    case CodeEntitlementsDER = 0xFADE7172
    case SuperBlob = 0xFADE0CC0
    case BlobWrapper = 0xFADE0B01
    
    
    public var description: String {
        switch self {
        case .CodeDirectory: return "CodeDirectory"
        // case .CodeRequirement: return "CodeRequirement"
        case .CodeRequirements: return "CodeRequirements"
        case .CodeEntitlements: return "CodeEntitlements"
        case .CodeEntitlementsDER: return "CodeEntitlementsDER"
        case .SuperBlob: return "SuperBlob"
        case .BlobWrapper: return "BlobWrapper"
        }
    }
}

public enum MachOCodeSignatureHashType: UInt8, CustomStringConvertible {
    case NO_HASH = 0
    case SHA1 = 1
    case SHA256 = 2
    case SHA256_TRUNCATED = 3
    case SHA384 = 4
    case SHA512 = 5

    public var description: String {
        switch self {
        case .NO_HASH: return "NO_HASH (\(rawValue.description))"
        case .SHA1: return "SHA1 (\(rawValue.description))"
        case .SHA256: return "SHA256 (\(rawValue.description))"
        case .SHA256_TRUNCATED: return "SHA256_TRUNCATED (\(rawValue.description))"
        case .SHA384: return "SHA384 (\(rawValue.description))"
        case .SHA512: return "SHA512 (\(rawValue.description))"
        }
    }
    
    public var label: String {
        switch self {
        case .NO_HASH: return "NO_HASH"
        case .SHA1: return "SHA1"
        case .SHA256: return "SHA256"
        case .SHA256_TRUNCATED: return "SHA256_TRUNCATED"
        case .SHA384: return "SHA384"
        case .SHA512: return "SHA512"
        }
    }
}



// https://github.com/apple/llvm-project/blob/4156d51ba7021cdcf016ec1af6f5f296e43f82d6/llvm/include/llvm/BinaryFormat/MachO.h#L2215
// https://opensource.apple.com/source/xnu/xnu-4570.61.1/osfmk/kern/cs_blobs.h.auto.html
public struct MachOCodeSignatureCodeDirectoryFlags: OptionSet, CustomStringConvertible {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    //  public static let NONE:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000000) }
    public static var CS_VALID:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000001) }
    public static var CS_ADHOC:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000002) }
    public static var CS_GET_TASK_ALLOW:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000004) }
    public static var CS_INSTALLER:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000008) }
    public static var CS_FORCED_LV:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000010) }
    public static var CS_INVALID_ALLOWED:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000020) }
    public static var CS_HARD:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000100) }
    public static var CS_KILL:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000200) }
    public static var CS_CHECK_EXPIRATION:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000400) }
    public static var CS_RESTRICT:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000800) }
    public static var CS_ENFORCEMENT:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00001000) }
    public static var CS_REQUIRE_LV:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00002000) }
    public static var CS_ENTITLEMENTS_VALIDATED:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00004000) }
    public static var CS_NVRAM_UNRESTRICTED:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00008000) }
    public static var CS_RUNTIME:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00010000) }// Hardened Runtime
    public static var CS_LINKER_SIGNED:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x20000) }
    
    // ADHOC | HARD | KILL | CHECK_EXPIRATION | RESTRICT | ENFORCEMENT | REQUIRE_LV | RUNTIME
    public static var CS_ALLOWED_MACHO:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000002 | 0x00000100 | 0x00000200 | 0x00000400 | 0x00000800 | 0x00001000 | 0x00002000 | 0x00010000) }

    public static var CS_EXEC_SET_HARD:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00100000) }
    public static var CS_EXEC_SET_KILL:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00200000) }
    public static var CS_EXEC_SET_ENFORCEMENT:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00400000) }
    public static var CS_EXEC_INHERIT_SIP:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00800000) }
    public static var CS_KILLED:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x01000000) }
    public static var CS_DYLD_PLATFORM:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x02000000) }
    public static var CS_PLATFORM_BINARY:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x04000000) }
    public static var CS_PLATFORM_PATH:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x08000000) }
    public static var CS_DEBUGGED:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x10000000) }
    public static var CS_SIGNED:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x20000000) }
    public static var CS_DEV_CODE:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x40000000) }
    public static var CS_DATAVAULT_CONTROLLER:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x80000000) }
        
        // GET_TASK_ALLOW | INSTALLER | DATAVAULT_CONTROLLER | NVRAM_UNRESTRICTED
    public static var CS_ENTITLEMENT_FLAGS:  MachOCodeSignatureCodeDirectoryFlags  { .init(rawValue: 0x00000004 | 0x00000008 | 0x80000000 | 0x00008000) }

    static public var debugDescriptions: [(Self, String)] {[
        // (.NONE, "NONE"),
        (.CS_VALID, "CS_VALID"),
        (.CS_ADHOC, "CS_ADHOC"),
        (.CS_GET_TASK_ALLOW, "CS_GET_TASK_ALLOW"),
        (.CS_INSTALLER, "CS_INSTALLER"),
        (.CS_FORCED_LV, "CS_FORCED_LV"),
        (.CS_INVALID_ALLOWED, "CS_INVALID_ALLOWED"),
        (.CS_HARD, "CS_HARD"),
        (.CS_KILL, "CS_KILL"),
        (.CS_CHECK_EXPIRATION, "CS_CHECK_EXPIRATION"),
        (.CS_RESTRICT, "CS_RESTRICT"),
        (.CS_ENFORCEMENT, "CS_ENFORCEMENT"),
        (.CS_REQUIRE_LV, "CS_REQUIRE_LV"),
        (.CS_ENTITLEMENTS_VALIDATED, "CS_ENTITLEMENTS_VALIDATED"),
        (.CS_NVRAM_UNRESTRICTED, "CS_NVRAM_UNRESTRICTED"),
        (.CS_RUNTIME, "CS_RUNTIME"),
        (.CS_LINKER_SIGNED, "CS_LINKER_SIGNED"),
        (.CS_ALLOWED_MACHO, "CS_ALLOWED_MACHO"),
        (.CS_EXEC_SET_HARD, "CS_EXEC_SET_HARD"),
        (.CS_EXEC_SET_KILL, "CS_EXEC_SET_KILL"),
        (.CS_EXEC_SET_ENFORCEMENT, "CS_EXEC_SET_ENFORCEMENT"),
        (.CS_EXEC_INHERIT_SIP, "CS_EXEC_INHERIT_SIP"),
        (.CS_KILLED, "CS_KILLED"),
        (.CS_DYLD_PLATFORM, "CS_DYLD_PLATFORM"),
        (.CS_PLATFORM_BINARY, "CS_PLATFORM_BINARY"),
        (.CS_PLATFORM_PATH, "CS_PLATFORM_PATH"),
        (.CS_DEBUGGED, "CS_DEBUGGED"),
        (.CS_SIGNED, "CS_SIGNED"),
        (.CS_DEV_CODE, "CS_DEV_CODE"),
        (.CS_DATAVAULT_CONTROLLER, "CS_DATAVAULT_CONTROLLER"),
        (.CS_ENTITLEMENT_FLAGS, "CS_ENTITLEMENT_FLAGS"),
    ]}
    
    public var flags: [(Self, String)] {
        Self.debugDescriptions.filter { contains($0.0) }
    }
    
    public var descriptionList: [String] {
        Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
    }
    
    public var description: String {
        return "(\(descriptionList.joined(separator: ",")))"
    }
}


// https://github.com/apple-oss-distributions/Security/blob/main/OSX/libsecurity_codesigning/lib/codedirectory.h
public enum CodeSignatureCodeDirectoryType: UInt32, CustomStringConvertible {
    case cdCodeDirectorySlot = 0
    case cdInfoSlot = 1
    case cdRequirementsSlot = 2
    case cdResourceDirSlot = 3
    case cdTopDirectorySlot = 4
    case cdEntitlementSlot = 5
    case cdRepSpecificSlot = 6
    case cdEntitlementDERSlot = 7
    case cdLaunchConstraintSelf = 8
    case cdLaunchConstraintParent = 9
    case cdLaunchConstraintResponsible = 10
    case cdAlternateCodeDirectorySlots = 0x1000
    case cdAlternateCodeDirectoryLimit = 0x1005
    case cdSignatureSlot = 0x10000
    
    public var description: String {
        switch self {
        case .cdCodeDirectorySlot: return "CodeDirectorySlot"
        case .cdInfoSlot: return "InfoSlot"
        case .cdRequirementsSlot: return "RequirementsSlot"
        case .cdResourceDirSlot: return "ResourceDirSlot"
        case .cdTopDirectorySlot: return "TopDirectorySlot"
        case .cdEntitlementSlot: return "EntitlementSlot"
        case .cdRepSpecificSlot: return "RepSpecificSlot"
        case .cdEntitlementDERSlot: return "EntitlementDERSlot"
        case .cdLaunchConstraintSelf: return "LaunchConstraintSelf"
        case .cdLaunchConstraintParent: return "LaunchConstraintParent"
        case .cdLaunchConstraintResponsible: return "LaunchConstraintResponsible"
        case .cdAlternateCodeDirectorySlots: return "AlternateCodeDirectorySlots"
        case .cdAlternateCodeDirectoryLimit: return "AlternateCodeDirectoryLimit"
        case .cdSignatureSlot: return "SignatureSlot"
        }
    }
}

