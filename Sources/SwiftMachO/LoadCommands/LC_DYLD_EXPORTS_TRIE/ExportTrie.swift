//
//  ExportTrie.swift
//  swift-macho
//
//  Created by jon on 3/17/26.
//

import BinaryParsing
import Foundation

public struct ExportTrie: Parseable {
    public let exports: [ExportTrieExport]
    public let range: Range<Int>
}

extension ExportTrie {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        let startPosition = input.parserRange.lowerBound

        var exports: [ExportTrieExport] = []
        // Stack: (nodeOffset from start of trie, accumulated symbol prefix)
        var stack: [(offset: Int, prefix: String)] = [(0, "")]

        while let (nodeOffset, prefix) = stack.popLast() {
            try input.seek(toAbsoluteOffset: startPosition + nodeOffset)

            let terminalSize = try UInt(parsingLEB128: &input)

            if terminalSize > 0 {
                let flagsRaw = try UInt(parsingLEB128: &input)
                let flags = ExportTrieExport.ExportFlags(rawValue: UInt32(flagsRaw))

                if flags.contains(.REEXPORT) {
                    let ordinal = UInt64(try UInt(parsingLEB128: &input))
                    let importedName = try String(parsingNulTerminated: &input)
                    exports.append(ExportTrieExport(
                        name: prefix, flags: flags, address: ordinal,
                        importedName: importedName.isEmpty ? nil : importedName))
                } else if flags.contains(.STUB_AND_RESOLVER) {
                    let stubOffset = UInt64(try UInt(parsingLEB128: &input))
                    _ = try UInt(parsingLEB128: &input)  // resolver offset
                    exports.append(ExportTrieExport(
                        name: prefix, flags: flags, address: stubOffset,
                        importedName: nil))
                } else {
                    let symbolOffset = UInt64(try UInt(parsingLEB128: &input))
                    exports.append(ExportTrieExport(
                        name: prefix, flags: flags, address: symbolOffset,
                        importedName: nil))
                }

                // Seek past terminal info to reach children
                // Re-seek to node start, skip the terminal size ULEB, then skip terminalSize bytes
                try input.seek(toAbsoluteOffset: startPosition + nodeOffset)
                _ = try UInt(parsingLEB128: &input)  // re-read terminal size
                try input.seek(toRelativeOffset: Int(terminalSize))
            }

            let childCount = try UInt8(parsing: &input)

            for _ in 0..<childCount {
                let edgeLabel = try String(parsingNulTerminated: &input)
                let childOffset = Int(try UInt(parsingLEB128: &input))
                stack.append((childOffset, prefix + edgeLabel))
            }
        }

        self.exports = exports.sorted { $0.name < $1.name }
    }
}

extension ExportTrie: Displayable {
    public var title: String { "Export Trie" }
    public var description: String { "\(exports.count) exported symbols" }
    public var fields: [DisplayableField] {
        [
            .init(
                label: "Exports", stringValue: "\(exports.count) symbols", offset: 0,
                size: range.count,
                children: exports.enumerated().map { index, export_ in
                    .init(
                        label: "[\(index)]", stringValue: export_.name, offset: 0, size: 0,
                        children: export_.fields, obj: export_)
                }, obj: self)
        ]
    }
    public var children: [Displayable]? { nil }
}
