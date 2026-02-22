public struct LoadCommandParsingError: Error, CustomStringConvertible {
    /// 0-based position of the command within the load command array
    public let commandIndex: Int
    /// The parsed command type, or nil if the LoadCommandHeader itself failed to parse
    public let commandID: LoadCommandHeader.ID?
    /// Byte offset from the start of the MachO data where this command begins
    public let commandOffset: Int
    /// The original error thrown by the parser
    public let underlyingError: any Error

    public var description: String {
        let idStr = commandID.map { " (\($0))" } ?? " (unknown type)"
        let offsetStr = String(commandOffset, radix: 16, uppercase: false)
        return "Failed to parse load command #\(commandIndex)\(idStr) "
             + "at offset 0x\(offsetStr): \(underlyingError)"
    }
}
