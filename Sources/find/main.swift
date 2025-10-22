import Foundation
import ArgumentParser
import SwiftMachO

struct Find: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Check if a file is a Mach-O binary and print its path if it is."
    )

    @Argument(help: "The path to the file to check.")
    var filePath: String

    func run() throws {
        let fileURL = URL(fileURLWithPath: filePath)

        // Try to parse the file as a Mach-O
        do {
            _ = try MachOFile(fileURL)
            // If successful, print the file path
            print(filePath)
        } catch {
            // If it fails, the file is not a Mach-O, so we don't print anything
        }
    }
}

Find.main()
