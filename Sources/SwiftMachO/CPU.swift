import Foundation
import BinaryParsing


public struct CPU: CustomStringConvertible {
    public let type: CPU_TYPE
    public let subtype: UInt32 // TODO
    
    public var description: String {
        "\(type.description) (\(subtype.description))"
    }
    
    @CaseName
    public enum CPU_TYPE: UInt32, CustomStringConvertible {
        case VAX = 1
        case MC68000 = 6
        case X86 = 7
        case X86_64 = 0x1000007
        case MIPS = 8
        case MC98000 = 10
        case HPPA = 11
        case ARM = 12
        case ARM64 = 0x100000C
        case ARM64_32 = 0x200000C
        case MC88000 = 13
        case SPARC = 14
        case I860 = 15
        case ALPHA = 16
        case POWERPC = 18
        case POWERPC_64 = 0x1000012
    }
}

extension CPU {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.type = try CPU_TYPE(parsing: &input, endianness: endianness)
        self.subtype = try UInt32(parsing: &input, endianness: endianness)
    }
}

// TODO: Create enums for CPU_SUBTYPE
// https://github.com/blacktop/go-macho/blob/625bf9e9a2841515b43ff5d23e6d5ffefe8ac462/types/cpu.go
// https://github.com/aaronst/macholibre/blob/master/macholibre/dictionary.py#L331
// https://opensource.apple.com/source/xnu/xnu-4570.41.2/osfmk/mach/machine.h.auto.html
public enum CPU_SUBTYPE: CustomStringConvertible {
    case CPU_TYPE_ANY(Int)
    case CPU_TYPE_VAX(VAX_CPU_SUBTYPE)
    case CPU_TYPE_MC680(MC680_CPU_SUBTYPE)
    case CPU_TYPE_X86(X86_CPU_SUBTYPE)
    case CPU_TYPE_X86_64(X86_CPU_SUBTYPE)  // TODO: It appears that this is wrong CPU_TYPE_X86_64(X86_64_CPU_SUBTYPE), using X86_CPU_SUBTYPE for now
    case CPU_TYPE_MIPS(MIPS_CPU_SUBTYPE)
    case CPU_TYPE_MC98000(MC98000_CPU_SUBTYPE)
    case CPU_TYPE_HPPA(HPPA_CPU_SUBTYPE)
    case CPU_TYPE_ARM(ARM_CPU_SUBTYPE)
    case CPU_TYPE_ARM64(ARM64_CPU_SUBTYPE)
    case CPU_TYPE_ARM64_32(ARM_64_32_CPU_SUBTYPE)
    case CPU_TYPE_MC88000(MC88000_CPU_SUBTYPE)
    case CPU_TYPE_SPARC(SPARC_CPU_SUBTYPE)
    case CPU_TYPE_I860(I860_CPU_SUBTYPE)
    case CPU_TYPE_ALPHA(Int)
    case CPU_TYPE_POWERPC(POWERPC_CPU_SUBTYPE)
    case CPU_TYPE_POWERPC_64(POWERPC_64_CPU_SUBTYPE)
    
    public var description: String {
        switch self {
        case .CPU_TYPE_ANY(let value): "Any \(value.description)"
        case .CPU_TYPE_VAX(let value): value.description
        case .CPU_TYPE_MC680(let value): value.description
        case .CPU_TYPE_X86(let value): value.description
        case .CPU_TYPE_X86_64(let value): value.description
        case .CPU_TYPE_MIPS(let value): value.description
        case .CPU_TYPE_MC98000(let value): value.description
        case .CPU_TYPE_HPPA(let value): value.description
        case .CPU_TYPE_ARM(let value): value.description
        case .CPU_TYPE_ARM64(let value): value.description
        case .CPU_TYPE_ARM64_32(let value): value.description
        case .CPU_TYPE_MC88000(let value): value.description
        case .CPU_TYPE_SPARC(let value): value.description
        case .CPU_TYPE_I860(let value): value.description
        case .CPU_TYPE_ALPHA(let value): value.description
        case .CPU_TYPE_POWERPC(let value): value.description
        case .CPU_TYPE_POWERPC_64(let value): value.description
        }
    }
}

@CaseName
public enum VAX_CPU_SUBTYPE: Int {
    case VaxALL   = 0
    case Vax780   = 1
    case Vax785   = 2
    case Vax750   = 3
    case Vax730   = 4
    case VaxI     = 5
    case VaxII    = 6
    case Vax8200  = 7
    case Vax8500  = 8
    case Vax8600  = 9
    case Vax8650  = 10
    case Vax8800  = 11
    case VaxIII   = 12
}

@CaseName
public enum ARM64_CPU_SUBTYPE: Int {
    case Arm64All = 0
    case Arm64V8  = 1
    case Arm64E   = 2
}

@CaseName
public enum MC680_CPU_SUBTYPE: Int {
    case MC68030 = 1
    case MC68040  = 2
    case MC68030_ONLY   = 3
}

@CaseName
public enum I386_CPU_SUBTYPE: Int {
    case MC68030 = 1
}

@CaseName
public enum X86_CPU_SUBTYPE: Int {
    case ALL = 0
    case X86_ALL = 3
    case X86_ARCH1 = 4
    case X86_586 = 5
    case X86_64_H = 8
    case X86_PENTIUM_M = 9
    case X86_PENTIUM_4 = 10
    case X86_ITANIUM = 11
    case X86_XEON = 12
    case X86_INTEL_FAMILY_MAX = 15
    case X86_PENTPRO = 22
    case X86_PENTIUM_3_M = 24
    case X86_PENTIUM_4_M = 26
    case X86_ITANIUM_2 = 27
    case X86_XEON_MP = 28
    case X86_PENTIUM_3_XEON = 40
    case X86_PENTII_M3 = 54
    case X86_PENTII_M5 = 86
    case X86_CELERON = 103
    case X86_CELERON_MOBILE = 119
    case X86_486SX = 132
}

@CaseName
public enum X86_64_CPU_SUBTYPE: Int {
    case ALL = 0x80000000
    case X86_ALL = 0x80000003
    case X86_ARCH1 = 0x80000004
    case X86_586 = 0x80000005
    case X86_64_H = 0x80000008
    case X86_PENTIUM_M = 0x80000009
    case X86_PENTIUM_4 = 0x8000000A
    case X86_ITANIUM = 0x8000000B
    case X86_XEON = 0x8000000C
    case X86_INTEL_FAMILY_MAX = 0x8000000F
    case X86_PENTPRO = 0x80000016
    case X86_PENTIUM_3_M = 0x80000018
    case X86_PENTIUM_4_M = 0x8000001A
    case X86_ITANIUM_2 = 0x8000001B
    case X86_XEON_MP = 0x8000001C
    case X86_PENTIUM_3_XEON = 0x80000028
    case X86_PENTII_M3 = 0x80000036
    case X86_PENTII_M5 = 0x80000056
    case X86_CELERON = 0x80000067
    case X86_CELERON_MOBILE = 0x80000077
    case X86_486SX = 0x80000084
}

@CaseName
public enum MIPS_CPU_SUBTYPE: Int {
    case ALL = 0
    case R2300 = 1
    case R2600 = 2
    case R2800 = 3
    case R2000a = 4
    case R2000 = 5
    case R3000a = 6
    case R3000 = 7
}

@CaseName
public enum MC98000_CPU_SUBTYPE: Int {
    case MC98000_ALL = 0
    case MC98601 = 1
}

@CaseName
public enum HPPA_CPU_SUBTYPE: Int {
    case HPPA_7100 = 0
    case HPPA_7100LC = 1
}

@CaseName
public enum ARM_CPU_SUBTYPE: Int {
    case ALL = 0
    case V4T = 5
    case V6 = 6
    case V5TEJ = 7
    case XSCALE = 8
    case V7 = 9
    case V7F = 10
    case V7S = 11
    case V7K = 12
    case V8 = 13
    case V6M = 14
    case V7M = 15
    case V7EM = 16
}

@CaseName
public enum ARM_64_CPU_SUBTYPE: Int {
    case ALL = 0
    case V8 = 1
    case E = 2
}

@CaseName
public enum ARM_64_32_CPU_SUBTYPE: Int {
    case ALL = 0
    case V8 = 1
}

@CaseName
public enum MC88000_CPU_SUBTYPE: Int {
    case ALL = 0
    case MC88100 = 1
    case MC88110 = 2
}

@CaseName
public enum SPARC_CPU_SUBTYPE: Int {
    case ALL = 0
}

@CaseName
public enum I860_CPU_SUBTYPE: Int {
    case ALL = 0
    case _860 = 1
}

@CaseName
public enum POWERPC_CPU_SUBTYPE: Int {
    case ALL = 0
    case _601 = 1
    case _602 = 2
    case _603 = 3
    case _603e = 4
    case _603ev = 5
    case _604 = 6
    case _604e = 7
    case _620 = 8
    case _750 = 9
    case _7400 = 10
    case _7450 = 11
    case _970 = 100
}

@CaseName
public enum POWERPC_64_CPU_SUBTYPE: Int {
    case ALL = 2147483648
    case _601 = 2147483649
    case _602 = 2147483650
    case _603 = 2147483651
    case _603e = 2147483652
    case _603ev = 2147483653
    case _604 = 2147483654
    case _604e = 2147483655
    case _620 = 2147483656
    case _750 = 2147483657
    case _7400 = 2147483658
    case _7450 = 2147483659
    case _970 = 2147483748
}
