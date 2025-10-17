//
//  CodeDirectory.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//
import Foundation
import BinaryParsing


public struct CodeDirectory: Parseable {
    public let range: Range<Int>
    public let magic: CodeSignatureSuperBlob.Magic
    public let length: UInt32
    public let version: UInt32
    public let flags: UInt32 // TODO:
    public let hashOffset: UInt32
    public let identOffset: UInt32
    public let numSpecialSlots: UInt32
    public let numCodeSlots: UInt32
    public let codeLimit: UInt32
    public let hashSize: UInt8
    public let hashType: UInt8
    public let platform: UInt8
    public let _pageSize: UInt8
    public let unused: UInt32
    
    // Version 0x20100+
    public let scatterOffset: UInt32? = nil
    
    // Version 0x20200+
    public let teamOffset: UInt32? = nil
    
    // Version 0x20300+
    public let unused2: UInt32? = nil
    public let codeLimit64: UInt32? = nil
    
    // Version 0x20400+
    public let execSegHeader: ExecutableSegmentHeader? = nil
    
    // Version 0x20500+
    public let runtimeHeader: RuntimeHeader? = nil
    
    // Version 0x20600+
    public let linkageHeader: LinkageHeader? = nil
    
    
    // Non header items
    public let identifier: String
//    public let specialSlotHashes: [SpecialHash]
//    public let specialSlotHashesRange: Range<Data.Index>
//    public let codeSlotHashes: [CodeHash]
//    public let codeSlotHashesRange: Range<Data.Index>
//    public let scatter: Scatter?
//    public let teamID: String?
//    public var pageSize: Int
    
    public struct ExecutableSegmentHeader {
        public let range: Range<Int>
        public let base: UInt64
        public let limit: UInt64
        public let flags: SecAccessControlCreateFlags
        
        public enum Flags: UInt64, CustomStringConvertible {
            case EXECSEG_MAIN_BINARY = 0x1
            case EXECSEG_ALLOW_UNSIGNED = 0x10
            case EXECSEG_DEBUGGER = 0x20
            case EXECSEG_JIT = 0x40
            case EXECSEG_SKIP_LV = 0x80
            case EXECSEG_CAN_LOAD_CDHASH = 0x100
            case EXECSEG_CAN_EXEC_CDHASH = 0x200
            
            public var description: String {
                switch self {
                case .EXECSEG_MAIN_BINARY: "EXECSEG_MAIN_BINARY"
                case .EXECSEG_ALLOW_UNSIGNED: "EXECSEG_ALLOW_UNSIGNED"
                case .EXECSEG_DEBUGGER: "EXECSEG_DEBUGGER"
                case .EXECSEG_JIT: "EXECSEG_JIT"
                case .EXECSEG_SKIP_LV: "EXECSEG_SKIP_LV"
                case .EXECSEG_CAN_LOAD_CDHASH: "EXECSEG_CAN_LOAD_CDHASH"
                case .EXECSEG_CAN_EXEC_CDHASH: "EXECSEG_CAN_EXEC_CDHASH"
                }
            }
        }
    }
    
    public struct RuntimeHeader: Parseable {
        public let range: Range<Int>
        public let version: UInt32
        public let preEncryptionOffset: UInt32
    }
    
    public struct LinkageHeader: Parseable {
        public let range: Range<Int>
        public let version: UInt32
        public let applicationType: UInt8
        public let applicationSubType: UInt16
        public let offset: UInt32
        public let size: UInt32
    }
    
    public struct Scatter: Parseable {
        public let range: Range<Int>
        public let count: UInt32
        public let base: UInt32
        public let targetOffset: UInt64
        public let reserved: UInt64
    }
    
    public struct CodeLimit64: Parseable {
        public let range: Range<Int>
        public let unused: UInt64
        public let codeLimit64: UInt64
    }
    
    public struct SpecialHash: Parseable {
        public let range: Range<Int>
        public let index: CodeSignatureCodeDirectoryType
        public let data: Data
        
        public var hash: String {
            return data[range].hexDescription
        }
        
        public var isEmpty: Bool {
            return data.isEmpty
        }
    }
    
    public struct CodeHash: Parseable {
        public let index: Int
        public let data: Data
        public let range: Range<Data.Index>
        public let hashRange: Range<Data.Index>
        
        public var hash: String {
            return data[range].hexDescription
        }
    }
}

extension CodeDirectory {
    public init(parsing input: inout ParserSpan, endian: Endianness) throws {
        let start = input.parserRange.lowerBound
        self.magic = try CodeSignatureSuperBlob.Magic(parsing: &input, endianness: endian)
        // TODO: guard to check magic
        self.length = try UInt32(parsing: &input, endianness: endian)
        self.version = try UInt32(parsing: &input, endianness: endian)
        self.flags = try UInt32(parsing: &input, endianness: endian)
        self.hashOffset = try UInt32(parsing: &input, endianness: endian)
        self.identOffset = try UInt32(parsing: &input, endianness: endian)
        self.identifier = try String(parsingNulTerminated: &input)
        self.numSpecialSlots = try UInt32(parsing: &input, endianness: endian)
        self.numCodeSlots = try UInt32(parsing: &input, endianness: endian)
        self.codeLimit = try UInt32(parsing: &input, endianness: endian)
        self.hashSize = try UInt8(parsing: &input)
        self.hashType = try UInt8(parsing: &input)
        self.platform = try UInt8(parsing: &input)
        self._pageSize = try UInt8(parsing: &input)
        self.unused = try UInt32(parsing: &input, endianness: endian)
        self.range = start..<input.parserRange.lowerBound
    }
}
