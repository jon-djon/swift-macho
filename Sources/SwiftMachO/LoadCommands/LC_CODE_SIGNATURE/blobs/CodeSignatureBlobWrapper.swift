//
//  CodeSignatureBlobWrapper.swift
//  swift-macho
//
//  Created by jon on 10/17/25.
//

import Foundation
import BinaryParsing
import SwiftASN1
@_spi(CMS) import X509


public struct CodeSignatureBlobWrapper: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    
    // This has to be private because it is an SPI.
    // Need to break out CMS into it's own library.
    private let cms: CMSSignature?
    
    public var certificates: [Certificate]? {
        cms?.certificates
    }
    
    public struct Signer {
        public let certificate: Certificate
        public let signingTime: Date?
    }
    
    
    public var signers: [Signer]? {
        guard let signers = try? cms?.signers else { return nil }
        return signers.map { Signer(certificate: $0.certificate, signingTime: $0.signingTime) }
    }
    
    public let cmsDataRange: Range<Int>
    public let range: Range<Int>
    
    public var description: String {
        "CodeSignatureBlobWrapper \(length.description) bytes"
    }
}

extension CodeSignatureBlobWrapper {
    /// Reads the BER TLV header to determine the total encoded length (tag + length bytes + content),
    /// so trailing padding can be stripped before parsing.
    private static func berContentLength(_ bytes: [UInt8]) -> Int? {
        guard bytes.count >= 2 else { return nil }
        // bytes[0] is the tag; bytes[1] starts the length encoding
        let lengthByte = bytes[1]
        let contentLength: Int
        let headerSize: Int
        if lengthByte & 0x80 == 0 {
            // Short form: length is directly encoded in bits 0–6
            contentLength = Int(lengthByte)
            headerSize = 2
        } else {
            // Long form: low 7 bits indicate how many subsequent bytes encode the length
            let numLengthBytes = Int(lengthByte & 0x7F)
            guard numLengthBytes > 0, bytes.count >= 2 + numLengthBytes else { return nil }
            contentLength = bytes[2..<(2 + numLengthBytes)].reduce(0) { ($0 << 8) | Int($1) }
            headerSize = 2 + numLengthBytes
        }
        return headerSize + contentLength
    }
    
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .BlobWrapper else {
            throw MachOError.badMagicValue("CodeSignatureBlobWrapper unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.cmsDataRange = input.startPosition..<input.startPosition+Int(self.length)-8
        self.range = start..<start+Int(self.length)
        
        let rawData = try Data(parsing: &input, byteCount: Int(self.length) - 8)
        
        // BER encodes the exact content length in the tag-length-value header.
        // Read it to trim any trailing padding before parsing.
        let cmsBytes = [UInt8](rawData)
        let berContentLength = CodeSignatureBlobWrapper.berContentLength(cmsBytes)
        let trimmedBytes = berContentLength.map { Array(cmsBytes.prefix($0)) } ?? cmsBytes
        
        if let rootNode = try? BER.parse(trimmedBytes) {
            self.cms = try? CMSSignature(berEncoded: rootNode, withIdentifier: .sequence)
        } else {
            self.cms = nil
        }
    }
}

extension CodeSignatureBlobWrapper: Displayable {
    public var title: String {
        "CodeSignatureBlobWrapper"
    }
    public var fields: [DisplayableField] {
        [
            .init(label: "Magic", stringValue: magic.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Length", stringValue: length.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "CMS Data Range", stringValue: "\(cmsDataRange.count) bytes", offset: 8, size: Int(length), children: nil, obj: self),
        ]
    }
    
    public var children: [any Displayable]? {
        []
    }
}
