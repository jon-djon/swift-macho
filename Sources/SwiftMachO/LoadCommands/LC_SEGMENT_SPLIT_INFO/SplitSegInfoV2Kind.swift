//
//  SplitSegInfoV2Kind.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

/// The kind of pointer adjustment in split segment info v2
@CaseName
public enum SplitSegInfoV2Kind: UInt8 {
    case pointer64 = 1  // DYLD_CACHE_ADJ_V2_POINTER_64
    case delta64 = 2  // DYLD_CACHE_ADJ_V2_DELTA_64
    case delta32 = 3  // DYLD_CACHE_ADJ_V2_DELTA_32
    case arm64ADRP = 4  // DYLD_CACHE_ADJ_V2_ARM64_ADRP
    case arm64Off12 = 5  // DYLD_CACHE_ADJ_V2_ARM64_OFF12
    case arm64Br26 = 6  // DYLD_CACHE_ADJ_V2_ARM64_BR26
    case armMovwMovt = 7  // DYLD_CACHE_ADJ_V2_ARM_MOVW_MOVT
    case armBr24 = 8  // DYLD_CACHE_ADJ_V2_ARM_BR24
    case thumbMovwMovt = 9  // DYLD_CACHE_ADJ_V2_THUMB_MOVW_MOVT
    case thumbBr22 = 10  // DYLD_CACHE_ADJ_V2_THUMB_BR22
    case imageOff32 = 11  // DYLD_CACHE_ADJ_V2_IMAGE_OFF_32
    case threaded = 12  // DYLD_CACHE_ADJ_V2_THREADED_POINTER_64
}
