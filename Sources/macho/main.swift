import ArgumentParser
import Foundation
import SwiftMachO
import X509

// MARK: - Tree Printer
class TreePrinter {
    // Configuration for tree drawing characters
    struct TreeChars {
        static let branch = "├── "
        static let lastBranch = "└── "
        static let vertical = "│   "
        static let space = "    "
    }

    // Print the entire tree starting from root
    static func printTree(_ node: Displayable, title: String = "Root") {
        print(title)
        printNode(node, prefix: "", isLast: true)
    }

    // Recursive function to print each node
    private static func printNode(_ node: Displayable, prefix: String, isLast: Bool) {

        for (index, field) in node.fields.enumerated() {
            let isLastField = index == node.fields.count - 1 && (node.children?.isEmpty ?? true)
            let connector = isLastField && isLast ? TreeChars.lastBranch : TreeChars.branch
            let label = field.label.padding(toLength: 20, withPad: " ", startingAt: 0)
            let value = field.stringValue.padding(toLength: 20, withPad: " ", startingAt: 0)
            print("\(prefix)\(connector)\(label)Value: \(value)")
            //           print("\(prefix)\(connector)\(label)Offset: \(range.hexDescription) M Offset: \(mOffset.hexDescription) Value: \(value) Data: \(file.data.hexString(in: range))")
            // print("\(prefix)\(connector)\(key): \(value)")
        }

        // Print children
        if let children = node.children, !children.isEmpty {
            for (index, child) in children.enumerated() {
                let isLastChild = index == children.count - 1
                let childPrefix = prefix + (isLast ? TreeChars.space : TreeChars.vertical)

                // Print child indicator
                let connector = isLastChild ? TreeChars.lastBranch : TreeChars.branch
                print("\(prefix)\(connector)[\(child.title)]")

                // Recursively print child node
                let grandchildPrefix = childPrefix
                printNode(child, prefix: grandchildPrefix, isLast: isLastChild)
            }
        }
    }
}

// --- Command-Line Tool Definition ---

struct ParseMachO: ParsableCommand {
    // Customize the help message and description for the tool.
    static let configuration = CommandConfiguration(
        abstract: "Checks if a file is a valid Mach-O executable by inspecting its magic number."
    )

    // Define the file path as a required command-line argument.
    @Argument(help: "The path to the file to check.")
    var filePath: String = ""

    // The main logic is now in the `run()` method.
    func run() throws {
        // let path = "/Applications/Bear.app/Contents/MacOS/Bear"
        let path =
            "/Users/jon/Library/Application Support/discord/WidevineCdm/4.10.2891.0/_platform_specific/mac_arm64/libwidevinecdm.dylib"

        guard MachOFile.isMachoFile(URL(fileURLWithPath: path)) else {
            print("Could not parse Mach-O at \(filePath)")
            return
        }

        guard let file = try? MachOFile(URL(fileURLWithPath: path)) else {
            print("Could not parse Mach-O at \(filePath)")
            return
        }

        // TreePrinter.printTree(file, title: file.description)

        if case .fat(let fatBinary) = file.file {
            for macho: MachO in fatBinary.machos {
                if let (_, signature) = macho.getSignature() {

                    for blob in signature.blobs {
                        print(blob.description)
                        //                        if case .BlobWrapper(let blob, let wrapper) = blob {
                        //                            try wrapper.cmsData.write(to: URL(fileURLWithPath: "/Users/jon/code/swift-macho/tmp/signeddata.bin"), options: [.atomic])
                        //                        }

                        //                        if case .CodeRequirements(let blob, let codeSignatureCodeRequirements) = blob {
                        //                            for (header, requirement) in codeSignatureCodeRequirements.requirements {
                        //                                if let expression = try? requirement.buildExpressionString() {
                        //                                    print("******* \(expression)")
                        //                                }
                        //                            }
                        //                        }
                    }
                }
                try file.validateSignature(macho)
            }
        } else if case .macho(let macho) = file.file {
            if let (_, signature) = macho.getSignature() {

                for blob in signature.blobs {
                    if case .CodeDirectory(let blob, let magic) = blob {
                        print("Code Directory Identifier: \(blob.type), \(magic.description)")
                    }
                }

            }
        }

        //        switch file.file {
        //        case .fat(let fatBinary):
        //            for binary in fatBinary.machos {
        //                for field in binary.header.fields {
        //                    let range = binary.header.getAbsoluteFieldRange(field)
        //                    let mOffset = binary.getMachoOffset(range)
        //                    let label = field.label.padding(toLength: 20, withPad: " ", startingAt: 0)
        //                    let value = field.stringValue.padding(toLength: 20, withPad: " ", startingAt: 0)
        //                    print("\(label)Offset: \(range.hexDescription) M Offset: \(mOffset.hexDescription) Value: \(value) Data: \(file.data.hexString(in: range))")
        //                }
        //
        //                // dump(binary.header)
        //    //            for cmd in binary.loadCommands {
        //    //                if let _cmd = cmd as? LC_FUNCTION_STARTS {
        //    //                    dump(_cmd)
        //    //                }
        //    //            }
        //            }
        //        case .macho(let machO):
        //            break
        //        }
    }
}

// --- Entry Point ---
// This starts the command-line tool and handles parsing the arguments.
ParseMachO.main()
