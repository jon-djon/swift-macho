import BinaryParsing
import Foundation

public struct Symbols {
    public let entries: [ResolvedSymbol]

    public let range: Range<Int>

    public init(range: Range<Int>, entries: [ResolvedSymbol]) {
        self.range = range
        self.entries = entries
    }
}

extension Symbols: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "\(entries.count) symbols" }
    public var fields: [DisplayableField] {
        entries.enumerated().map { index, resolved in
            .init(
                label: "Symbol \(index)", stringValue: resolved.name, offset: 0,
                size: resolved.symbol.size,
                children: resolved.fields, obj: resolved)
        }
    }
    public var children: [Displayable]? { nil }
}
