//
//  VM_PROT.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation

@AutoOptionSet
public struct VM_PROT: OptionSet, Sendable {
    // public static let VM_PROT_NONE = VM_PROT(rawValue: 0x00000000)
    public static let VM_PROT_READ = VM_PROT(rawValue: 0x0000_0001)
    public static let VM_PROT_WRITE = VM_PROT(rawValue: 0x0000_0002)
    public static let VM_PROT_EXECUTE = VM_PROT(rawValue: 0x0000_0004)  // VM_PROT_RORW_TP & VM_PROT_ALLEXEC
    public static let VM_PROT_DEFAULT = VM_PROT(rawValue: 0x0000_0003)
    public static let VM_PROT_NO_CHANGE_LEGACY = VM_PROT(rawValue: 0x0000_0008)
    public static let VM_PROT_NO_CHANGE = VM_PROT(rawValue: 0x0100_0000)
    public static let VM_PROT_COPY = VM_PROT(rawValue: 0x0000_0010)  // VM_PROT_WANTS_COPY
    public static let VM_PROT_IS_MASK = VM_PROT(rawValue: 0x0000_0040)
    public static let VM_PROT_STRIP_READ = VM_PROT(rawValue: 0x0000_0080)
    public static let VM_PROT_EXECUTE_ONLY = VM_PROT(rawValue: 0x0000_0084)
    public static let VM_PROT_TPRO = VM_PROT(rawValue: 0x0000_0200)
}
