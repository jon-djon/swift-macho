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
    public let count: UInt32
    public let threadState: ThreadState

    public let range: Range<Int>

    @CaseName
    public enum Flavor: UInt32 {
        // x86 flavors
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
        // ARM flavors
        case ARM_THREAD_STATE = 1001      // Intentionally different range to avoid collision
        case ARM_THREAD_STATE64 = 1006
    }

    public enum ThreadState {
        case x86_64(ThreadState64)
        case x86_32(ThreadState32)
        case arm64(ARM64ThreadState)
        case unknown(Data)
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

        public static let size: Int = 8 * 21  // 168 bytes
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

        public static let size: Int = 4 * 16  // 64 bytes
    }

    public struct ARM64ThreadState: Parseable {
        public let x0: UInt64
        public let x1: UInt64
        public let x2: UInt64
        public let x3: UInt64
        public let x4: UInt64
        public let x5: UInt64
        public let x6: UInt64
        public let x7: UInt64
        public let x8: UInt64
        public let x9: UInt64
        public let x10: UInt64
        public let x11: UInt64
        public let x12: UInt64
        public let x13: UInt64
        public let x14: UInt64
        public let x15: UInt64
        public let x16: UInt64
        public let x17: UInt64
        public let x18: UInt64
        public let x19: UInt64
        public let x20: UInt64
        public let x21: UInt64
        public let x22: UInt64
        public let x23: UInt64
        public let x24: UInt64
        public let x25: UInt64
        public let x26: UInt64
        public let x27: UInt64
        public let x28: UInt64
        public let fp: UInt64   // x29 - frame pointer
        public let lr: UInt64   // x30 - link register
        public let sp: UInt64   // stack pointer
        public let pc: UInt64   // program counter
        public let cpsr: UInt32 // current program status register
        public let pad: UInt32  // padding for alignment

        public let range: Range<Int>

        public static let size: Int = 8 * 33 + 4 + 4  // 272 bytes
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
        self.count = try UInt32(parsing: &input, endianness: endianness)

        // Parse thread state based on flavor
        switch flavor {
        case .x86_THREAD_STATE64:
            self.threadState = .x86_64(try ThreadState64(parsing: &input, endianness: endianness))
        case .x86_THREAD_STATE32:
            self.threadState = .x86_32(try ThreadState32(parsing: &input, endianness: endianness))
        case .ARM_THREAD_STATE64:
            self.threadState = .arm64(try ARM64ThreadState(parsing: &input, endianness: endianness))
        default:
            // For unknown flavors, read the raw data
            let byteCount = Int(count) * 4  // count is in 32-bit words
            let data = try Data(parsing: &input, byteCount: byteCount)
            self.threadState = .unknown(data)
        }
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

extension LC_UNIXTHREAD.ARM64ThreadState {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.x0 = try UInt64(parsing: &input, endianness: endianness)
        self.x1 = try UInt64(parsing: &input, endianness: endianness)
        self.x2 = try UInt64(parsing: &input, endianness: endianness)
        self.x3 = try UInt64(parsing: &input, endianness: endianness)
        self.x4 = try UInt64(parsing: &input, endianness: endianness)
        self.x5 = try UInt64(parsing: &input, endianness: endianness)
        self.x6 = try UInt64(parsing: &input, endianness: endianness)
        self.x7 = try UInt64(parsing: &input, endianness: endianness)
        self.x8 = try UInt64(parsing: &input, endianness: endianness)
        self.x9 = try UInt64(parsing: &input, endianness: endianness)
        self.x10 = try UInt64(parsing: &input, endianness: endianness)
        self.x11 = try UInt64(parsing: &input, endianness: endianness)
        self.x12 = try UInt64(parsing: &input, endianness: endianness)
        self.x13 = try UInt64(parsing: &input, endianness: endianness)
        self.x14 = try UInt64(parsing: &input, endianness: endianness)
        self.x15 = try UInt64(parsing: &input, endianness: endianness)
        self.x16 = try UInt64(parsing: &input, endianness: endianness)
        self.x17 = try UInt64(parsing: &input, endianness: endianness)
        self.x18 = try UInt64(parsing: &input, endianness: endianness)
        self.x19 = try UInt64(parsing: &input, endianness: endianness)
        self.x20 = try UInt64(parsing: &input, endianness: endianness)
        self.x21 = try UInt64(parsing: &input, endianness: endianness)
        self.x22 = try UInt64(parsing: &input, endianness: endianness)
        self.x23 = try UInt64(parsing: &input, endianness: endianness)
        self.x24 = try UInt64(parsing: &input, endianness: endianness)
        self.x25 = try UInt64(parsing: &input, endianness: endianness)
        self.x26 = try UInt64(parsing: &input, endianness: endianness)
        self.x27 = try UInt64(parsing: &input, endianness: endianness)
        self.x28 = try UInt64(parsing: &input, endianness: endianness)
        self.fp = try UInt64(parsing: &input, endianness: endianness)
        self.lr = try UInt64(parsing: &input, endianness: endianness)
        self.sp = try UInt64(parsing: &input, endianness: endianness)
        self.pc = try UInt64(parsing: &input, endianness: endianness)
        self.cpsr = try UInt32(parsing: &input, endianness: endianness)
        self.pad = try UInt32(parsing: &input, endianness: endianness)
    }
}

extension LC_UNIXTHREAD: Displayable {
    public var title: String { "\(Self.self)" }
    public var description: String { """
        Specifies the initial thread state for a Unix process. This legacy command defines the register values \
        (including the program counter/entry point) for the main thread when the process starts.

        Replaced by `LC_MAIN` in modern binaries, but still used by the kernel and some legacy executables.
        """ }
    public var fields: [DisplayableField] {
        var fields: [DisplayableField] = [
            .init(label: "Command ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Command Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "Flavor", stringValue: flavor.description, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "Count", stringValue: count.description, offset: 12, size: 4, children: nil, obj: self),
        ]

        switch threadState {
        case .x86_64(let state):
            fields.append(.init(label: "Thread State (x86_64)", stringValue: "rip: \(state.rip.hexDescription)", offset: 16, size: LC_UNIXTHREAD.ThreadState64.size, children: state.fields, obj: self))
        case .x86_32(let state):
            fields.append(.init(label: "Thread State (x86)", stringValue: "eip: \(state.eip.hexDescription)", offset: 16, size: LC_UNIXTHREAD.ThreadState32.size, children: state.fields, obj: self))
        case .arm64(let state):
            fields.append(.init(label: "Thread State (ARM64)", stringValue: "pc: \(state.pc.hexDescription)", offset: 16, size: LC_UNIXTHREAD.ARM64ThreadState.size, children: state.fields, obj: self))
        case .unknown(let data):
            fields.append(.init(label: "Thread State (Unknown)", stringValue: "\(data.count) bytes", offset: 16, size: data.count, children: nil, obj: self))
        }

        return fields
    }
    public var children: [Displayable]? { nil }
}

extension LC_UNIXTHREAD.ThreadState64: Displayable {
    public var title: String { "x86_64 Thread State" }
    public var description: String { "rip: \(rip.hexDescription)" }
    public var fields: [DisplayableField] {
        [
            .init(label: "rax", stringValue: rax.hexDescription, offset: 0, size: 8, children: nil, obj: self),
            .init(label: "rbx", stringValue: rbx.hexDescription, offset: 8, size: 8, children: nil, obj: self),
            .init(label: "rcx", stringValue: rcx.hexDescription, offset: 16, size: 8, children: nil, obj: self),
            .init(label: "rdx", stringValue: rdx.hexDescription, offset: 24, size: 8, children: nil, obj: self),
            .init(label: "rdi", stringValue: rdi.hexDescription, offset: 32, size: 8, children: nil, obj: self),
            .init(label: "rsi", stringValue: rsi.hexDescription, offset: 40, size: 8, children: nil, obj: self),
            .init(label: "rbp", stringValue: rbp.hexDescription, offset: 48, size: 8, children: nil, obj: self),
            .init(label: "rsp", stringValue: rsp.hexDescription, offset: 56, size: 8, children: nil, obj: self),
            .init(label: "r8", stringValue: r8.hexDescription, offset: 64, size: 8, children: nil, obj: self),
            .init(label: "r9", stringValue: r9.hexDescription, offset: 72, size: 8, children: nil, obj: self),
            .init(label: "r10", stringValue: r10.hexDescription, offset: 80, size: 8, children: nil, obj: self),
            .init(label: "r11", stringValue: r11.hexDescription, offset: 88, size: 8, children: nil, obj: self),
            .init(label: "r12", stringValue: r12.hexDescription, offset: 96, size: 8, children: nil, obj: self),
            .init(label: "r13", stringValue: r13.hexDescription, offset: 104, size: 8, children: nil, obj: self),
            .init(label: "r14", stringValue: r14.hexDescription, offset: 112, size: 8, children: nil, obj: self),
            .init(label: "r15", stringValue: r15.hexDescription, offset: 120, size: 8, children: nil, obj: self),
            .init(label: "rip", stringValue: rip.hexDescription, offset: 128, size: 8, children: nil, obj: self),
            .init(label: "rflags", stringValue: rflags.hexDescription, offset: 136, size: 8, children: nil, obj: self),
            .init(label: "cs", stringValue: cs.hexDescription, offset: 144, size: 8, children: nil, obj: self),
            .init(label: "fs", stringValue: fs.hexDescription, offset: 152, size: 8, children: nil, obj: self),
            .init(label: "gs", stringValue: gs.hexDescription, offset: 160, size: 8, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}

extension LC_UNIXTHREAD.ThreadState32: Displayable {
    public var title: String { "x86 Thread State" }
    public var description: String { "eip: \(eip.hexDescription)" }
    public var fields: [DisplayableField] {
        [
            .init(label: "eax", stringValue: eax.hexDescription, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "ebx", stringValue: ebx.hexDescription, offset: 4, size: 4, children: nil, obj: self),
            .init(label: "ecx", stringValue: ecx.hexDescription, offset: 8, size: 4, children: nil, obj: self),
            .init(label: "edx", stringValue: edx.hexDescription, offset: 12, size: 4, children: nil, obj: self),
            .init(label: "edi", stringValue: edi.hexDescription, offset: 16, size: 4, children: nil, obj: self),
            .init(label: "esi", stringValue: esi.hexDescription, offset: 20, size: 4, children: nil, obj: self),
            .init(label: "ebp", stringValue: ebp.hexDescription, offset: 24, size: 4, children: nil, obj: self),
            .init(label: "esp", stringValue: esp.hexDescription, offset: 28, size: 4, children: nil, obj: self),
            .init(label: "ss", stringValue: ss.hexDescription, offset: 32, size: 4, children: nil, obj: self),
            .init(label: "eflags", stringValue: eflags.hexDescription, offset: 36, size: 4, children: nil, obj: self),
            .init(label: "eip", stringValue: eip.hexDescription, offset: 40, size: 4, children: nil, obj: self),
            .init(label: "cs", stringValue: cs.hexDescription, offset: 44, size: 4, children: nil, obj: self),
            .init(label: "ds", stringValue: ds.hexDescription, offset: 48, size: 4, children: nil, obj: self),
            .init(label: "es", stringValue: es.hexDescription, offset: 52, size: 4, children: nil, obj: self),
            .init(label: "fs", stringValue: fs.hexDescription, offset: 56, size: 4, children: nil, obj: self),
            .init(label: "gs", stringValue: gs.hexDescription, offset: 60, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}

extension LC_UNIXTHREAD.ARM64ThreadState: Displayable {
    public var title: String { "ARM64 Thread State" }
    public var description: String { "pc: \(pc.hexDescription)" }
    public var fields: [DisplayableField] {
        [
            .init(label: "x0", stringValue: x0.hexDescription, offset: 0, size: 8, children: nil, obj: self),
            .init(label: "x1", stringValue: x1.hexDescription, offset: 8, size: 8, children: nil, obj: self),
            .init(label: "x2", stringValue: x2.hexDescription, offset: 16, size: 8, children: nil, obj: self),
            .init(label: "x3", stringValue: x3.hexDescription, offset: 24, size: 8, children: nil, obj: self),
            .init(label: "x4", stringValue: x4.hexDescription, offset: 32, size: 8, children: nil, obj: self),
            .init(label: "x5", stringValue: x5.hexDescription, offset: 40, size: 8, children: nil, obj: self),
            .init(label: "x6", stringValue: x6.hexDescription, offset: 48, size: 8, children: nil, obj: self),
            .init(label: "x7", stringValue: x7.hexDescription, offset: 56, size: 8, children: nil, obj: self),
            .init(label: "x8", stringValue: x8.hexDescription, offset: 64, size: 8, children: nil, obj: self),
            .init(label: "x9", stringValue: x9.hexDescription, offset: 72, size: 8, children: nil, obj: self),
            .init(label: "x10", stringValue: x10.hexDescription, offset: 80, size: 8, children: nil, obj: self),
            .init(label: "x11", stringValue: x11.hexDescription, offset: 88, size: 8, children: nil, obj: self),
            .init(label: "x12", stringValue: x12.hexDescription, offset: 96, size: 8, children: nil, obj: self),
            .init(label: "x13", stringValue: x13.hexDescription, offset: 104, size: 8, children: nil, obj: self),
            .init(label: "x14", stringValue: x14.hexDescription, offset: 112, size: 8, children: nil, obj: self),
            .init(label: "x15", stringValue: x15.hexDescription, offset: 120, size: 8, children: nil, obj: self),
            .init(label: "x16", stringValue: x16.hexDescription, offset: 128, size: 8, children: nil, obj: self),
            .init(label: "x17", stringValue: x17.hexDescription, offset: 136, size: 8, children: nil, obj: self),
            .init(label: "x18", stringValue: x18.hexDescription, offset: 144, size: 8, children: nil, obj: self),
            .init(label: "x19", stringValue: x19.hexDescription, offset: 152, size: 8, children: nil, obj: self),
            .init(label: "x20", stringValue: x20.hexDescription, offset: 160, size: 8, children: nil, obj: self),
            .init(label: "x21", stringValue: x21.hexDescription, offset: 168, size: 8, children: nil, obj: self),
            .init(label: "x22", stringValue: x22.hexDescription, offset: 176, size: 8, children: nil, obj: self),
            .init(label: "x23", stringValue: x23.hexDescription, offset: 184, size: 8, children: nil, obj: self),
            .init(label: "x24", stringValue: x24.hexDescription, offset: 192, size: 8, children: nil, obj: self),
            .init(label: "x25", stringValue: x25.hexDescription, offset: 200, size: 8, children: nil, obj: self),
            .init(label: "x26", stringValue: x26.hexDescription, offset: 208, size: 8, children: nil, obj: self),
            .init(label: "x27", stringValue: x27.hexDescription, offset: 216, size: 8, children: nil, obj: self),
            .init(label: "x28", stringValue: x28.hexDescription, offset: 224, size: 8, children: nil, obj: self),
            .init(label: "fp (x29)", stringValue: fp.hexDescription, offset: 232, size: 8, children: nil, obj: self),
            .init(label: "lr (x30)", stringValue: lr.hexDescription, offset: 240, size: 8, children: nil, obj: self),
            .init(label: "sp", stringValue: sp.hexDescription, offset: 248, size: 8, children: nil, obj: self),
            .init(label: "pc", stringValue: pc.hexDescription, offset: 256, size: 8, children: nil, obj: self),
            .init(label: "cpsr", stringValue: cpsr.hexDescription, offset: 264, size: 4, children: nil, obj: self),
            .init(label: "pad", stringValue: pad.hexDescription, offset: 268, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
