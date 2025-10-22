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
    public let magic: CodeSignatureSuperBlob.Magic
    public let length: UInt32
    // public let pkcs7: PKCS7 // TODO: Need to extract CMS code from the swift-certificates lib
    
    public let range: Range<Int>
    
    public var description: String {
        "CodeSignatureBlobWrapper"
    }
}

extension CodeSignatureBlobWrapper {
    public init(parsing input: inout ParserSpan, endian: Endianness) throws {
        self.range = input.parserRange.range
        self.magic = try CodeSignatureSuperBlob.Magic(parsing: &input, endianness: endian)
        self.length = try UInt32(parsing: &input, endianness: endian)
    }
}
