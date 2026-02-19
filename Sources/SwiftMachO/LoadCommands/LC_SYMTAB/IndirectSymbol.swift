import BinaryParsing
import Foundation

/// A single entry in the indirect symbol table (LC_DYSYMTAB `indirectsymoff`).
///
/// Each entry is a 4-byte value that is either an index into the LC_SYMTAB
/// symbol table, or one of two sentinel values for local/absolute symbols.
public struct IndirectSymbol: Parseable {
    /// Sentinel: the symbol is local to the translation unit (no symbol table lookup needed).
    public static let INDIRECT_SYMBOL_LOCAL: UInt32 = 0x8000_0000
    /// Sentinel: the symbol is absolute (no symbol table lookup needed).
    public static let INDIRECT_SYMBOL_ABS: UInt32 = 0x4000_0000

    /// Raw 32-bit value as stored in the indirect symbol table.
    public let value: UInt32
    public let range: Range<Int>

    /// True when the entry is a local-symbol sentinel.
    public var isLocal: Bool { value == Self.INDIRECT_SYMBOL_LOCAL }
    /// True when the entry is an absolute-symbol sentinel.
    public var isAbsolute: Bool { value == Self.INDIRECT_SYMBOL_ABS }

    /// Index into the LC_SYMTAB `nlist` array, or `nil` for sentinel values.
    public var symbolTableIndex: UInt32? {
        guard !isLocal && !isAbsolute else { return nil }
        return value
    }
}

extension IndirectSymbol {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        self.value = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension IndirectSymbol: Displayable {
    public var title: String { "IndirectSymbol" }
    public var description: String {
        if isLocal { return "Local" }
        if isAbsolute { return "Absolute" }
        return "Symbol[\(value)]"
    }
    public var fields: [DisplayableField] {
        [.init(label: "Value", stringValue: description, offset: 0, size: 4, children: nil, obj: self)]
    }
    public var children: [Displayable]? { nil }
}
