//
//  LC_PREBOUND_DYLIB.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

// https://flylib.com/books/en/3.126.1.96/1/
// Old structure that does not seem to be parsed correctly
// It appears that name is the only field used
// TODO: Look for other examples
public struct LC_PREBOUND_DYLIB: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_PREBOUND_DYLIB
    public let header: LoadCommandHeader
    public let nameOffset: UInt32
    public let name: String

    // public let nmodules: UInt32
    // public let linkedModulesOffset: UInt32
    // public let linkedModules: [Bool]

    public let range: Range<Int>
}

extension LC_PREBOUND_DYLIB {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        self.nameOffset = try UInt32(parsing: &input, endianness: endianness)
        // self.nmodules = try UInt32(parsing: &input, endianness: endianness)
        // self.linkedModulesOffset = try UInt32(parsing: &input, endianness: endianness)

        // Parse the name string at the given offset
        try input.seek(toAbsoluteOffset: self.range.lowerBound)
        try input.seek(toRelativeOffset: self.nameOffset)
        self.name = try String(parsingNulTerminated: &input)

        // Parse the linked_modules bit vector at its offset
        // Each bit represents whether a module is linked (1) or not (0)
        // let moduleCount = Int(self.nmodules)
        // let byteCount = (moduleCount + 7) / 8
        // try input.seek(toAbsoluteOffset: self.range.lowerBound)
        // try input.seek(toRelativeOffset: self.linkedModulesOffset)
        // var modules = [Bool]()
        // modules.reserveCapacity(moduleCount)
        // for byteIndex in 0..<byteCount {
        //     let byte = try UInt8(parsing: &input)
        //     let bitsInThisByte = min(8, moduleCount - byteIndex * 8)
        //     for bit in 0..<bitsInThisByte {
        //         modules.append((byte & (1 << bit)) != 0)
        //     }
        // }
        // self.linkedModules = modules
    }
}

extension LC_PREBOUND_DYLIB: Displayable {
    public var description: String {
        "Specifies a prebound dynamic library and which of its modules are linked by this binary. Prebinding was an optimization (now largely obsolete) where dyld precomputed library load addresses to speed up launch times."
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()
        b.add(label: "Name Offset", stringValue: nameOffset.description, size: 4)
        // b.add(label: "Number of Modules", stringValue: nmodules.description, size: 4)
        // b.add(label: "Linked Modules Offset", stringValue: linkedModulesOffset.description, size: 4)
        b.add(
            label: "Name", stringValue: name, offset: Int(nameOffset), size: name.count)
        // let linkedCount = linkedModules.filter { $0 }.count
        // b.add(
        //     label: "Linked Modules",
        //     stringValue: "\(linkedCount)/\(nmodules) modules linked",
        //     offset: Int(linkedModulesOffset),
        //     size: (Int(nmodules) + 7) / 8)
        return b.build()
    }
    public var children: [Displayable]? { nil }
}
