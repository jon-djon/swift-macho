//
//  SwiftMachOMacros.swift
//  swift-macho
//
//  Created by jon on 10/17/25.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// Example: A simple expression macro
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
        return "(\(argument), \(literal: argument.description))"
    }
}

public struct CaseNameDescriptionMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Ensure we're attached to an enum
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw CustomError.notAnEnum
        }
        
        // Extract all enum cases
        let cases = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap { $0.elements }
            .map { $0.name.text }
        
        // If no cases found, return empty
        guard !cases.isEmpty else {
            return []
        }
        
        // Build the switch cases
        let switchCases = cases.map { caseName in
            """
                case .\(caseName):
                    return "\(caseName)"
            """
        }.joined(separator: "\n        ")
        
        // Create the description property
        let descriptionProperty = """
            public var description: String {
                switch self {
                \(switchCases)
                }
            }
            """
        
        return [DeclSyntax(stringLiteral: descriptionProperty)]
    }
}

// Extension macro for adding conformance
public struct AddCustomStringConvertibleMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Only add conformance if not already conforming
        if protocols.isEmpty {
            return []
        }
        
        let customStringConvertible: DeclSyntax = """
            extension \(type.trimmed): CustomStringConvertible {}
            """
        
        guard let extensionDecl = customStringConvertible.as(ExtensionDeclSyntax.self) else {
            return []
        }
        
        return [extensionDecl]
    }
}

// Combined macro that does both
public struct CaseNameMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try CaseNameDescriptionMacro.expansion(
            of: node,
            providingMembersOf: declaration,
            in: context
        )
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        try AddCustomStringConvertibleMacro.expansion(
            of: node,
            attachedTo: declaration,
            providingExtensionsOf: type,
            conformingTo: protocols,
            in: context
        )
    }
}

enum CustomError: Error, CustomStringConvertible {
    case notAnEnum
    case notAStruct
    case unsupportedRawType(String)
    
    var description: String {
        switch self {
        case .notAnEnum:
            return "CaseName macro can only be applied to enums"
        case .notAStruct:
            return "AutoOptionSet macro can only be applied to structs"
        case .unsupportedRawType(let type):
            return "Unsupported raw type: \(type). Use .UInt8, .UInt16, .UInt32, or .UInt64"
        }
    }
}

public struct AutoOptionSetMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Get the raw value type from the macro argument
        let rawType = try getRawType(from: node)
        
        // Ensure we're attached to a struct
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw CustomError.notAStruct
        }
        
        // Extract all static option properties
        let options = extractOptions(from: structDecl)
        
        // Generate the rawValue property
        let rawValueProperty = """
            public let rawValue: \(rawType)
            """
        
        // Generate the init method
        let initMethod = """
            public init(rawValue: \(rawType)) {
                self.rawValue = rawValue
            }
            """
        
        // Generate the activeFlags property
        let activeFlagsProperty = generateActiveFlagsProperty(options: options, structName: structDecl.name.text)
        
        // Generate description property
        let descriptionProperty = """
            public var description: String {
                let flags = activeFlags
                return flags.isEmpty ? "none" : flags.map { $1 }.joined(separator: ",")
            }
            """
        
        return [
            DeclSyntax(stringLiteral: rawValueProperty),
            DeclSyntax(stringLiteral: initMethod),
            DeclSyntax(stringLiteral: activeFlagsProperty),
            DeclSyntax(stringLiteral: descriptionProperty)
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Add conformance to CustomStringConvertible if needed
        if protocols.isEmpty {
            return []
        }
        
        let customStringConvertible: DeclSyntax = """
            extension \(type.trimmed): CustomStringConvertible {}
            """
        
        guard let extensionDecl = customStringConvertible.as(ExtensionDeclSyntax.self) else {
            return []
        }
        
        return [extensionDecl]
    }
    
    private static func getRawType(from node: AttributeSyntax) throws -> String {
        // Check if there's an argument for the raw type
        guard let arguments = node.arguments,
              case .argumentList(let argList) = arguments,
              let firstArg = argList.first else {
            // Default to UInt32 if no type specified
            return "UInt32"
        }
        
        // Handle enum member access (e.g., .UInt32)
        if let memberAccess = firstArg.expression.as(MemberAccessExprSyntax.self) {
            let enumCase = memberAccess.declName.baseName.text
            
            // Map enum cases to actual type names
            switch enumCase {
            case "UInt8":
                return "UInt8"
            case "UInt16":
                return "UInt16"
            case "UInt32":
                return "UInt32"
            case "UInt64":
                return "UInt64"
            default:
                throw CustomError.unsupportedRawType(enumCase)
            }
        }
        
        // Default fallback
        return "UInt32"
    }
    
    private static func extractOptions(from structDecl: StructDeclSyntax) -> [(name: String, value: String)] {
        var options: [(name: String, value: String)] = []
        
        for member in structDecl.memberBlock.members {
            // Look for static var or static let declarations
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               varDecl.modifiers.contains(where: { $0.name.text == "static" }) {
                
                for binding in varDecl.bindings {
                    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                        continue
                    }
                    
                    let name = identifier.identifier.text
                    
                    // Check for direct initialization pattern: static let NAME = TypeName(rawValue: VALUE)
                    if let initializer = binding.initializer?.value,
                       let funcCall = initializer.as(FunctionCallExprSyntax.self) {
                        
                        // Check if it's a direct type initialization
                        if let arg = funcCall.arguments.first,
                           arg.label?.text == "rawValue",
                           let intLiteral = arg.expression.as(IntegerLiteralExprSyntax.self) {
                            
                            let value = intLiteral.literal.text
                            options.append((name: name, value: value))
                            continue
                        }
                    }
                    
                    // Check for computed property pattern: static var NAME: Type { .init(rawValue: VALUE) }
                    if let getter = binding.accessorBlock?.accessors.as(AccessorDeclListSyntax.self)?.first {
                        // Extract the raw value from the getter body
                        if let returnStmt = getter.body?.statements.first?.item.as(ReturnStmtSyntax.self),
                           let funcCall = returnStmt.expression?.as(FunctionCallExprSyntax.self),
                           let memberAccess = funcCall.calledExpression.as(MemberAccessExprSyntax.self),
                           memberAccess.declName.baseName.text == "init",
                           let arg = funcCall.arguments.first,
                           let intLiteral = arg.expression.as(IntegerLiteralExprSyntax.self) {
                            
                            let value = intLiteral.literal.text
                            options.append((name: name, value: value))
                        }
                    }
                }
            }
        }
        
        return options
    }
    
    private static func generateActiveFlagsProperty(options: [(name: String, value: String)], structName: String) -> String {
        if options.isEmpty {
            return """
                public var activeFlags: [(Self, String)] {
                    return []
                }
                """
        }
        
        let checks = options.map { option in
            """
                    if self.contains(.\(option.name)) {
                        flags.append((.\(option.name),"\(option.name)"))
                    }
            """
        }.joined(separator: "\n")
        
        return """
             public var activeFlags: [(Self, String)] {
                var flags: [(Self, String)] = []
            \(checks)
                return flags
            }
            """
    }
}

// Plugin entry point
@main
struct SwiftMachOMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        CaseNameMacro.self,
        AutoOptionSetMacro.self,
    ]
}
