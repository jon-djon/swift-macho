//
//  CodeSignatureBlobWrapper.swift
//  swift-macho
//
//  Created by jon on 10/17/25.
//

import Foundation
import BinaryParsing
// import SwiftCMS


public struct CodeSignatureBlobWrapper: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    // public let pkcs7: PKCS7 // TODO: Need to extract CMS code from the swift-certificates lib
    
    public let range: Range<Int>
    
    public var description: String {
        "CodeSignatureBlobWrapper \(length.description) bytes"
    }
}

extension CodeSignatureBlobWrapper {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .BlobWrapper else {
            throw MachOError.badMagicValue("CodeSignatureBlobWrapper unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
    }
}

extension CodeSignatureBlobWrapper: Displayable {
    public var title: String {
        "CodeSignatureBlobWrapper"
    }
    
    public var children: [any Displayable]? {
        []
    }
}
