import Foundation

public struct JSONFormatter: MachOFormatter {
    public init() {}

    public func format(_ node: DisplayableNode) -> String {
        let dict = buildNode(node)
        guard let data = try? JSONSerialization.data(
            withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
            let string = String(data: data, encoding: .utf8)
        else { return "{}" }
        return string
    }

    private func buildNode(_ node: DisplayableNode) -> [String: Any] {
        var dict: [String: Any] = [:]

        for field in node.fields {
            addField(field, to: &dict)
        }

        if let children = node.children, !children.isEmpty {
            for child in children {
                let key = child.title
                let value = buildNode(child)
                dict[key] = value
            }
        }

        return dict
    }

    private func addField(_ field: FieldNode, to dict: inout [String: Any]) {
        if let children = field.children, !children.isEmpty {
            var nested: [String: Any] = [:]
            if !field.value.isEmpty {
                nested["_value"] = field.value
            }
            for child in children {
                addField(child, to: &nested)
            }
            dict[field.label] = nested
        } else {
            dict[field.label] = field.value
        }
    }
}
