import SwiftMachO

public protocol MachOFormatter {
    func format(_ node: DisplayableNode) -> String
}

extension MachOFormatter {
    public func render(_ displayable: any Displayable) -> String {
        format(DisplayableNode.from(displayable))
    }
}

public enum OutputFormat: String, CaseIterable, Sendable {
    case tree
    case json
    case yaml

    public func makeFormatter() -> any MachOFormatter {
        switch self {
        case .tree: return TreeFormatter()
        case .json: return JSONFormatter()
        case .yaml: return YAMLFormatter()
        }
    }
}
