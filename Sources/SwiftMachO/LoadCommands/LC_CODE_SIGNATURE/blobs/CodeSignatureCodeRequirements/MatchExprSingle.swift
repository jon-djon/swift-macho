//
//  MatchExprSingle.swift
//  swift-macho
//
//  Created by jon on 10/24/25.
//

import Foundation
import BinaryParsing


public struct MatchExprSingle: Parseable {
    public let op: MatchOp
    public let arg: String?
    public let timestamp: UInt64?
    
    public let range: Range<Int>
    
    @CaseName
    public enum MatchOp: UInt32 {
        case matchExists = 0
        case matchEqual = 1
        case matchContains = 2
        case matchBeginsWith = 3
        case matchEndsWith = 4
        case matchLessThan = 5
        case matchGreaterThan = 6
        case matchLessEqual = 7
        case matchGreaterEqual = 8
        case matchOn = 9
        case matchBefore = 10
        case matchAfter = 11
        case matchOnOrBefore = 12
        case matchOnOrAfter = 13
        case matchAbsent = 14
    }
    
    public var matchString: String {
        switch op {
        case .matchExists: return "/* exists */" // " /* exists */ "
        case .matchAbsent: return "absent"// " /* does not exists */ "
        case .matchEqual: return " = \"\(arg ?? "")\""
        case .matchContains: return " ~ \(arg ?? "")"
        case .matchBeginsWith: return " = \(arg ?? "")*"
        case .matchEndsWith: return " = *\(arg ?? "")"
        case .matchLessThan: return " < \(arg ?? "")"
        case .matchGreaterThan: return " > \(arg ?? "")"
        case .matchLessEqual: return " <= \(arg ?? "")"
        case .matchGreaterEqual: return " >= \(arg ?? "")"
        case .matchOn: return " todo_matchOn \(arg ?? "")"
        case .matchBefore: return " todo_matchBefore \(arg ?? "")"
        case .matchAfter: return " todo_matchAfter \(arg ?? "")"
        case .matchOnOrBefore: return " todo_matchOnOrBefore \(arg ?? "")"
        case .matchOnOrAfter: return " todo_matchOnOrAfter \(arg ?? "")"
        }
    }
}

extension MatchExprSingle {
    public init(parsing input: inout ParserSpan) throws {
        self.range = input.parserRange.range
        
        self.op = try MatchOp(parsing: &input, endianness :.big)
        
        switch self.op {
        case .matchExists, .matchAbsent:
            self.arg = nil
            self.timestamp = nil
        case .matchEqual, .matchContains, .matchBeginsWith, .matchEndsWith, .matchLessThan, .matchGreaterThan, .matchLessEqual, .matchGreaterEqual:
            let size = try UInt32(parsing: &input, endianness: .big)
            self.arg = try String(parsingUTF8: &input, count: Int(size).align(4))
            self.timestamp = nil
        case .matchOn, .matchBefore, .matchAfter, .matchOnOrBefore, .matchOnOrAfter:
            self.timestamp = try UInt64(parsing: &input, endianness: .big)
            self.arg = nil
        }
    }
}
