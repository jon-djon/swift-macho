import BinaryParsing
import Foundation

public struct MachOFile {
    public let id: UUID = UUID()
    public let url: URL
    public let data: Data
    public let file: BinaryType
    public let range: Range<Int>

    public var machos: [MachO] {
        switch file {
        case .fat(let f): f.machos
        case .macho(let m): [m]
        }
    }

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

    public init(_ url: URL) throws {
        self.url = url
        self.data = try Data(contentsOf: url, options: .mappedIfSafe)
        self.range = 0..<self.data.count

        let magic = try self.data.withParserSpan { input in
            try BinaryMagic(parsing: &input, endianness: .little)
        }

        do {
            if magic.isFat {
                self.file = BinaryType.fat(try FatBinary(parsing: data))
            } else {
                self.file = BinaryType.macho(try MachO(parsing: data))
            }
        } catch let e as MachOError {
            throw e
        } catch let e as LoadCommandParsingError {
            throw e
        } catch {
            throw MachOError.parsingError(
                "\(url.lastPathComponent) (magic: \(magic)): \(error)")
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
    public static func isMachoFile(_ path: URL) -> Bool {
        guard let fileHandle = try? FileHandle(forReadingFrom: path) else { return false }

        defer {
            try? fileHandle.close()
        }

        let data = fileHandle.readData(ofLength: 8)

        guard data.count == 8 else { return false }

        let magic = data.withParserSpan { input in
            try? BinaryMagic(parsing: &input, endianness: .big)
        }

        guard
            magic != nil
        else { return false }

        // Java class files also have a magic of 0xBFBAFECA
        // In a class file 4-6 is the minor version & 6-8 is the major version
        // A check below to make sure count is below 0x20 is to make sure it is actually a Macho or Fat Binary
        if magic == .fat {
            let count = try? data.withParserSpan { input in
                try input.seek(toRelativeOffset: 4)
                return try UInt32(parsing: &input, endianness: .big)
            }

            guard
                let count = count,
                count < 0x20
            else { return false }
        }

        return true
    }

    public func getHash(_ range: Range<Int>, type: CodeSignatureHashType) -> String {
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

