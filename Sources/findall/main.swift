import ArgumentParser
import Foundation
import SwiftMachO

struct FindAll: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract:
            "Recursively find all Mach-O files under a directory and write their paths to a file."
    )

    @Argument(help: "Root path to search from.")
    var searchPath: String

    @Option(name: .shortAndLong, help: "Path to write the newline-delimited output file.")
    var output: String

    // Directories whose subtrees are never searched.
    private static let excludedPaths: [String] = [
        "/private/var/folders",
        "/Users/jon/Library/Mobile Documents/com~apple~CloudDocs",
        "/System/Volumes/Data/dev",
        "/proc",
        "/Library/Caches",
        "/Users/jon/Library/Caches",
    ]

    func run() throws {
        let root = URL(fileURLWithPath: searchPath, isDirectory: true)
        let isTTY = isatty(STDERR_FILENO) != 0

        // Create / truncate output file up front.
        FileManager.default.createFile(atPath: output, contents: nil)
        let out = try FileHandle(forWritingTo: URL(fileURLWithPath: output))
        defer { try? out.close() }

        // Enumerate all regular files, skipping symbolic links to avoid cycles.
        let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey, .isDirectoryKey],
            options: [.skipsPackageDescendants]
        )

        var checked = 0
        var found = 0

        while let url = enumerator?.nextObject() as? URL {
            let resources = try? url.resourceValues(
                forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .isDirectoryKey])

            // Skip excluded directory subtrees entirely.
            if resources?.isDirectory == true {
                let path = url.path
                if Self.excludedPaths.contains(where: { path.hasPrefix($0) }) {
                    enumerator?.skipDescendants()
                }
                continue
            }

            guard
                resources?.isSymbolicLink != true,
                resources?.isRegularFile == true
            else { continue }

            checked += 1

            if MachOFile.isMachoFile(url) {
                found += 1
                let line = url.path + "\n"
                if let data = line.data(using: .utf8) {
                    try? out.write(contentsOf: data)
                }
            }

            if isTTY {
                renderStatus(checked: checked, found: found, path: url.path)
            }
        }

        if isTTY {
            // Clear progress line.
            fputs("\r\u{1B}[K", stderr)
        }
        fputs(
            "Done: checked \(checked) files, found \(found) Mach-O binaries → \(output)\n", stderr)
    }
}

// MARK: - Progress

private let spinner = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

private func renderStatus(checked: Int, found: Int, path: String) {
    let frame = spinner[(checked / 100) % spinner.count]

    let maxLen = 50
    let label = path.count > maxLen ? "…" + path.suffix(maxLen - 1) : path

    // \r returns to column 0; ESC[K clears to end of line.
    fputs("\r\(frame) checked: \(checked)  found: \(found)  \(label)\u{1B}[K", stderr)
}

FindAll.main()
