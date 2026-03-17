//
//  LC_DYLD_EXPORTS_TRIE.swift
//  swift-macho
//
//  Created by jon on 3/17/26.
//

import BinaryParsing
import Foundation
import Testing

@testable import SwiftMachO

struct LC_DYLD_EXPORTS_TRIE_Tests {
    // LC_DYLD_EXPORTS_TRIE header
    // cmd=0x80000033, cmdsize=0x10 (16)
    // offset=0x8148, size=0x30 (48)
    let data = Data([
        0x33, 0x00, 0x00, 0x80,  // cmd = LC_DYLD_EXPORTS_TRIE (0x80000033)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x48, 0x81, 0x00, 0x00,  // offset = 0x8148
        0x30, 0x00, 0x00, 0x00,  // size = 48
    ])

    // Zero offset/size
    let dataEmpty = Data([
        0x33, 0x00, 0x00, 0x80,  // cmd = LC_DYLD_EXPORTS_TRIE (0x80000033)
        0x10, 0x00, 0x00, 0x00,  // cmdsize = 16
        0x00, 0x00, 0x00, 0x00,  // offset = 0
        0x00, 0x00, 0x00, 0x00,  // size = 0
    ])

    // Wrong command ID
    let bad = Data([0x50, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00])

    @Test
    func loadCommandParsing() throws {
        try data.withParserSpan { span in
            let f = try SwiftMachO.LC_DYLD_EXPORTS_TRIE(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_DYLD_EXPORTS_TRIE)
            #expect(f.header.cmdSize == 16)
            #expect(f.range == 0..<16)
            #expect(f.offset == 0x8148)
            #expect(f.size == 0x30)
            #expect(span.count == 0)
        }
    }

    @Test
    func loadCommandEmpty() throws {
        try dataEmpty.withParserSpan { span in
            let f = try SwiftMachO.LC_DYLD_EXPORTS_TRIE(parsing: &span, endianness: .little)
            #expect(f.header.id == .LC_DYLD_EXPORTS_TRIE)
            #expect(f.offset == 0)
            #expect(f.size == 0)
            #expect(span.count == 0)
        }
    }

    @Test
    func loadCommandInvalidID() throws {
        _ = bad.withParserSpan { span in
            #expect(throws: ParsingError.self) {
                _ = try SwiftMachO.LC_DYLD_EXPORTS_TRIE(parsing: &span, endianness: .little)
            }
        }
    }

    // Helper to build ULEB128 encoding of a value
    static func uleb128(_ value: UInt) -> [UInt8] {
        var v = value
        var bytes: [UInt8] = []
        repeat {
            var byte = UInt8(v & 0x7F)
            v >>= 7
            if v != 0 { byte |= 0x80 }
            bytes.append(byte)
        } while v != 0
        return bytes
    }

    // Hand-crafted trie with two symbols: _main and _helper
    //
    // Layout:
    //   [0]  Root: terminalSize=0, childCount=1, edge="_" -> node at offset A
    //   [A]  Node "_": terminalSize=0, childCount=2,
    //          edge "main" -> node at offset B, edge "helper" -> node at offset C
    //   [B]  Node "_main": terminalSize=N, flags=0, addr=0x1000, childCount=0
    //   [C]  Node "_helper": terminalSize=N, flags=0, addr=0x2000, childCount=0
    static var trieData: Data {
        var d = Data()

        // Root node at offset 0
        d.append(0x00)  // terminalSize = 0
        d.append(0x01)  // childCount = 1
        d.append(contentsOf: "_".utf8)
        d.append(0x00)  // edge null terminator
        // child offset will be filled after we know it
        let childOffsetPos = d.count
        d.append(0x00)  // placeholder for child offset

        // Node "_" at current offset
        let nodeUnderscoreOffset = d.count
        d.append(0x00)  // terminalSize = 0
        d.append(0x02)  // childCount = 2

        // edge "main\0" -> node at offset (to be filled)
        d.append(contentsOf: "main".utf8)
        d.append(0x00)
        let mainOffsetPos = d.count
        d.append(0x00)  // placeholder

        // edge "helper\0" -> node at offset (to be filled)
        d.append(contentsOf: "helper".utf8)
        d.append(0x00)
        let helperOffsetPos = d.count
        d.append(0x00)  // placeholder

        // Node "_main"
        let mainNodeOffset = d.count
        let mainAddr = uleb128(0x1000)
        d.append(UInt8(1 + mainAddr.count))  // terminalSize (flags + addr)
        d.append(0x00)  // flags = 0
        d.append(contentsOf: mainAddr)
        d.append(0x00)  // childCount = 0

        // Node "_helper"
        let helperNodeOffset = d.count
        let helperAddr = uleb128(0x2000)
        d.append(UInt8(1 + helperAddr.count))  // terminalSize
        d.append(0x00)  // flags = 0
        d.append(contentsOf: helperAddr)
        d.append(0x00)  // childCount = 0

        // Patch offsets (all fit in single ULEB128 byte)
        d[childOffsetPos] = UInt8(nodeUnderscoreOffset)
        d[mainOffsetPos] = UInt8(mainNodeOffset)
        d[helperOffsetPos] = UInt8(helperNodeOffset)

        return d
    }

    @Test
    func exportTrieTwoSymbols() throws {
        let trie = Self.trieData
        try trie.withParserSpan { span in
            let result = try ExportTrie(parsing: &span)
            #expect(result.exports.count == 2)

            // Sorted alphabetically
            #expect(result.exports[0].name == "_helper")
            #expect(result.exports[0].address == 0x2000)
            #expect(result.exports[0].flags.rawValue == 0)
            #expect(result.exports[0].importedName == nil)

            #expect(result.exports[1].name == "_main")
            #expect(result.exports[1].address == 0x1000)
            #expect(result.exports[1].flags.rawValue == 0)
            #expect(result.exports[1].importedName == nil)
        }
    }

    // Empty trie (just root with no terminal, no children)
    @Test
    func exportTrieEmpty() throws {
        let trie = Data([
            0x00,  // terminalSize = 0
            0x00,  // childCount = 0
        ])
        try trie.withParserSpan { span in
            let result = try ExportTrie(parsing: &span)
            #expect(result.exports.count == 0)
        }
    }

    // Single export at a leaf node
    @Test
    func exportTrieSingleSymbol() throws {
        var d = Data()
        // Root: no terminal, one child
        d.append(0x00)  // terminalSize = 0
        d.append(0x01)  // childCount = 1
        d.append(contentsOf: "_main".utf8)
        d.append(0x00)
        let childOffset = d.count + 1  // +1 for this offset byte itself
        d.append(UInt8(childOffset))

        // Leaf "_main": address = 0x100
        let addr = Self.uleb128(0x100)
        d.append(UInt8(1 + addr.count))  // terminalSize
        d.append(0x00)  // flags = 0
        d.append(contentsOf: addr)
        d.append(0x00)  // childCount = 0

        try d.withParserSpan { span in
            let result = try ExportTrie(parsing: &span)
            #expect(result.exports.count == 1)
            #expect(result.exports[0].name == "_main")
            #expect(result.exports[0].address == 0x100)
        }
    }

    // Re-export: _foo re-exported from ordinal 2 as _bar
    @Test
    func exportTrieReexport() throws {
        var d = Data()
        // Root: no terminal, one child
        d.append(0x00)  // terminalSize = 0
        d.append(0x01)  // childCount = 1
        d.append(contentsOf: "_foo".utf8)
        d.append(0x00)
        let childOffset = d.count + 1
        d.append(UInt8(childOffset))

        // Leaf "_foo": re-export
        // terminal payload: flags(1) + ordinal(1) + "_bar\0"(5) = 7 bytes
        d.append(0x07)  // terminalSize = 7
        d.append(0x08)  // flags = REEXPORT (0x08)
        d.append(0x02)  // ordinal = 2
        d.append(contentsOf: "_bar".utf8)
        d.append(0x00)  // imported name null terminator
        d.append(0x00)  // childCount = 0

        try d.withParserSpan { span in
            let result = try ExportTrie(parsing: &span)
            #expect(result.exports.count == 1)
            #expect(result.exports[0].name == "_foo")
            #expect(result.exports[0].flags.contains(.REEXPORT))
            #expect(result.exports[0].address == 2)  // ordinal
            #expect(result.exports[0].importedName == "_bar")
        }
    }

    // Weak definition
    @Test
    func exportTrieWeakDefinition() throws {
        var d = Data()
        d.append(0x00)  // terminalSize = 0
        d.append(0x01)  // childCount = 1
        d.append(contentsOf: "_weak".utf8)
        d.append(0x00)
        let childOffset = d.count + 1
        d.append(UInt8(childOffset))

        let addr = Self.uleb128(0x100)
        d.append(UInt8(1 + addr.count))  // terminalSize
        d.append(0x04)  // flags = WEAK_DEFINITION
        d.append(contentsOf: addr)
        d.append(0x00)  // childCount = 0

        try d.withParserSpan { span in
            let result = try ExportTrie(parsing: &span)
            #expect(result.exports.count == 1)
            #expect(result.exports[0].name == "_weak")
            #expect(result.exports[0].flags.contains(.WEAK_DEFINITION))
            #expect(result.exports[0].address == 0x100)
            #expect(result.exports[0].importedName == nil)
        }
    }

    // Integration test against a real binary
    @Test
    func exportTrieFromTestBinary() throws {
        let url = URL(
            fileURLWithPath:
                "/Users/jon/Library/Developer/Xcode/DerivedData/MachOExplorer-exefoinxhmtwvkbuzqysdgfczyht/Build/Products/Debug/MachOExplorer.app/Contents/Resources/TestBinary"
        )
        let machoFile = try MachOFile(url)
        let macho = machoFile.machos[0]

        let exportsTrie = macho.loadCommands.compactMap { cmd -> ExportTrie? in
            if case .LC_DYLD_EXPORTS_TRIE(_, let trie) = cmd {
                return trie
            }
            return nil
        }.first

        let trie = try #require(exportsTrie)
        #expect(trie.exports.count == 2)

        let mainExport = trie.exports.first { $0.name == "_main" }
        let mhExport = trie.exports.first { $0.name == "__mh_execute_header" }

        #expect(mainExport != nil)
        #expect(mainExport?.address != 0)
        #expect(mainExport?.flags.rawValue == 0)

        #expect(mhExport != nil)
        #expect(mhExport?.address == 0)
    }
}
