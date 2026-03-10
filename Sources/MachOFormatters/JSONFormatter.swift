import Foundation

public struct JSONFormatter: MachOFormatter {
    public init() {}

    public func format(_ node: DisplayableNode) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard
            let data = try? encoder.encode(node),
            let string = String(data: data, encoding: .utf8)
        else { return "{}" }
        return string
    }
}
