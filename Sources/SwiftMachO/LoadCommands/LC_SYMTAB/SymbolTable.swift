import BinaryParsing
import Foundation

public struct SymbolTable: Parseable {
    public let symbols: [Symbol]

    public let range: Range<Int>
}

extension SymbolTable {
    public init(
        parsing input: inout ParserSpan, endianness: Endianness, numSymbols: Int,
        is64Bit: Bool = false
    )
        throws
    {
        self.range = input.parserRange.range
        self.symbols = try Array(parsing: &input, count: numSymbols) {
            input in
            var symbolSpan = try input.sliceSpan(
                byteCount: is64Bit ? Symbol.size64 : Symbol.size32)
            print(symbolSpan.startPosition)
            return try Symbol(parsing: &symbolSpan, endianness: endianness, is64it: is64Bit)
        }
    }
}

extension SymbolTable: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        []
    }
    public var children: [Displayable]? { nil }
}
