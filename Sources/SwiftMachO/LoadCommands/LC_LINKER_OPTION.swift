//
//  LC_LINKER_OPTION.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_LINKER_OPTION: LoadCommand {
    public let header: LoadCommandHeader
    public let count: UInt32
    public let options: [(offset:Int,option:String)]  // Storing the offset and the option
    
    public let range: Range<Int>
    
}

extension LC_LINKER_OPTION {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_LINKER_OPTION else {
            throw MachOError.LoadCommandError("Invalid LC_LINKER_OPTION")
        }
        
        self.count = try UInt32(parsing: &input, endianness: endianness)
        self.options = try Array(parsing: &input, count: Int(self.count)) { input in
            (input.startPosition, try String(parsingNulTerminated: &input))
        }
    }
}

extension LC_LINKER_OPTION: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Option Count", stringValue: count.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Options", stringValue: "\(count.description) Options", offset: 8, size: 4,
                  children: options.enumerated().map { index,option in
                          .init(label: "Option \(index)", stringValue: option.option, offset: option.offset, size: 4, children: nil, obj: self)
                  },
                  obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
