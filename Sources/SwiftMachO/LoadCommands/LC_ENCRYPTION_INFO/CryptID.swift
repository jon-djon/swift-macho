//
//  CryptID.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

/// Encryption system identifier for LC_ENCRYPTION_INFO commands.
/// A value of 0 indicates the binary is not encrypted, while non-zero values
/// indicate encryption (typically FairPlay DRM for App Store apps).
@CaseName
public enum CryptID: UInt32 {
    case notEncrypted = 0
    case encrypted = 1  // FairPlay DRM
}
