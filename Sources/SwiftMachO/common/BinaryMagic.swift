import BinaryParsing

/// Consolidated magic number type for all Mach-O and fat binary formats.
/// Replaces the previously separate `MachO.Magic`, `FatBinary.Magic`, and `MachOFile.Magic` types.
@CaseName
public enum BinaryMagic: UInt32 {
    case fat            = 0xCAFE_BABE
    case fat64          = 0xCAFE_BABF
    case fatSwapped     = 0xBEBA_FECA
    case fat64Swapped   = 0xBFBA_FECA
    case macho32        = 0xFEED_FACE
    case macho64        = 0xFEED_FACF
    case macho32Swapped = 0xCEFA_EDFE
    case macho64Swapped = 0xCFFA_EDFE

    public var isFat: Bool {
        switch self {
        case .fat, .fat64, .fatSwapped, .fat64Swapped: true
        default: false
        }
    }

    public var is64Bit: Bool {
        switch self {
        case .fat64, .fat64Swapped, .macho64, .macho64Swapped: true
        default: false
        }
    }

    public var isSwapped: Bool {
        switch self {
        case .fatSwapped, .fat64Swapped, .macho32Swapped, .macho64Swapped: true
        default: false
        }
    }

    /// Endianness of the binary's data fields (not the magic bytes themselves).
    public var endian: Endianness {
        switch self {
        case .macho32Swapped, .macho64Swapped: .little
        default: .big
        }
    }

    /// Size of the Mach-O header that follows the magic (only meaningful for non-fat magics).
    public var headerSize: Int {
        is64Bit ? 28 : 24
    }
}
