//
//  ExportTrieExport.swift
//  swift-macho
//
//  Created by jon on 3/17/26.
//

import Foundation

public struct ExportTrieExport {
    public let name: String
    public let flags: ExportFlags
    public let address: UInt64
    public let importedName: String?

    @AutoOptionSet
    public struct ExportFlags: OptionSet, Sendable {
        public static let KIND_THREAD_LOCAL = ExportFlags(rawValue: 0x01)
        public static let KIND_ABSOLUTE = ExportFlags(rawValue: 0x02)
        public static let WEAK_DEFINITION = ExportFlags(rawValue: 0x04)
        public static let REEXPORT = ExportFlags(rawValue: 0x08)
        public static let STUB_AND_RESOLVER = ExportFlags(rawValue: 0x10)
    }
}

extension ExportTrieExport: Displayable {
    public var range: Range<Int> { 0..<0 }
    public var title: String { "Export" }
    public var description: String { name }
    public var fields: [DisplayableField] {
        var result: [DisplayableField] = [
            .init(
                label: "Name", stringValue: name, offset: 0, size: 0,
                children: nil, obj: self),
            .init(
                label: "Flags", stringValue: flags.description, offset: 0, size: 0,
                children: nil, obj: self),
            .init(
                label: "Address", stringValue: address.hexDescription, offset: 0, size: 0,
                children: nil, obj: self),
        ]
        if let importedName {
            result.append(
                .init(
                    label: "Imported Name", stringValue: importedName, offset: 0, size: 0,
                    children: nil, obj: self))
        }
        return result
    }
    public var children: [Displayable]? { nil }
}
