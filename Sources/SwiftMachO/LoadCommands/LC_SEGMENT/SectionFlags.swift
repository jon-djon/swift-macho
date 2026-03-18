//
//  SectionFlags.swift
//  swift-macho
//

import BinaryParsing
import Foundation

public struct SectionFlags: CustomStringConvertible, Sendable {
    public let type: SectionType
    public let attributes: SectionAttributes
    public let rawValue: UInt32

    public var description: String {
        var parts: [String] = []
        if type.rawValue != 0 {
            parts.append(type.description)
        } else {
            parts.append("REGULAR")
        }
        if attributes.rawValue != 0 {
            parts.append(attributes.description)
        }
        return parts.joined(separator: ", ")
    }

    @AutoOptionSet
    public struct SectionType: OptionSet, Sendable {
        public static let REGULAR: SectionType = []
        public static let ZERO_FILL = SectionType(rawValue: 0x01)
        public static let CSTRING_LITERALS = SectionType(rawValue: 0x02)
        public static let BYTE_LITERALS4 = SectionType(rawValue: 0x03)
        public static let BYTE_LITERALS8 = SectionType(rawValue: 0x04)
        public static let LITERAL_POINTERS = SectionType(rawValue: 0x05)
        public static let NON_LAZY_SYMBOL_POINTERS = SectionType(rawValue: 0x06)
        public static let LAZY_SYMBOL_POINTERS = SectionType(rawValue: 0x07)
        public static let SYMBOL_STUBS = SectionType(rawValue: 0x08)
        public static let MOD_INIT_FUNC_POINTERS = SectionType(rawValue: 0x09)
        public static let MOD_TERM_FUNC_POINTERS = SectionType(rawValue: 0x0a)
        public static let COALESCED = SectionType(rawValue: 0x0b)
        public static let GB_ZERO_FILL = SectionType(rawValue: 0x0c)
        public static let INTERPOSING = SectionType(rawValue: 0x0d)
        public static let BYTE_LITERALS16 = SectionType(rawValue: 0x0e)
        public static let DTRACE_DOF = SectionType(rawValue: 0x0f)
        public static let LAZY_DYLIB_SYMBOL_POINTERS = SectionType(rawValue: 0x10)
        public static let THREAD_LOCAL_REGULAR = SectionType(rawValue: 0x11)
        public static let THREAD_LOCAL_ZERO_FILL = SectionType(rawValue: 0x12)
        public static let THREAD_LOCAL_VARIABLES = SectionType(rawValue: 0x13)
        public static let THREAD_LOCAL_VARIABLE_POINTERS = SectionType(rawValue: 0x14)
        public static let THREAD_LOCAL_INIT_FUNCTION_POINTERS = SectionType(rawValue: 0x15)
        public static let INIT_FUNC_OFFSETS = SectionType(rawValue: 0x16)
    }

    @AutoOptionSet
    public struct SectionAttributes: OptionSet, Sendable {
        public static let PURE_INSTRUCTIONS = SectionAttributes(rawValue: 0x8000_0000)
        public static let NO_TOC = SectionAttributes(rawValue: 0x4000_0000)
        public static let STRIP_STATIC_SYMS = SectionAttributes(rawValue: 0x2000_0000)
        public static let NO_DEAD_STRIP = SectionAttributes(rawValue: 0x1000_0000)
        public static let LIVE_SUPPORT = SectionAttributes(rawValue: 0x0800_0000)
        public static let SELF_MODIFYING_CODE = SectionAttributes(rawValue: 0x0400_0000)
        public static let DEBUG = SectionAttributes(rawValue: 0x0200_0000)
        public static let SOME_INSTRUCTIONS = SectionAttributes(rawValue: 0x0000_0400)
        public static let EXT_RELOC = SectionAttributes(rawValue: 0x0000_0200)
        public static let LOC_RELOC = SectionAttributes(rawValue: 0x0000_0100)
    }

    public init(rawValue value: UInt32) {
        self.rawValue = value
        self.type = SectionType(rawValue: value & 0x0000_00ff)
        self.attributes = SectionAttributes(rawValue: value & 0xffff_ff00)
    }
    
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        let value = try UInt32(parsing: &input, endianness: endianness)
        self.init(rawValue: value)
    }
}