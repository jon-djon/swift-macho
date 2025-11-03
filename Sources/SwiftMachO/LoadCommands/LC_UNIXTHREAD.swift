//
//  LC_UNIXTHREAD.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import Foundation
import BinaryParsing

public struct LC_UNIXTHREAD: LoadCommand {
    public let header: LoadCommandHeader
    public let flavor: Flavor


    public let range: Range<Int>
    
    @CaseName
    public enum Flavor: UInt32 {
        case x86_THREAD_STATE32 = 1
        case x86_FLOAT_STATE32 = 2
        case x86_EXCEPTION_STATE32 = 3
        case x86_THREAD_STATE64 = 4
        case x86_FLOAT_STATE64 = 5
        case x86_EXCEPTION_STATE64 = 6
        case x86_THREAD_STATE = 7
        case x86_FLOAT_STATE = 8
        case x86_EXCEPTION_STATE = 9
        case x86_DEBUG_STATE32 = 10
        case x86_DEBUG_STATE64 = 11
        case x86_DEBUG_STATE = 12
    }
    
    public struct ThreadState64: Parseable {
        public let rax: UInt64
        public let rbx: UInt64
        public let rcx: UInt64
        public let rdx: UInt64
        public let rdi: UInt64
        public let rsi: UInt64
        public let rbp: UInt64
        public let rsp: UInt64
        public let r8: UInt64
        public let r9: UInt64
        public let r10: UInt64
        public let r11: UInt64
        public let r12: UInt64
        public let r13: UInt64
        public let r14: UInt64
        public let r15: UInt64
        public let rip: UInt64
        public let rflags: UInt64
        public let cs: UInt64
        public let fs: UInt64
        public let gs: UInt64
        
        public let range: Range<Int>
        
        public var size: Int {
            8*21
        }
    }
    
    public struct ThreadState32: Parseable {
        public let eax: UInt32
        public let ebx: UInt32
        public let ecx: UInt32
        public let edx: UInt32
        public let edi: UInt32
        public let esi: UInt32
        public let ebp: UInt32
        public let esp: UInt32
        public let ss: UInt32
        public let eflags: UInt32
        public let eip: UInt32
        public let cs: UInt32
        public let ds: UInt32
        public let es: UInt32
        public let fs: UInt32
        public let gs: UInt32
        
        public let range: Range<Int>
        
        public var size: Int {
            4*16
        }
    }
}

extension LC_UNIXTHREAD {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
        guard header.id == .LC_UNIXTHREAD else {
            throw MachOError.LoadCommandError("Invalid LC_UNIXTHREAD")
        }

        self.flavor = try Flavor(parsing: &input, endianness: endianness)
    }
}

extension LC_UNIXTHREAD.ThreadState64 {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.rax = try UInt64(parsing: &input, endianness: endianness)
        self.rbx = try UInt64(parsing: &input, endianness: endianness)
        self.rcx = try UInt64(parsing: &input, endianness: endianness)
        self.rdx = try UInt64(parsing: &input, endianness: endianness)
        self.rdi = try UInt64(parsing: &input, endianness: endianness)
        self.rsi = try UInt64(parsing: &input, endianness: endianness)
        self.rbp = try UInt64(parsing: &input, endianness: endianness)
        self.rsp = try UInt64(parsing: &input, endianness: endianness)
        self.r8 = try UInt64(parsing: &input, endianness: endianness)
        self.r9 = try UInt64(parsing: &input, endianness: endianness)
        self.r10 = try UInt64(parsing: &input, endianness: endianness)
        self.r11 = try UInt64(parsing: &input, endianness: endianness)
        self.r12 = try UInt64(parsing: &input, endianness: endianness)
        self.r13 = try UInt64(parsing: &input, endianness: endianness)
        self.r14 = try UInt64(parsing: &input, endianness: endianness)
        self.r15 = try UInt64(parsing: &input, endianness: endianness)
        self.rip = try UInt64(parsing: &input, endianness: endianness)
        self.rflags = try UInt64(parsing: &input, endianness: endianness)
        self.cs = try UInt64(parsing: &input, endianness: endianness)
        self.fs = try UInt64(parsing: &input, endianness: endianness)
        self.gs = try UInt64(parsing: &input, endianness: endianness)
    }
}

extension LC_UNIXTHREAD.ThreadState32 {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        
        self.eax = try UInt32(parsing: &input, endianness: endianness)
        self.ebx = try UInt32(parsing: &input, endianness: endianness)
        self.ecx = try UInt32(parsing: &input, endianness: endianness)
        self.edx = try UInt32(parsing: &input, endianness: endianness)
        self.edi = try UInt32(parsing: &input, endianness: endianness)
        self.esi = try UInt32(parsing: &input, endianness: endianness)
        self.ebp = try UInt32(parsing: &input, endianness: endianness)
        self.esp = try UInt32(parsing: &input, endianness: endianness)
        self.ss = try UInt32(parsing: &input, endianness: endianness)
        self.eflags = try UInt32(parsing: &input, endianness: endianness)
        self.eip = try UInt32(parsing: &input, endianness: endianness)
        self.cs = try UInt32(parsing: &input, endianness: endianness)
        self.ds = try UInt32(parsing: &input, endianness: endianness)
        self.es = try UInt32(parsing: &input, endianness: endianness)
        self.fs = try UInt32(parsing: &input, endianness: endianness)
        self.gs = try UInt32(parsing: &input, endianness: endianness)
    }
}



extension LC_UNIXTHREAD: Displayable {
    public var title: String { "\(Self.self) TODO" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
