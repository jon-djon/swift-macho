//
//  ToolEnum.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

// https://github.com/apple-oss-distributions/dyld/blob/main/common/MachOAnalyzer.cpp
@CaseName
public enum ToolEnum: UInt32 {
    case TOOL_NONE = 0
    case TOOL_CLANG = 1
    case TOOL_SWIFT = 2
    case TOOL_LD = 3
    case TOOL_LLD = 4
    case TOOL_LD_PRIME = 5
    case TOOL_METAL = 1026
    case TOOL_AIRLLD = 1027
    case TOOL_AIRNT = 1028
    case TOOL_AIRPACK = 1029
    case TOOL_GPUARCHIVER = 1031
    case TOOL_METAL_FRAMEWORK = 1032
}
