import ArgumentParser
import Foundation
import MachOFormatters
import SwiftMachO

struct ParseMachO: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Parse and display a Mach-O binary."
    )

    @Argument(help: "Path to the Mach-O binary.")
    var filePath: String

    @Option(name: .shortAndLong, help: "Output format: tree, json, yaml (default: tree).")
    var format: String = "tree"

    func run() throws {
        guard let outputFormat = OutputFormat(rawValue: format) else {
            throw ValidationError("Unknown format '\(format)'. Valid options: tree, json, yaml")
        }

        guard MachOFile.isMachoFile(URL(fileURLWithPath: filePath)) else {
            print("Not a Mach-O file: \(filePath)")
            return
        }

        do {
            let file = try MachOFile(URL(fileURLWithPath: filePath))
            let formatter = outputFormat.makeFormatter()
            print(formatter.render(file))
        } catch let e as LoadCommandParsingError {
            print("Parse error: \(e)")
        } catch {
            print("Could not parse Mach-O at \(filePath): \(error)")
        }
    }
}

ParseMachO.main()
