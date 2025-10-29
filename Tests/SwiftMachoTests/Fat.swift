//
//  Fat.swift
//  swift-macho
//
//  Created by jon on 10/28/25.
//

import Testing
@testable import SwiftMachO
import Foundation

struct FatBinaryTests {
    let data = Data([202,254,186,190,0,0,0,2,1,0,0,7,0,0,0,3,0,0,64,0,0,71,204,112,0,0,0,14,1,0,0,12,0,0,0,0,0,72,64,0,0,61,252,48,0,0,0,14,])
    
    @Test
    func testFatBinary() {
//        let f = try FatBinary(parsing: data)
//        #expect(elf.header.class == .class32Bit)
//        #expect(elf.header.endian == .little)
    }
}
