import Foundation
import BinaryParsing


public enum FatBinaryError: Error, CustomStringConvertible {
    case badMagicValue(UInt32)
    case unknownError

    public var description: String {
        switch self {
        case .badMagicValue(let value):
            return "The file format with magic value '\(value.hex)' is not supported."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

public struct FatBinary: Parseable {
    public let magic: FatBinary.Magic
    public let nfatArch: UInt32
    public let architectures: [FatArchive]
    public let machos: [MachO]
    
    public var range: Range<Int>

    public enum Magic: UInt32, CustomStringConvertible {
        case fat = 0xcafebabe
        case fat64 = 0xcafebabf
        case fatSwapped = 0xbebafeca
        case fat64Swapped = 0xbfbafeca

        public var description: String {
            switch self {
            case .fat: return "Fat"
            case .fat64: return "Fat64"
            case .fatSwapped: return "FatSwapped"
            case .fat64Swapped: return "Fat64Swapped"
            }
        }
    }
}

extension FatBinary: ExpressibleByParsing {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.parserRange.lowerBound
        
        self.magic = try FatBinary.Magic(parsingBigEndian: &input)
        self.nfatArch = try UInt32(parsingBigEndian: &input)
        self.architectures = try Array(parsing: &input, count: Int(self.nfatArch)) { input in
            try FatArchive(parsing: &input)
        }
        
        self.range = start..<input.parserRange.lowerBound
        
        self.machos = try self.architectures.map { arch in
            try input.seek(toAbsoluteOffset: arch.offset)
            var machoSlice = try input.sliceSpan(byteCount: Int(arch.size))
            return try MachO(parsing: &machoSlice)
        }
    }
}   

extension FatBinary: Displayable {
    public var title: String { "Fat Binary" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Magic", stringValue: magic.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Number of Archives", stringValue: nfatArch.description, offset: 8, size: 4,
                  children: architectures.enumerated().map { (index: Int, archive: FatArchive) in
                          .init(label: "Archive \(index.description)", stringValue: "", offset: 12+(index*20), size: 20, children: archive.fields, obj: self)
                  },
                  obj: self
            )
        ]
    }
    public var children: [Displayable]? { machos }
}
