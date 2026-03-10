public struct TreeFormatter: MachOFormatter {
    private enum Chars {
        static let branch     = "├── "
        static let lastBranch = "└── "
        static let vertical   = "│   "
        static let space      = "    "
    }

    public init() {}

    public func format(_ node: DisplayableNode) -> String {
        var lines: [String] = [node.title]
        if !node.description.isEmpty {
            lines.append("    \(node.description)")
        }
        appendNode(node, prefix: "", isLast: true, into: &lines)
        return lines.joined(separator: "\n")
    }

    private func appendNode(
        _ node: DisplayableNode,
        prefix: String,
        isLast: Bool,
        into lines: inout [String]
    ) {
        let hasChildren = !(node.children ?? []).isEmpty
        for (i, field) in node.fields.enumerated() {
            let last = !hasChildren && i == node.fields.count - 1
            appendField(field, prefix: prefix, isLast: last, into: &lines)
        }
        if let children = node.children {
            for (i, child) in children.enumerated() {
                let lastChild = i == children.count - 1
                let connector = lastChild ? Chars.lastBranch : Chars.branch
                lines.append("\(prefix)\(connector)[\(child.title)]")
                let childPrefix = prefix + (lastChild ? Chars.space : Chars.vertical)
                appendNode(child, prefix: childPrefix, isLast: lastChild, into: &lines)
            }
        }
    }

    private func appendField(
        _ field: FieldNode,
        prefix: String,
        isLast: Bool,
        into lines: inout [String]
    ) {
        let connector = isLast ? Chars.lastBranch : Chars.branch
        let label = field.label.padding(toLength: 24, withPad: " ", startingAt: 0)
        lines.append("\(prefix)\(connector)\(label)\(field.value)")
        if let children = field.children {
            let childPrefix = prefix + (isLast ? Chars.space : Chars.vertical)
            for (j, child) in children.enumerated() {
                appendField(child, prefix: childPrefix, isLast: j == children.count - 1, into: &lines)
            }
        }
    }
}
