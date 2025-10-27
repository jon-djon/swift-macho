//
//  CodeRequirement.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//
import Foundation
import BinaryParsing

@CaseName
public enum CodeExpressionLevel: Int {
    case primary = 0
    case and = 1
    case or = 2
    case top = 3
}

@CaseName
public enum CodeSignatureRequirementExprOp: UInt32 {
    case opFalse = 0
    case opTrue = 1
    case opIdent = 2
    case opAppleAnchor = 3
    case opAnchorHash = 4
    case opInfoKeyValue = 5
    case opAnd = 6
    case opOr = 7
    case opCDHash = 8
    case opNot = 9
    case opInfoKeyField = 10
    case opCertField = 11
    case opTrustedCert = 12
    case opTrustedCerts = 13
    case opCertGeneric = 14
    case opAppleGenericAnchor = 15
    case opEntitlementField = 16
    case opCertPolicy = 17
    case opNamedAnchor = 18
    case opNamedCode = 19
    case opPlatform = 20
    case opNotarized = 21
    case opCertDate = 22
    case opLegacyDevID = 23
    // case exprOpCount = 24
}

public enum CodeSignatureRequirementExprOpValue {
    case Single(CodeSignatureRequirementExprOp)
    case SingleArg(CodeSignatureRequirementExprOp, String)
    case KeyValue(CodeSignatureRequirementExprOp, String, String)
    case SingleInt(CodeSignatureRequirementExprOp, UInt32)
    case CertMatch(CodeSignatureRequirementExprOp, CertificateMatch)
    case KeyMatch(CodeSignatureRequirementExprOp, String, MatchExprSingle)
}

public struct CodeSignatureCodeRequirement: Parseable {
    public let magic: CodeSignatureBlobMagic
    public let length: UInt32
    public let kind: UInt32
    public let expressions:[CodeSignatureRequirementExprOpValue]
    
    public let range: Range<Int>
    public let type: MachOCodeSignatureRequirementType
    
    public var description: String {
        "\(type) \(kind)"
//        requirements.map {
//            $0.description
//        }.joined(separator: "\n")
    }
}


extension CodeSignatureCodeRequirement {
    public init(parsing input: inout ParserSpan, type: MachOCodeSignatureRequirementType) throws {
        let start = input.startPosition
        self.type = type
        
        self.magic = try CodeSignatureBlobMagic(parsing: &input, endianness: .big)
        guard magic == .CodeRequirement else {
            throw MachOError.badMagicValue("CodeRequirement unexpected magic value \(self.magic)")
        }
        self.length = try UInt32(parsing: &input, endianness: .big)
        self.range = start..<start+Int(self.length)
        self.kind = try UInt32(parsing: &input, endianness: .big)
        
        // Reset back to start and create new span with the length
        var span = try input.sliceSpan(byteCount: self.length-12)
        
        var expressions:[CodeSignatureRequirementExprOpValue] = []
        switch type {
        case .DesignatedRequirementType:
            while !span.parserRange.isEmpty {
                let op = try CodeSignatureRequirementExprOp(parsing: &span, endianness: .big)
                switch op {
                case .opFalse, .opTrue, .opAppleAnchor, .opAppleGenericAnchor, .opTrustedCerts, .opNotarized, .opLegacyDevID, .opOr, .opAnd:
                    expressions.append(CodeSignatureRequirementExprOpValue.Single(op))
                case .opIdent, .opAnchorHash, .opCDHash, .opNot, .opNamedCode, .opNamedAnchor:
                    let size = try UInt32(parsing: &span, endianness: .big)
                    let arg = try String(parsingUTF8: &span, count: Int(size).align(4))
                    expressions.append(CodeSignatureRequirementExprOpValue.SingleArg(op, arg))
                case .opInfoKeyValue:
                    let keySize = try UInt32(parsing: &span, endianness: .big)
                    let key = try String(parsingUTF8: &span, count: Int(keySize).align(4))
                    let valueSize = try UInt32(parsing: &span, endianness: .big)
                    let value = try String(parsingUTF8: &span, count: Int(valueSize).align(4))
                    expressions.append(CodeSignatureRequirementExprOpValue.KeyValue(op, key, value))
                case .opTrustedCert, .opPlatform:
                    let idx = try UInt32(parsing: &span, endianness: .big)
                    expressions.append(CodeSignatureRequirementExprOpValue.SingleInt(op, idx))
                case .opCertGeneric, .opCertField, .opCertPolicy, .opCertDate:
                    let match = try CertificateMatch(parsing: &span)
                    expressions.append(CodeSignatureRequirementExprOpValue.CertMatch(op, match))
                case .opInfoKeyField, .opEntitlementField:
                    let keySize = try UInt32(parsing: &span, endianness: .big)
                    let key = try String(parsingUTF8: &span, count: Int(keySize).align(4))
                    let match = try MatchExprSingle(parsing: &span)
                    expressions.append(CodeSignatureRequirementExprOpValue.KeyMatch(op, key, match))
                }
            }
            
        default: break
        }
        self.expressions = expressions
    }
}

extension CodeSignatureCodeRequirement {
    public func buildExpressionString() throws -> String {
        var index = 0
        return try buildExpressionString(&index, level: .top)
    }
     
    // https://github.com/apple-oss-distributions/Security/blob/3dab46a11f45f2ffdbd70e2127cc5a8ce4a1f222/OSX/libsecurity_codesigning/lib/reqdumper.cpp
    private func buildExpressionString(_ index: inout Int, level: CodeExpressionLevel = .top) throws -> String {
        guard
            index >= 0,
            index < expressions.count
        else { throw MachOError.parsingError("CodeSignatureCodeRequirement.RequirementOpError") }
        
        var expressionString = ""
        let expression = expressions[index]
        index += 1
        
        switch expression {
        case .Single(let op):
            switch op {
            case .opFalse: expressionString += "never"
            case .opTrue: expressionString += "always"
            case .opAppleAnchor: expressionString += "anchor apple"
            case .opAppleGenericAnchor: expressionString += "anchor apple generic"
            case .opTrustedCerts: expressionString += "anchor trusted"
            case .opLegacyDevID: expressionString += "legacy"
            case .opNotarized: expressionString += "notarized"
            case .opAnd:
                if level.rawValue <  CodeExpressionLevel.and.rawValue {
                    expressionString += "("
                }
                
                expressionString += "\(try buildExpressionString(&index, level: .and))"
                expressionString += " and "
                expressionString += "\(try buildExpressionString(&index, level: .and))"
                if level.rawValue <  CodeExpressionLevel.and.rawValue {
                    expressionString += ")"
                }
            case .opOr:
                if level.rawValue <  CodeExpressionLevel.or.rawValue {
                    expressionString += "("
                }
                expressionString += "\(try buildExpressionString(&index, level: .or))"
                expressionString += " or "
                expressionString += "\(try buildExpressionString(&index, level: .or))"
                if level.rawValue <  CodeExpressionLevel.or.rawValue {
                    expressionString += ")"
                }
            default: break
            }
        case .SingleArg(let op, let arg):
            switch op {
            case .opIdent: expressionString += "identifier \"\(arg)\""
            case .opAnchorHash: expressionString += "certificate \("certSlot") = \("hashData")" // ?? TODO
            case .opCDHash: expressionString += "cdhash \(arg)"
            case .opNot: expressionString += "! \(try buildExpressionString(&index, level: .primary))"
            case .opNamedCode: expressionString += "(\(arg))"
            case .opNamedAnchor: expressionString += "anchor apple \(arg)"
            default: break
            }
        case .KeyValue(let op, let key, let value):
            switch op {
            case .opInfoKeyValue: expressionString += "info[\(key)] = \(value)"
            default: break
            }
        case .SingleInt(let op, let idx):
            switch op {
            case .opTrustedCert: expressionString += "certificate \(idx) trusted"
            case .opPlatform: expressionString += "platform = \(idx)"
            default: break
            }
        case .CertMatch(let op, let certMatch):
            switch op {
            case .opCertField: expressionString += "certificate \(certMatch.slotString)[\(certMatch.fieldString)]\(certMatch.match.matchString)"
            case .opCertGeneric: expressionString += "certificate \(certMatch.slotString)[field.\(certMatch.fieldOID ?? "<OID-Error>")] \(certMatch.match.matchString)"
            case .opCertPolicy: expressionString += "certificate \(certMatch.slotString)[policy.\("<oid>")] \(certMatch.match.matchString)"
            case .opCertDate: expressionString += "certificate  \(certMatch.slotString)[timestamp.\("<oid>")]"
            default: break
            }
        case .KeyMatch(let op, let key, let match):
            switch op {
            case .opInfoKeyField: expressionString += "info[\(key)] \(match.matchString)"
            case .opEntitlementField: expressionString += "entitlement[\(key)] \(match.matchString)"
            default: break
            }
        }
        return expressionString
    }
}


extension CodeSignatureCodeRequirement: Displayable {
    public var title: String {
        "CodeSignatureCodeRequirements"
    }
    
    public var children: [any Displayable]? {
        []
    }
}



