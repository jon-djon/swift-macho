import ArgumentParser
import Foundation
import SwiftMachO

struct RunAll: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Parse every Mach-O path listed in a file and write a CSV report."
    )

    @Argument(help: "Path to a newline-delimited file listing Mach-O paths to parse.")
    var listFile: String

    @Option(name: .shortAndLong, help: "Path to write CSV output.")
    var output: String

    @Flag(name: .shortAndLong, help: "Include successful parses in the CSV (default: errors only).")
    var all: Bool = false

    func run() throws {
        let paths = try loadPaths()
        let total = paths.count
        let isTTY = isatty(STDERR_FILENO) != 0

        // Create / truncate the output file and write the CSV header.
        FileManager.default.createFile(atPath: output, contents: nil)
        let out = try FileHandle(forWritingTo: URL(fileURLWithPath: output))
        defer { try? out.close() }
        writeCSV(to: out, "filepath,status,message\n")

        var errorCount = 0
        var okCount = 0

        for (index, path) in paths.enumerated() {
            if isTTY {
                renderProgress(current: index, total: total, errors: errorCount, path: path)
            }

            let status: String
            let message: String

            do {
                _ = try MachOFile(URL(fileURLWithPath: path))
                okCount += 1
                status = "ok"
                message = ""
            } catch let e as LoadCommandParsingError {
                errorCount += 1
                status = "error"
                message = e.description
            } catch {
                errorCount += 1
                status = "error"
                message = error.localizedDescription
            }

            if all || status == "error" {
                writeCSV(to: out, "\(csvField(path)),\(status),\(csvField(message))\n")
            }
        }

        if isTTY {
            renderProgress(current: total, total: total, errors: errorCount, path: "")
            fputs("\n", stderr)
        }
        fputs("Finished: \(total) files  ok: \(okCount)  errors: \(errorCount)\n", stderr)
    }

    private func loadPaths() throws -> [String] {
        let contents = try String(contentsOf: URL(fileURLWithPath: listFile), encoding: .utf8)
        return contents
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

// MARK: - Progress bar

private func renderProgress(current: Int, total: Int, errors: Int, path: String) {
    let barWidth = 30
    let fraction = total > 0 ? Double(current) / Double(total) : 1.0
    let filled = Int(fraction * Double(barWidth))
    let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: barWidth - filled)
    let pct = Int(fraction * 100)

    // Truncate long paths from the left so the line stays readable.
    let maxLen = 40
    let label = path.count > maxLen ? "…" + path.suffix(maxLen - 1) : path

    // \r returns to column 0; ESC[K erases to end of line, preventing stale characters.
    fputs("\r[\(bar)] \(current)/\(total) (\(pct)%)  errors: \(errors)  \(label)\u{1B}[K", stderr)
}

// MARK: - Helpers

private func writeCSV(to handle: FileHandle, _ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    try? handle.write(contentsOf: data)
}

/// Wraps a CSV field in quotes when it contains a comma, double-quote, or newline.
private func csvField(_ value: String) -> String {
    let needsQuoting = value.contains(",") || value.contains("\"") || value.contains("\n")
    guard needsQuoting else { return value }
    return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
}

RunAll.main()
