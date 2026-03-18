//
//  CodeEntitlements.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//
import Foundation
import BinaryParsing


public struct CodeSignatureCodeEntitlements: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    public let entitlements: [String:Any]
    
    public let range: Range<Int>
    
    public var description: String {
        "CodeSignatureCodeEntitlements (\(keys.joined(separator: ",")))"
    }
    
    public var keys: [String] {
        Array(entitlements.keys)
    }
}


extension CodeSignatureCodeEntitlements {
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .CodeEntitlements else {
            throw MachOError.badMagicValue("CodeSignatureCodeEntitlements unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        let data = try Data(parsing: &input, byteCount: Int(self.length))
        
        guard
            let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil),
            let entitlements = plist as? [String: AnyObject]
        else { throw MachOError.parsingError("MachOSignatureValue.CodeEntitlementsValue") }
        
        self.entitlements = entitlements
        self.range = start..<start+Int(self.length)
    }
}

extension CodeSignatureCodeEntitlements: Displayable {
    public var title: String {
        "CodeSignatureCodeEntitlements"
    }
    
    public var fields: [DisplayableField] {
        [
            .init(label: "Magic", stringValue: magic.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Length", stringValue: length.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Entitlements", stringValue: "\(entitlements.count) Entitlements", offset: 8, size: Int(length),
                  children: entitlements.sorted(by: { $0.key < $1.key }).map { key, value in
                        .init(label: key, stringValue: Self.displayString(for: value),
                              offset: 0, size: 0, children: Self.displayChildren(for: value), obj: self)
                  },
            obj: self),
        ]
    }
    
    public var children: [any Displayable]? {
        []
    }

    private static func displayString(for value: Any) -> String {
        switch value {
        case let bool as Bool:
            return bool.description
        case let string as String:
            return string
        case let number as NSNumber:
            return number.stringValue
        case let data as Data:
            return "\(data.count) bytes"
        case let array as [Any]:
            return "\(array.count) items"
        case let dict as [String: Any]:
            return "\(dict.count) pairs"
        default:
            return String(describing: value)
        }
    }

    private static func displayChildren(for value: Any) -> [DisplayableField]? {
        switch value {
        case let array as [Any]:
            return array.enumerated().map { index, element in
                .init(label: "[\(index)]", stringValue: displayString(for: element),
                      offset: 0, size: 0, children: displayChildren(for: element), obj: nil)
            }
        case let dict as [String: Any]:
            return dict.sorted(by: { $0.key < $1.key }).map { key, element in
                .init(label: key, stringValue: displayString(for: element),
                      offset: 0, size: 0, children: displayChildren(for: element), obj: nil)
            }
        default:
            return nil
        }
    }
}
