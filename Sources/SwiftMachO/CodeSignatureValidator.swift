import Foundation

public struct CodeSignatureValidator {
    public let machoFile: MachOFile
    public let macho: MachO

    public init(machoFile: MachOFile, macho: MachO) {
        self.machoFile = machoFile
        self.macho = macho
    }

    public func validate() throws {
        guard
            let (_, signature) = macho.getSignature(),
            let cd = macho.getCodeDirectory()
        else { throw MachOError.invalidSignature }

        // Code hashes are calculated by looking at the start of the macho file and
        // calculating a hash for each page size (e.g. 0-4096, 4096-8192)
        // Note that the last hash is limited by the codeLimit value that is the CodeSignatureCodeDirectory
        for hash in cd.codeSlotHashes {
            let range = hash.relativeHashRange + macho.range.lowerBound
            let c_hash = machoFile.getHash(range, type: cd.hashType)

            guard hash.hash == c_hash else { throw MachOError.invalidSignature }
        }

        guard
            let value = signature.blobs.first(where: {
                switch $0 {
                case .CodeDirectory(_, _): true
                default: false
                }
            }),
            case .CodeDirectory(_, let d) = value
        else { throw MachOError.invalidSignature }

        let _ = machoFile.getHash(d.range, type: cd.hashType)
        // TODO: Need to parse out the CMS signature (CodeSignatureBlobWrapper) to pull out the cdhash from the SignedData
        // guard hash.hash == c_hash else { throw MachOError.invalidSignature }

        for hash in cd.specialSlotHashes {
            // Sometimes the special hashes have all 00s
            if hash.isEmpty {
                continue
            }

            switch hash.index {
            case .CodeDirectorySlot: break  // This will not be in the list of special indexes.  See above for CDHash verifications.
            case .InfoSlot:
                // TODO: Need to look for LC_SEGMENT_64 -> __TEXT -> __info_plist or "Resources/Info.plist" file
                break
            case .RequirementsSlot:
                guard
                    let value = signature.blobs.first(where: {
                        switch $0 {
                        case .CodeRequirements(_, _): true
                        default: false
                        }
                    }),
                    case .CodeRequirements(_, let req) = value
                else { throw MachOError.invalidSignature }

                let c_hash = machoFile.getHash(req.range, type: cd.hashType)
                guard hash.hash == c_hash else { throw MachOError.invalidSignature }
            case .ResourceDirSlot:
                // TODO: Need to look for file "_CodeSignature/CodeResources" & hash it
                break
            case .TopDirectorySlot:
                break
            case .EntitlementSlot:
                guard
                    let value = signature.blobs.first(where: {
                        switch $0 {
                        case .CodeEntitlements(_, _): true
                        default: false
                        }
                    }),
                    case .CodeEntitlements(_, let er) = value
                else { throw MachOError.invalidSignature }

                let c_hash = machoFile.getHash(er.range, type: cd.hashType)
                guard hash.hash == c_hash else { throw MachOError.invalidSignature }
            case .RepSpecificSlot:
                break
            case .EntitlementDERSlot:
                guard
                    let value = signature.blobs.first(where: {
                        switch $0 {
                        case .CodeEntitlementsDER(_, _): true
                        default: false
                        }
                    }),
                    case .CodeEntitlementsDER(_, let edr) = value
                else { throw MachOError.invalidSignature }

                let c_hash = machoFile.getHash(edr.range, type: cd.hashType)
                guard hash.hash == c_hash else { throw MachOError.invalidSignature }
            case .LaunchConstraintSelf:
                break
            case .LaunchConstraintParent:
                break
            case .LaunchConstraintResponsible:
                break
            case .AlternateCodeDirectorySlots:
                break
            case .AlternateCodeDirectoryLimit:
                break
            case .SignatureSlot:
                break
            }
        }
    }
}
