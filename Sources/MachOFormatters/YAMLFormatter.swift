public struct YAMLFormatter: MachOFormatter {
    public init() {}

    public func format(_ node: DisplayableNode) -> String {
        var lines: [String] = []
        appendNode(node, indent: 0, into: &lines)
        return lines.joined(separator: "\n")
    }

    private func appendNode(_ node: DisplayableNode, indent: Int, into lines: inout [String]) {
        let pad = String(repeating: "  ", count: indent)
        lines.append("\(pad)title: \(yamlScalar(node.title))")
        if !node.description.isEmpty {
            lines.append("\(pad)description: \(yamlScalar(node.description))")
        }
        if !node.fields.isEmpty {
            lines.append("\(pad)fields:")
            for field in node.fields {
                appendField(field, indent: indent + 1, into: &lines)
            }
        }
        if let children = node.children, !children.isEmpty {
            lines.append("\(pad)children:")
            for child in children {
                lines.append("\(pad)  -")
                appendNode(child, indent: indent + 2, into: &lines)
            }
        }
    }

    private func appendField(_ field: FieldNode, indent: Int, into lines: inout [String]) {
        let pad = String(repeating: "  ", count: indent)
        lines.append("\(pad)- label: \(yamlScalar(field.label))")
        lines.append("\(pad)  value: \(yamlScalar(field.value))")
        if let children = field.children, !children.isEmpty {
            lines.append("\(pad)  fields:")
            for child in children {
                appendField(child, indent: indent + 2, into: &lines)
            }
        }
    }

    private func yamlScalar(_ value: String) -> String {
        let needsQuoting = value.contains(":") || value.contains("#")
            || value.contains("\"") || value.contains("'")
            || value.hasPrefix(" ") || value.isEmpty
        guard needsQuoting else { return value }
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        return "\"\(escaped)\""
    }
}
