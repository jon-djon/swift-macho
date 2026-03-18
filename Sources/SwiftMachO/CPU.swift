import BinaryParsing
import Foundation

private let CPU_SUBTYPE_LIB64: UInt32 = 0x80000000

public struct CPU: CustomStringConvertible {
    public let type: CPU_TYPE
    public let subtype: CPU_SUBTYPE
    public let lib64: Bool

    public var description: String {
        "\(type.description) \(subtype.description)"
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
        case GPU = 0x1000013
        case GPU2 = 0x1000017
    }
}

extension CPU {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.type = try CPU_TYPE(parsing: &input, endianness: endianness)
        let rawSubtype = try UInt32(parsing: &input, endianness: endianness)
        self.lib64 = (rawSubtype & CPU_SUBTYPE_LIB64) != 0
        self.subtype = CPU_SUBTYPE(cpuType: type, rawValue: rawSubtype & ~CPU_SUBTYPE_LIB64)
    }
}

public enum CPU_SUBTYPE: CustomStringConvertible {
    case vax(VAX_CPU_SUBTYPE)
    case mc680(MC680_CPU_SUBTYPE)
    case x86(X86_CPU_SUBTYPE)
    case x86_64(X86_CPU_SUBTYPE)
    case mips(MIPS_CPU_SUBTYPE)
    case mc98000(MC98000_CPU_SUBTYPE)
    case hppa(HPPA_CPU_SUBTYPE)
    case arm(ARM_CPU_SUBTYPE)
    case arm64(ARM64_CPU_SUBTYPE)
    case arm64_32(ARM64_32_CPU_SUBTYPE)
    case mc88000(MC88000_CPU_SUBTYPE)
    case sparc(SPARC_CPU_SUBTYPE)
    case i860(I860_CPU_SUBTYPE)
    case powerpc(POWERPC_CPU_SUBTYPE)
    case powerpc64(POWERPC_CPU_SUBTYPE)
    case gpu(UInt32)
    case gpu2(UInt32)
    case unknown(cpuType: CPU.CPU_TYPE, rawSubtype: UInt32)

    public var description: String {
        switch self {
        case .vax(let v): v.description
        case .mc680(let v): v.description
        case .x86(let v): v.description
        case .x86_64(let v): v.description
        case .mips(let v): v.description
        case .mc98000(let v): v.description
        case .hppa(let v): v.description
        case .arm(let v): v.description
        case .arm64(let v): v.description
        case .arm64_32(let v): v.description
        case .mc88000(let v): v.description
        case .sparc(let v): v.description
        case .i860(let v): v.description
        case .powerpc(let v): v.description
        case .powerpc64(let v): v.description
        case .gpu(let v): "GPU subtype \(v)"
        case .gpu2(let v): "GPU2 subtype \(v)"
        case .unknown(_, let v): "unknown (\(v))"
        }
    }

    init(cpuType: CPU.CPU_TYPE, rawValue: UInt32) {
        let v = Int(rawValue)
        switch cpuType {
        case .VAX:
            self = VAX_CPU_SUBTYPE(rawValue: v).map { .vax($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .MC68000:
            self = MC680_CPU_SUBTYPE(rawValue: v).map { .mc680($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .X86:
            self = X86_CPU_SUBTYPE(rawValue: v).map { .x86($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .X86_64:
            self = X86_CPU_SUBTYPE(rawValue: v).map { .x86_64($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .MIPS:
            self = MIPS_CPU_SUBTYPE(rawValue: v).map { .mips($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .MC98000:
            self = MC98000_CPU_SUBTYPE(rawValue: v).map { .mc98000($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .HPPA:
            self = HPPA_CPU_SUBTYPE(rawValue: v).map { .hppa($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .ARM:
            self = ARM_CPU_SUBTYPE(rawValue: v).map { .arm($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .ARM64:
            self = ARM64_CPU_SUBTYPE(rawValue: v).map { .arm64($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .ARM64_32:
            self = ARM64_32_CPU_SUBTYPE(rawValue: v).map { .arm64_32($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .MC88000:
            self = MC88000_CPU_SUBTYPE(rawValue: v).map { .mc88000($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .SPARC:
            self = SPARC_CPU_SUBTYPE(rawValue: v).map { .sparc($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .I860:
            self = I860_CPU_SUBTYPE(rawValue: v).map { .i860($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .ALPHA:
            self = .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .POWERPC:
            self = POWERPC_CPU_SUBTYPE(rawValue: v).map { .powerpc($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .POWERPC_64:
            self = POWERPC_CPU_SUBTYPE(rawValue: v).map { .powerpc64($0) }
                ?? .unknown(cpuType: cpuType, rawSubtype: rawValue)
        case .GPU:
            self = .gpu(rawValue)
        case .GPU2:
            self = .gpu2(rawValue)
        }
    }
}

// MARK: - Per-architecture subtype enums

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
public enum MC680_CPU_SUBTYPE: Int {
    case MC68030 = 1
    case MC68040  = 2
    case MC68030_ONLY   = 3
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
public enum ARM64_CPU_SUBTYPE: Int {
    case ALL = 0
    case V8 = 1
    case E = 2
}

@CaseName
public enum ARM64_32_CPU_SUBTYPE: Int {
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
