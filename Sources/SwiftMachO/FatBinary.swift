import Foundation
import BinaryParsing


public enum FatBinaryError: Error, CustomStringConvertible {
    case badMagicValue(UInt32)
    case unknownError

    public var description: String {
        switch self {
        case .badMagicValue(let value):
            return "The file format with magic value '\(value.hexDescription)' is not supported."
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

    @CaseName
    public enum Magic: UInt32, CustomStringConvertible {
        case Fat = 0xcafebabe
        case Fat64 = 0xcafebabf
        case FatSwapped = 0xbebafeca
        case Fat64Swapped = 0xbfbafeca
    }
}

extension FatBinary: ExpressibleByParsing {
    
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        
        self.magic = try FatBinary.Magic(parsing: &input, endianness: .big)
        self.nfatArch = try UInt32(parsing: &input, endianness: .big)
        self.architectures = try Array(parsing: &input, count: Int(self.nfatArch)) { input in
            try FatArchive(parsing: &input)
        }
        
        self.range = start..<input.startPosition
        
        self.machos = try self.architectures.compactMap { arch in
            // Fat Archives can contain files other than macho (e.g. "!<arch>" files)
            guard FatBinary.archiveIsMachO(arch, using: &input) else { return nil }
            
            try input.seek(toAbsoluteOffset: arch.offset)
            var machoSlice = try input.sliceSpan(byteCount: Int(arch.size))
            return try MachO(parsing: &machoSlice)
        }
        
        // TODO: Look into parsing additional types foud in the binary (e.g. "!<arch>" files)
    }
}

extension FatBinary {
    private static func archiveIsMachO(_ archive: FatArchive, using input: inout ParserSpan) -> Bool {
        do {
            try input.seek(toAbsoluteOffset: archive.offset)
            _ = try MachO.Magic(parsing: &input, endianness: .big)
            return true
        } catch {
            return false
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
