//
//  LC_THREAD.swift
//  swift-macho
//
//  Created by jon on 10/16/25.
//

import BinaryParsing
import Foundation

public struct LC_THREAD: LoadCommand {
    public static let expectedID: LoadCommandHeader.ID = .LC_THREAD
    public let header: LoadCommandHeader
    public let states: [ThreadStateEntry]
    public let range: Range<Int>

    /// A single flavor/count/state triple within the load command.
    /// LC_THREAD can contain multiple entries (unlike LC_UNIXTHREAD which has exactly one).
    public struct ThreadStateEntry {
        public let flavorRaw: UInt32
        public let flavor: LC_UNIXTHREAD.Flavor?
        public let count: UInt32
        public let threadState: LC_UNIXTHREAD.ThreadState
    }
}

extension LC_THREAD {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range

        self.header = try Self.parseAndValidateHeader(from: &input, endianness: endianness)

        // Parse all flavor/count/state entries until the command bytes are exhausted
        let commandEnd = range.lowerBound + Int(header.cmdSize)
        var states: [ThreadStateEntry] = []

        while input.parserRange.lowerBound < commandEnd && !input.isEmpty {
            let flavorRaw = try UInt32(parsing: &input, endianness: endianness)
            let count = try UInt32(parsing: &input, endianness: endianness)

            let threadState: LC_UNIXTHREAD.ThreadState
            if let flavor = LC_UNIXTHREAD.Flavor(rawValue: flavorRaw) {
                switch flavor {
                case .x86_THREAD_STATE64:
                    threadState = .x86_64(
                        try LC_UNIXTHREAD.ThreadState64(parsing: &input, endianness: endianness))
                case .x86_THREAD_STATE32:
                    threadState = .x86_32(
                        try LC_UNIXTHREAD.ThreadState32(parsing: &input, endianness: endianness))
                case .ARM_THREAD_STATE64:
                    threadState = .arm64(
                        try LC_UNIXTHREAD.ARM64ThreadState(parsing: &input, endianness: endianness))
                default:
                    let byteCount = Int(count) * 4
                    let data = try Data(parsing: &input, byteCount: byteCount)
                    threadState = .unknown(data)
                }
            } else {
                let byteCount = Int(count) * 4
                let data = try Data(parsing: &input, byteCount: byteCount)
                threadState = .unknown(data)
            }

            states.append(ThreadStateEntry(
                flavorRaw: flavorRaw,
                flavor: LC_UNIXTHREAD.Flavor(rawValue: flavorRaw),
                count: count,
                threadState: threadState))
        }

        self.states = states
    }
}

extension LC_THREAD: Displayable {
    public var description: String {
        "Specifies thread state without starting the thread. Can contain multiple state entries."
    }
    public var fields: [DisplayableField] {
        var b = fieldBuilder()

        for (index, entry) in states.enumerated() {
            let stateFields: [DisplayableField]
            let summary: String

            switch entry.threadState {
            case .x86_64(let state):
                summary = "x86_64, rip: \(state.rip.hexDescription)"
                stateFields = state.fields
            case .x86_32(let state):
                summary = "x86, eip: \(state.eip.hexDescription)"
                stateFields = state.fields
            case .arm64(let state):
                summary = "ARM64, pc: \(state.pc.hexDescription)"
                stateFields = state.fields
            case .unknown(let data):
                let flavorStr = entry.flavor?.description ?? "unknown (\(entry.flavorRaw))"
                summary = "\(flavorStr), \(data.count) bytes"
                stateFields = []
            }

            b.add(
                label: "State \(index)", stringValue: summary, size: 8 + Int(entry.count) * 4,
                children: [
                    .init(
                        label: "Flavor",
                        stringValue: entry.flavor?.description ?? "unknown (\(entry.flavorRaw))",
                        offset: 0, size: 4, children: nil, obj: self),
                    .init(
                        label: "Count", stringValue: entry.count.description, offset: 4,
                        size: 4, children: nil, obj: self),
                ] + stateFields)
        }

        return b.build()
    }
    public var children: [Displayable]? { nil }
}
