//
//  ToolEnum.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

// Are there more valid values?
// https://github.com/apple-oss-distributions/dyld/blob/main/common/MachOAnalyzer.cpp
@CaseName
public enum ToolEnum: UInt32 {
    case TOOL_NONE = 0
    case TOOL_CLANG = 1
    case TOOL_SWIFT = 2
    case TOOL_LD = 3
    case TOOL_LLD = 4
}
