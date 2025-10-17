//
//  Untitled.swift
//  swift-macho
//
//  Created by jon on 9/29/25.
//
import BinaryParsing

public protocol LoadCommand: CustomStringConvertible, Displayable, Parseable {
    var header: LoadCommandHeader { get }
}

public protocol LoadCommandLinkEdit {
    var offset: UInt32 { get }
    var size: UInt32 { get }
}

public protocol SimpleCommand { }

extension SimpleCommand {
    
}

public enum LoadCommandValues {
    case LC_CODE_SIGNATURE(LoadCommand, CodeSignatureSuperBlob)
    case LC_FUNCTION_STARTS(LoadCommand, FunctionStarts)
    case LC_SYMTAB(LoadCommand, [Symbol], [String])
    case LC_TODO(LoadCommand)
    case LC_LOAD_DYLIB(LoadCommand)
    case LC_LOAD_WEAK_DYLIB(LoadCommand)
    case LC_DYLD_ENVIRONMENT(LoadCommand)
    case LC_DYLD_INFO_ONLY(LoadCommand)
    case LC_ENCRYPTION_INFO(LoadCommand)
    case LC_ENCRYPTION_INFO_64(LoadCommand)
}



public struct LC_TODO: LoadCommand, Parseable {
    public let header: LoadCommandHeader
    public let range: Range<Int>
}

extension LC_TODO {
    public init(parsing input: inout ParserSpan, endianness: Endianness) throws {
        self.range = input.parserRange.range
        self.header = try LoadCommandHeader(parsing: &input, endianness: endianness)
    }
}

extension LC_TODO: Displayable {
    public var title: String { "\(Self.self) (TODO)" }
    public var description: String { "" }
    public var fields: [DisplayableField] {
        [
            .init(label: "ID", stringValue: header.id.description, offset: 0, size: 4, children: nil, obj: self),
            .init(label: "Size", stringValue: header.cmdSize.description, offset: 4, size: 4, children: nil, obj: self),
        ]
    }
    public var children: [Displayable]? { nil }
}
