//
//  CaseNameTests.swift
//  swift-macho
//
//  Created by jon on 10/17/25.
//

import SwiftMachOMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class SwiftMachOMacrosTests: XCTestCase {

    func testCaseNameMacroExpansion() {
        assertMacroExpansion(
            """
            @CaseName
            public enum Magic: UInt32 {
                case macho32 = 0xfeedface
                case macho64 = 0xfeedfacf
                case macho32Swapped = 0xcefaedfe
                case macho64Swapped = 0xcffaedfe
            }
            """,
            expandedSource: """
                public enum Magic: UInt32 {
                    case macho32 = 0xfeedface
                    case macho64 = 0xfeedfacf
                    case macho32Swapped = 0xcefaedfe
                    case macho64Swapped = 0xcffaedfe

                    public var description: String {
                        switch self {
                            case .macho32:
                            return "macho32"
                                case .macho64:
                            return "macho64"
                                case .macho32Swapped:
                            return "macho32Swapped"
                                case .macho64Swapped:
                            return "macho64Swapped"
                        }
                    }
                }
                """,
            macros: ["CaseName": CaseNameMacro.self]
        )
    }
}
