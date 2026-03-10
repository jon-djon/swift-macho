import SwiftMachO

public struct DisplayableNode: Codable, Sendable {
    public let title: String
    public let description: String
    public let fields: [FieldNode]
    public let children: [DisplayableNode]?
}

public struct FieldNode: Codable, Sendable {
    public let label: String
    public let value: String
    public let children: [FieldNode]?
}

extension DisplayableNode {
    public static func from(_ node: any Displayable) -> DisplayableNode {
        DisplayableNode(
            title: node.title,
            description: node.description,
            fields: node.fields.map { FieldNode.from($0) },
            children: node.children.map { $0.map { DisplayableNode.from($0) } }
        )
    }
}

extension FieldNode {
    static func from(_ field: DisplayableField) -> FieldNode {
        FieldNode(
            label: field.label,
            value: field.stringValue,
            children: field.children.map { $0.map { FieldNode.from($0) } }
        )
    }
}
