//
//  CodeDirectory.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//
import Foundation
import BinaryParsing


public struct CodeSignatureCodeDirectory: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    public let version: UInt32
    public let flags: UInt32 // TODO:
    public let hashOffset: UInt32
    public let identOffset: UInt32
    public let numSpecialSlots: UInt32
    public let numCodeSlots: UInt32
    public let codeLimit: UInt32
    public let hashSize: UInt8
    public let hashType: CodeSignatureHashType
    public let platform: UInt8
    public let pageSize: UInt8
    public let unused: UInt32
    
    // Header Items that are optional based on version
    
    // Version 0x20100+
    public let scatterOffset: UInt32?
    
    // Version 0x20200+
    public let teamOffset: UInt32?
    
    // Version 0x20300+
    public let codeLimit64: CodeLimit64?
    
    // Version 0x20400+
    public let execSegHeader: ExecutableSegmentHeader?
    
    // Version 0x20500+
    public let runtimeHeader: RuntimeHeader?
    
    // Version 0x20600+
    public let linkageHeader: LinkageHeader?
    
    
    // Non header items
    public let identifier: String
    public let specialSlotHashes: [SpecialHash]
    public let codeSlotHashes: [CodeHash]
    public let scatter: Scatter?
    public let teamID: String?
    
    public let range: Range<Int>
    
    public var fullPageSize: Int {
        Int(pow(2.0, Double(pageSize)))
    }
    
    public var specialSlotHashStart: Int {
        codeSlotHashStart - specialSlotHashSize
    }
    
    public var specialSlotHashSize: Int {
        Int(self.numSpecialSlots)*Int(hashSize)
    }
    
    public var codeSlotHashStart: Int {
        range.lowerBound + Int(hashOffset)
    }
    
    public var codeSlotHashSize: Int {
        Int(self.numCodeSlots)*Int(hashSize)
    }
    
    public struct ExecutableSegmentHeader {
        public let base: UInt64
        public let limit: UInt64
        public let flags: Flags
        
        public let range: Range<Int>
        
        @CaseName
        public enum Flags: UInt64 {
            case NONE = 0x0
            case EXECSEG_MAIN_BINARY = 0x1
            case EXECSEG_ALLOW_UNSIGNED = 0x10
            case EXECSEG_DEBUGGER = 0x20
            case EXECSEG_JIT = 0x40
            case EXECSEG_SKIP_LV = 0x80
            case EXECSEG_CAN_LOAD_CDHASH = 0x100
            case EXECSEG_CAN_EXEC_CDHASH = 0x200
        }
    }
    
    public struct RuntimeHeader: Parseable {
        public let version: UInt32
        public let preEncryptionOffset: UInt32
        
        public let range: Range<Int>
    }
    
    public struct LinkageHeader: Parseable {
        public let hashType: CodeSignatureHashType
        public let applicationType: UInt8
        public let applicationSubType: UInt16
        public let offset: UInt32
        public let size: UInt32
        
        public let range: Range<Int>
    }
    
    public struct Scatter: Parseable {
        public let count: UInt32
        public let base: UInt32
        public let targetOffset: UInt64
        public let reserved: UInt64
        
        public let range: Range<Int>
    }
    
    public struct CodeLimit64: Parseable {
        public let unused: UInt32
        public let codeLimit: UInt64
        
        public let range: Range<Int>
    }
    
    public struct SpecialHash: Parseable {
        public let index: CodeSignatureCodeDirectorySlotType
        public let data: Data
        public let range: Range<Int>
        
        public var hash: String {
            return data.hexDescription
        }
        
        public var isEmpty: Bool {
            return data.isEmpty
        }
    }
    
    public struct CodeHash: Parseable {
        public let index: UInt32
        public let data: Data
        public let range: Range<Data.Index>
        
        // Range of the bytes that are used to calculate the hash
        // This is relative to the beginning of the machO
        public let relativeHashRange: Range<Data.Index>
        
        public var hash: String {
            return data.hexDescription
        }
    }
}


extension CodeSignatureCodeDirectory.CodeLimit64 {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        
        self.unused = try UInt32(parsing: &input, endianness: .big)
        self.codeLimit = try UInt64(parsing: &input, endianness: .big)
        
        self.range = start..<start+12
    }
}

extension CodeSignatureCodeDirectory.RuntimeHeader {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        
        self.version = try UInt32(parsing: &input, endianness: .big)
        self.preEncryptionOffset = try UInt32(parsing: &input, endianness: .big)
        
        self.range = start..<start+8
    }
}


extension CodeSignatureCodeDirectory.LinkageHeader {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        
        self.hashType = try CodeSignatureHashType(parsing: &input)
        self.applicationType = try UInt8(parsing: &input)
        self.applicationSubType = try UInt16(parsing: &input, endianness: .big)
        self.offset = try UInt32(parsing: &input, endianness: .big)
        self.size = try UInt32(parsing: &input, endianness: .big)
        
        self.range = start..<start+12
    }
}

extension CodeSignatureCodeDirectory.ExecutableSegmentHeader {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        
        self.base = try UInt64(parsing: &input, endianness: .big)
        self.limit = try UInt64(parsing: &input, endianness: .big)
        self.flags = try CodeSignatureCodeDirectory.ExecutableSegmentHeader.Flags(parsing: &input, endianness: .big)
    }
}

extension CodeSignatureCodeDirectory.Scatter {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        
        self.count = try UInt32(parsing: &input, endianness: .big)
        self.base = try UInt32(parsing: &input, endianness: .big)
        self.targetOffset = try UInt64(parsing: &input, endianness: .big)
        self.reserved = try UInt64(parsing: &input, endianness: .big)
    }
}



extension CodeSignatureCodeDirectory.SpecialHash {
    public init(parsing input: inout ParserSpan, index: UInt32) throws {
        guard let index = CodeSignatureCodeDirectorySlotType(rawValue: index) else {
            throw MachOError.parsingError("Bad Special Hash index")
        }
        
        self.index = index
        self.range = input.parserRange.range
        self.data = Data(parsingRemainingBytes: &input)
    }
}

extension CodeSignatureCodeDirectory.CodeHash {
    public init(parsing input: inout ParserSpan, index: UInt32, relativeHashRange: Range<Data.Index>) throws {
        self.index = index
        self.relativeHashRange = relativeHashRange
        self.range = input.parserRange.range
        self.data = Data(parsingRemainingBytes: &input)
    }
}

extension CodeSignatureCodeDirectory {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .CodeDirectory else {
            throw MachOError.badMagicValue("CodeSignatureCodeDirectory unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.version = try UInt32(parsing: &input, endianness: .big)
        self.flags = try UInt32(parsing: &input, endianness: .big)
        self.hashOffset = try UInt32(parsing: &input, endianness: .big)
        self.identOffset = try UInt32(parsing: &input, endianness: .big)
        self.numSpecialSlots = try UInt32(parsing: &input, endianness: .big)
        self.numCodeSlots = try UInt32(parsing: &input, endianness: .big)
        self.codeLimit = try UInt32(parsing: &input, endianness: .big)
        self.hashSize = try UInt8(parsing: &input)
        self.hashType = try CodeSignatureHashType(parsing: &input)
        self.platform = try UInt8(parsing: &input)  // TODO: Is there an enum for this value?
        self.pageSize = try UInt8(parsing: &input)
        self.unused = try UInt32(parsing: &input, endianness: .big)
        self.range = start..<start+Int(self.length)
        
        // Version 0x20100+ includes scatter_offset UInt32
        if version >= 0x20100 {
            scatterOffset = try UInt32(parsing: &input, endianness: .big)
        } else {
            scatterOffset = nil
        }
        
        // Version 0x20200+ includes team offset UInt32
        if version >= 0x20200 {
            teamOffset = try UInt32(parsing: &input, endianness: .big)
        } else {
            teamOffset = nil
        }
        
        // Version 0x20300+ includes CodeLimit64(unused UInt32 , codelimit64 UInt64)
        if version >= 0x20300 {
            codeLimit64 = try CodeLimit64(parsing: &input)
        } else {
            codeLimit64 = nil
        }
        
        // Version 0x20400+ includes CdExecSeg(ExecSegBase UInt64 , ExecSegLimit UInt64,flags UInt64) // https://github.com/blacktop/go-macho/blob/master/pkg/codesign/types/directory.go#L358
        if version >= 0x20400 {
            execSegHeader = try ExecutableSegmentHeader(parsing: &input)
        } else {
            execSegHeader = nil
        }
        
        // Version 0x20500+ includes RuntimeHeader
        if version >= 0x20500 {
            runtimeHeader = try RuntimeHeader(parsing: &input)
        } else {
            runtimeHeader = nil
        }
        
        // Version 0x20600+ includes LinkageHeader
        if version >= 0x20600 {
            linkageHeader = try LinkageHeader(parsing: &input)
        } else {
            linkageHeader = nil
        }
        
        // Parse items that have offsets below here
        
        try input.seek(toAbsoluteOffset: start+Int(self.identOffset))
        self.identifier = try String(parsingNulTerminated: &input)
        
        if let scatterOffset = self.scatterOffset,
           scatterOffset != 0 {
            // TODO: Need to figure out if this offset if from the start of the macho????
            try input.seek(toAbsoluteOffset: start+Int(scatterOffset))
            self.scatter = try Scatter(parsing: &input)
        } else {
            self.scatter = nil
        }
        
        if let teamOffset = self.teamOffset,
           teamOffset != 0 {
            try input.seek(toAbsoluteOffset: start+Int(teamOffset))
            self.teamID = try String(parsingNulTerminated: &input)
        } else {
            self.teamID = nil
        }
        
        
        // Code Hashes
        let hashSize = Int(self.hashSize)
        var index: UInt32 = 0
        let abosoluteHashOffset = start+Int(self.hashOffset)
        try input.seek(toAbsoluteOffset: abosoluteHashOffset)
        let fullPageSize = Int(pow(2.0, Double(pageSize)))
        let limit = Int(self.codeLimit)
        
        self.codeSlotHashes = try Array(parsing: &input, count: Int(self.numCodeSlots)) { input in
            var span = try input.sliceSpan(byteCount: hashSize)
            
            let start = Int(index)*fullPageSize
            let end = Int(index+1)*fullPageSize > limit ? limit : Int(index+1)*fullPageSize
    
            let hash = try CodeHash(parsing: &span, index: index, relativeHashRange: start..<end)
            index += 1
            return hash
        }
        
        // Special Hashes
        // Have to rollback from the hash offset
        let startSpecialHash = abosoluteHashOffset - (Int(self.numSpecialSlots)*hashSize)
        
        try input.seek(toAbsoluteOffset: startSpecialHash)
        index = self.numSpecialSlots
        var specialSlotHashes = try Array(parsing: &input, count: Int(self.numSpecialSlots)) { input in
            var span = try input.sliceSpan(byteCount: hashSize)
            let hash = try SpecialHash(parsing: &span, index: index)
            index -= 1
            return hash
        }
        // This are in reverse order
        specialSlotHashes.reverse()
        self.specialSlotHashes = specialSlotHashes
        
    }
}

extension CodeSignatureCodeDirectory: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "CodeSignatureCodeDirectory" }
    public var fields: [DisplayableField] {
        var fields: [DisplayableField] =
        [
            .init(label: "Magic", stringValue: magic.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Length", stringValue: length.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Version", stringValue: version.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Flags", stringValue: flags.description, offset: 12, size: 4, children: nil, obj: self),
            .init(label: "Hash Offset", stringValue: hashOffset.description, offset: 16, size: 4, children: nil, obj: self),
            .init(label: "Identifier Offset", stringValue: identOffset.description, offset: 20, size: 4, children: nil, obj: self),
            .init(label: "Number of Special Slots", stringValue: numSpecialSlots.description, offset: 24, size: 4, children: nil, obj: self),
            .init(label: "Number of Code Slots", stringValue: numCodeSlots.description, offset: 28, size: 4, children: nil, obj: self),
            .init(label: "Code Limit", stringValue: codeLimit.description, offset: 32, size: 4, children: nil, obj: self),
            .init(label: "Hash Size", stringValue: hashSize.description, offset: 36, size: 1, children: nil, obj: self),
            .init(label: "Hash Type", stringValue: hashType.description, offset: 37, size: 1, children: nil, obj: self),
            .init(label: "Platform", stringValue: platform.description, offset: 38, size: 1, children: nil, obj: self),
            .init(label: "Page Size", stringValue: "\(pageSize.description) (\(self.fullPageSize.description) bytes)", offset: 39, size: 1, children: nil, obj: self),
            .init(label: "Unused", stringValue: unused.description, offset: 40, size: 4, children: nil, obj: self),
        ]
        
        if let scatterOffset = self.scatterOffset {
            fields.append(.init(label: "Scatter Offset", stringValue: scatterOffset.description, offset: 44, size: 4, children: nil, obj: self))
        }
        
        if let teamOffset = self.teamOffset {
            fields.append(.init(label: "Team ID Offset", stringValue: teamOffset.description, offset: 48, size: 4, children: nil, obj: self))
        }
        
        if let codeLimit64 = self.codeLimit64 {
            fields.append(.init(label: "CodeLimit64.Unused", stringValue: codeLimit64.unused.description, offset: 52, size: 4, children: nil, obj: self))
            fields.append(.init(label: "CodeLimit64.Code Limit", stringValue: codeLimit64.codeLimit.description, offset: 56, size: 8, children: nil, obj: self))
        }
        
        if let execSegHeader = self.execSegHeader {
            fields.append(.init(label: "ExecutableSegmentHeader.Base", stringValue: execSegHeader.base.description, offset: 64, size: 4, children: nil, obj: self))
            fields.append(.init(label: "ExecutableSegmentHeader.Limit", stringValue: execSegHeader.limit.description, offset: 68, size: 4, children: nil, obj: self))
            fields.append(.init(label: "ExecutableSegmentHeader.Flags", stringValue: execSegHeader.flags.description, offset: 72, size: 4, children: nil, obj: self))
        }
        
        if let runtimeHeader = self.runtimeHeader {
            fields.append(.init(label: "RuntimeHeader.Version", stringValue: runtimeHeader.version.description, offset: 76, size: 4, children: nil, obj: self))
            fields.append(.init(label: "RuntimeHeader.Pre Encryption Offset", stringValue: runtimeHeader.preEncryptionOffset.description, offset: 80, size: 4, children: nil, obj: self))
        }
        
        if let linkageHeader = self.linkageHeader {
            fields.append(.init(label: "RuntimeHeader.Version", stringValue: linkageHeader.hashType.description, offset: 84, size: 1, children: nil, obj: self))
            fields.append(.init(label: "RuntimeHeader.Pre Encryption Offset", stringValue: linkageHeader.applicationType.description, offset: 85, size: 1, children: nil, obj: self))
            fields.append(.init(label: "RuntimeHeader.Version", stringValue: linkageHeader.applicationSubType.description, offset: 86, size: 2, children: nil, obj: self))
            fields.append(.init(label: "RuntimeHeader.Pre Encryption Offset", stringValue: linkageHeader.offset.description, offset: 88, size: 4, children: nil, obj: self))
            fields.append(.init(label: "RuntimeHeader.Pre Encryption Offset", stringValue: linkageHeader.size.description, offset: 92, size: 4, children: nil, obj: self))
        }
        
        fields.append(.init(label: "Identifier", stringValue: identifier, offset: Int(identOffset), size: 4, children: nil, obj: self))
        
        if let teamOffset = self.teamOffset,
           let teamID = self.teamID {
            fields.append(.init(label: "Team ID", stringValue: teamID, offset: Int(teamOffset), size: 4, children: nil, obj: self))
        }
        
        fields += [
            .init(label: "Special Slot Hashes", stringValue: specialSlotHashes.count.description, offset: specialSlotHashStart, size: specialSlotHashSize, children: specialSlotHashes.enumerated().map { index, hash in
                    .init(label: "\(((index+1) * -1).description) \(hash.index.description)", stringValue: "\(hashType.description):\(hash.hash)", offset: hash.range.lowerBound, size: Int(hashSize), children: nil, obj: self)
                }, obj: self)
        ]
        
        fields += [
            .init(label: "Code Slot Hashes", stringValue: codeSlotHashes.count.description, offset: specialSlotHashStart, size: codeSlotHashSize, children: codeSlotHashes.enumerated().map { index, hash in
                    .init(label: "Page \(index.description)", stringValue: "\(hashType.description):\(hash.hash)", offset: 0, size: Int(hashSize), children: nil, obj: self)
                }, obj: self)
        ]
        
        return fields
    }
    public var children: [Displayable]? {
        nil
    }
}
