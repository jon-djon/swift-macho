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
    public init(parsing input: inout ParserSpan) throws {
        let start = input.startPosition
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .BlobWrapper else {
            throw MachOError.badMagicValue("CodeSignatureBlobWrapper unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.cmsDataRange = input.startPosition..<input.startPosition+Int(self.length)-8
        self.range = start..<start+Int(self.length)
        
        // This may fail because there is often padding bytes in the signature that need to be removed.
        // Not exactly sure how to determine how much padding needs to be removed?
        var data = try Data(parsing: &input, byteCount: Int(self.length))
        
        var cms: CMSSignature? = nil
        let maxAttempts = 16
        for attempt in 1...maxAttempts {
            print("CMS attempt \(attempt)")
            if let rootNode = try? BER.parse([UInt8](data)) {
                cms = try? CMSSignature(berEncoded: rootNode, withIdentifier: .sequence)
                break
            }
            data.removeLast()
        }
        self.cms = cms
        
//        if let rootNode = try? BER.parse([UInt8](data)) {
//            self.cms = try? CMSSignature(berEncoded: rootNode, withIdentifier: .sequence)
//        } else {
//            self.cms = nil
//        }
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
