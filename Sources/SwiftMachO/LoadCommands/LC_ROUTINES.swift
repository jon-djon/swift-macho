//
//  LC_ROUTINES.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_ROUTINES: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_ROUTINES
    public let header: LoadCommandHeader
    public let initAddress: UInt32   // VM address of init routine
    public let initModule: UInt32    // index into module table
    public let reserved1: UInt32
    public let reserved2: UInt32
    public let reserved3: UInt32
    public let reserved4: UInt32
    public let reserved5: UInt32
    public let reserved6: UInt32
    public let range: Range<Int>
}

extension LC_ROUTINES {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)
        self.initAddress = try UInt32(parsing: &input, endianness: endianness)
        self.initModule = try UInt32(parsing: &input, endianness: endianness)
        self.reserved1 = try UInt32(parsing: &input, endianness: endianness)
        self.reserved2 = try UInt32(parsing: &input, endianness: endianness)
        self.reserved3 = try UInt32(parsing: &input, endianness: endianness)
        self.reserved4 = try UInt32(parsing: &input, endianness: endianness)
        self.reserved5 = try UInt32(parsing: &input, endianness: endianness)
        self.reserved6 = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_ROUTINES: Displayable {
    public var description: String { "Routines" }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Init Address", stringValue: initAddress.hexDescription, size: 4)
        b.add(label: "Init Module", stringValue: initModule.hexDescription, size: 4)
        b.add(label: "Reserved 1", stringValue: reserved1.hexDescription, size: 4)
        b.add(label: "Reserved 2", stringValue: reserved2.hexDescription, size: 4)
        b.add(label: "Reserved 3", stringValue: reserved3.hexDescription, size: 4)
        b.add(label: "Reserved 4", stringValue: reserved4.hexDescription, size: 4)
        b.add(label: "Reserved 5", stringValue: reserved5.hexDescription, size: 4)
        b.add(label: "Reserved 6", stringValue: reserved6.hexDescription, size: 4)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
