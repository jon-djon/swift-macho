//
//  SwiftMachO.swift
//  swift-macho
//
//  Created by jon on 10/17/25.
//

// Declare the macro's public interface
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(
    module: "SwiftMachOMacros",
    type: "StringifyMacro"
)

@attached(member, names: named(description))
@attached(extension, conformances: CustomStringConvertible)
public macro CaseName() = #externalMacro(
    module: "SwiftMachOMacros",
    type: "CaseNameMacro"
)

/// Enum representing supported raw value types for OptionSet
public enum RawType {
    case UInt8
    case UInt16
    case UInt32
    case UInt64
}

/// Automatically adds OptionSet boilerplate including rawValue, init, and activeFlags property
///
/// - Parameter rawType: The type of the raw value (defaults to .UInt32)
///
/// Example usage:
/// ```swift
/// @AutoOptionSet(.UInt32)
/// public struct MyOptions: OptionSet {
///     static var option1: MyOptions { .init(rawValue: 0x01) }
///     static var option2: MyOptions { .init(rawValue: 0x02) }
/// }
/// ```
@attached(member, names: named(rawValue), named(init(rawValue:)), named(activeFlags), named(description))
@attached(extension, conformances: CustomStringConvertible)
public macro AutoOptionSet(_ rawType: RawType = .UInt32) = #externalMacro(
    module: "SwiftMachOMacros",
    type: "AutoOptionSetMacro"
)
