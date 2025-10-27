import Foundation
import BinaryParsing



public class MachOFile {
    public let id: UUID = UUID()
    public let url: URL
    public let data: Data
    public let file: BinaryType
    public let range: Range<Int>

    public enum BinaryType: CustomStringConvertible {
        case fat(FatBinary)
        case macho(MachO)

        public var description: String {
            switch self {
            case .fat: "Fat"
            case .macho: "Mach-O"
            }
        }
    }
    
    @CaseName
    public enum Magic: UInt32 {
        case fat = 0xcafebabe
        case fat64 = 0xcafebabf
        case fatSwapped = 0xbebafeca
        case fat64Swapped = 0xbfbafeca
        case macho32 = 0xfeedface
        case macho64 = 0xfeedfacf
        case macho32Swapped = 0xcefaedfe
        case macho64Swapped = 0xcffaedfe

        public var isFat: Bool {
            switch self {
            case .fat, .fat64, .fatSwapped, .fat64Swapped: true
            default: false
            }
        }

        public var is64Bit: Bool {
            switch self {
            case .fat64, .macho64, .macho64Swapped, .fat64Swapped: true
            default: false
            }
        }

        public var isSwapped: Bool {
            switch self {
            case .macho32Swapped, .macho64Swapped, .fatSwapped, .fat64Swapped: true
            default: false
            }
        }
    }

    public init(_ url: URL) throws {
        self.url = url
        self.data = try Data(contentsOf: url)
        self.range = 0..<self.data.count
        
        let magic = try self.data.withParserSpan { input in
            try Magic(parsing: &input, endianness: .little)
        }
        
        switch magic {
        case .fat, .fat64, .fatSwapped, .fat64Swapped:
            self.file = BinaryType.fat(try FatBinary(parsing: data))
        case .macho32, .macho64, .macho32Swapped, .macho64Swapped:
            self.file = BinaryType.macho(try MachO(parsing: data))
        }
    }
}

extension MachOFile: Displayable {
    public var title: String { url.lastPathComponent }
    public var description: String { url.lastPathComponent }
    public var children: [Displayable]? {
        switch file {
            case .fat(let fat): return [fat]
        case .macho(let macho): return [macho]
        }
    }
}


extension MachOFile {
    public func getHash(_ range: Range<Int>, type: CodeSignatureHashType) -> String {
        switch type {
        case .NO_HASH: ""
        case .SHA1: data.subdata(in: range).sha1
        case .SHA256: data.subdata(in: range).sha256
        case .SHA256_TRUNCATED: String(data.subdata(in: range).sha256.prefix(32))
        case .SHA384: data.subdata(in: range).sha384
        case .SHA512: data.subdata(in: range).sha512
        }
    }
    
    public func validateSignature(_ macho: MachO) throws {
        guard
            let (_,signature) = macho.getSignature(),
            let cd = macho.getCodeDirectory()
        else { throw MachOError.invalidSignature }
        
        // Code hashes are calculated by looking at the start of the macho file and
        // calculating a hash for each page size (e.g. 0-4096, 4096-8192)
        // Note that the last hash is limited by the codeLimit value that is the CodeSignatureCodeDirectory
        for hash in cd.codeSlotHashes {
            let range = hash.relativeHashRange + macho.range.lowerBound
            let c_hash = getHash(range, type: cd.hashType)
            
            guard hash.hash == c_hash else { throw MachOError.invalidSignature }
        }
        
        guard
            let value = signature.blobs.first(where: {
                switch $0 {
                case .CodeDirectory(_,_): true
                default: false
                }
            }),
            case let .CodeDirectory(_, d) = value
        else { throw MachOError.invalidSignature }
        
        let c_hash = getHash(d.range, type: cd.hashType)
        // TODO: Need to parse out the CMS signature (CodeSignatureBlobWrapper) to pull out the cdhash from the SignedData
        // guard hash.hash == c_hash else { throw MachOError.invalidSignature }
        print("CDHash: \(d.range) \(c_hash)")
        
        
        for hash in cd.specialSlotHashes {
            // Sometimes the special hashes have all 00s
            if hash.isEmpty {
                continue
            }
            
            switch hash.index {
            case .CodeDirectorySlot: break // This will not be in the list of special indexes.  See above for CDHash verifications.
            case .InfoSlot:
                // TODO: Need to look for LC_SEGMENT_64 -> __TEXT -> __info_plist or "Resources/Info.plist" file
                break
            case .RequirementsSlot:
                guard
                    let value = signature.blobs.first(where: {
                        switch $0 {
                        case .CodeRequirements(_,_): true
                        default: false
                        }
                    }),
                    case let .CodeRequirements(_, req) = value
                else { throw MachOError.invalidSignature }
                
                let c_hash = getHash(req.range, type: cd.hashType)
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
                        case .CodeEntitlements(_,_): true
                        default: false
                        }
                    }),
                    case let .CodeEntitlements(_, er) = value
                else { throw MachOError.invalidSignature }
                
                let c_hash = getHash(er.range, type: cd.hashType)
                guard hash.hash == c_hash else { throw MachOError.invalidSignature }
            case .RepSpecificSlot:
                break
            case .EntitlementDERSlot:
                guard
                    let value = signature.blobs.first(where: {
                        switch $0 {
                        case .CodeEntitlementsDER(_,_): true
                        default: false
                        }
                    }),
                    case let .CodeEntitlementsDER(_, edr) = value
                else { throw MachOError.invalidSignature }
                
                let c_hash = getHash(edr.range, type: cd.hashType)
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
        
        print("Validated signature")
    }
}
