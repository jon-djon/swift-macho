import Foundation
import BinaryParsing


public struct CPU: CustomStringConvertible {
    public let type: CPU_TYPE
    public let subtype: UInt32 // TODO
    
    public var description: String {
        "\(type.description) (\(subtype.description))"
    }
    
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
        
        public var description: String {
            switch self {
            case .VAX: "VAX"
            case .MC68000: "MC68000"
            case .X86: "X86"
            case .X86_64: "X86_64"
            case .MIPS: "MIPS"
            case .MC98000: "MC98000"
            case .HPPA: "HPPA"
            case .ARM: "ARM"
            case .ARM64: "ARM64"
            case .ARM64_32: "ARM64_32"
            case .MC88000: "MC88000"
            case .SPARC: "SPARC"
            case .I860: "I860"
            case .ALPHA: "ALPHA"
            case .POWERPC: "POWERPC"
            case .POWERPC_64: "POWERPC_64"
            }
        }
        
    }
}

extension CPU {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.type = try CPU_TYPE(parsing: &input, endianness: endianness)
        self.subtype = try UInt32(parsing: &input, endianness: endianness)
    }
}
