import Foundation

public enum MachOError: Error, CustomStringConvertible {
    case unsupportedFile(String)
    case unsupportedMachO(String)
    case LoadCommandError(String)
    case badMagicValue(String)
    case parsingError(String)
    case invalidSignature
    case unknownError

    public var description: String {
        switch self {
        case .unsupportedFile(let format): "The file format '\(format)' is not supported."
        case .unsupportedMachO(let message): message
        case .LoadCommandError(let message): message
        case .unknownError: "An unknown error occurred."
        case .invalidSignature: "Signature did not validate"
        case .parsingError(let message): "Error while parsing: \(message)"
        case .badMagicValue(let message): "The Mach-O magic value is invalid: \(message)"
        }
    }
}
