import Foundation

public enum MachOError: Error, CustomStringConvertible {
    case unsupportedFile(String)
    case LoadCommandError(String)
    case badMagicValue(String)
    case unknownError

    public var description: String {
        switch self {
        case .unsupportedFile(let format): "The file format '\(format)' is not supported."
        case .LoadCommandError(let message): message
        case .unknownError: "An unknown error occurred."
        case .badMagicValue(let message): "The Mach-O magic value is invalid: \(message)"
        }
    }
}
