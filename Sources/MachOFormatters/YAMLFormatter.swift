public struct YAMLFormatter: MachOFormatter {
    public init() {}

    public func format(_ node: DisplayableNode) -> String {
        var lines: [String] = []
        appendNode(node, indent: 0, into: &lines)
        return lines.joined(separator: "\n")
    }

    private func appendNode(_ node: DisplayableNode, indent: Int, into lines: inout [String]) {
        let pad = String(repeating: "  ", count: indent)
        lines.append("\(pad)\(yamlScalar(node.title)):")

        for field in node.fields {
            appendField(field, indent: indent + 1, into: &lines)
        }

        if let children = node.children, !children.isEmpty {
            for child in children {
                appendNode(child, indent: indent + 1, into: &lines)
            }
        }
    }

    private func appendField(_ field: FieldNode, indent: Int, into lines: inout [String]) {
        let pad = String(repeating: "  ", count: indent)
        if let children = field.children, !children.isEmpty {
            if field.value.isEmpty {
                lines.append("\(pad)\(yamlScalar(field.label)):")
            } else {
                lines.append("\(pad)\(yamlScalar(field.label)):")
                lines.append("\(pad)  _value: \(yamlScalar(field.value))")
            }
            for child in children {
                appendField(child, indent: indent + 1, into: &lines)
            }
        } else {
            lines.append("\(pad)\(yamlScalar(field.label)): \(yamlScalar(field.value))")
        }
    }

    private func yamlScalar(_ value: String) -> String {
        let needsQuoting = value.contains(":") || value.contains("#")
            || value.contains("\"") || value.contains("'")
            || value.hasPrefix(" ") || value.isEmpty
            || value.contains("{") || value.contains("}")
            || value.contains("[") || value.contains("]")
        guard needsQuoting else { return value }
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        return "\"\(escaped)\""
    }
}
