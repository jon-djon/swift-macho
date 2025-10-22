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
        
        let (range,magic) = try self.data.withParserSpan { input in
            return (input.parserRange , try Magic(parsing: &input, endianness: .little))
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
    public func getHash(_ range: Range<Int>, type: MachOCodeSignatureHashType) -> String {
        switch type {
        case .NO_HASH: ""
        case .SHA1: data.subdata(in: range).sha1
        case .SHA256: data.subdata(in: range).sha256
        case .SHA256_TRUNCATED: String(data.subdata(in: range).sha256.prefix(32))
        case .SHA384: data.subdata(in: range).sha384
        case .SHA512: data.subdata(in: range).sha512
        }
    }
}
