import Foundation
import BinaryParsing

public struct FatArchive {
    public let cpu: CPU
    public let offset: UInt32
    public let size: UInt32
    public let align: UInt32
    
    public let range: Range<Int>
}

extension FatArchive: ExpressibleByParsing, Parseable {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.parserRange.lowerBound
        
        self.cpu = try CPU(parsing: &input, endianness: .big)
        self.offset = try UInt32(parsing: &input, endianness: .big)
        self.size = try UInt32(parsing: &input, endianness: .big)
        self.align = try UInt32(parsing: &input, endianness: .big)
        self.range = start..<input.parserRange.lowerBound
    }
}

extension FatArchive: Displayable {
    public var title: String { "Fat Archive" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        var fields: [DisplayableField] = [
            .init(label: "CPU", stringValue: cpu.description, offset: 0, size: 8, children: [
                .init(label: "Type", stringValue: cpu.type.description, offset: 0, size: 8, children: nil, obj: self),
                .init(label: "Subtype", stringValue: cpu.subtype.description, offset: 8, size: 8, children: nil, obj: self),
            ], obj: self),
            .init(label: "Offset", stringValue: offset.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: offset.description, offset: 12, size: 4, children: nil, obj: self),
            .init(label: "Align", stringValue: offset.description, offset: 16, size: 4, children: nil, obj: self),
        ]
        return fields
    }
    public var children: [Displayable]? { nil }
}
