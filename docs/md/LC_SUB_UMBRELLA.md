# LC_SUB_UMBRELLA

**Command ID:** `0x11` (17)

Identifies a sub-umbrella framework that this framework re-exports. This command specifies the name of another umbrella framework whose symbols should be made visible to clients linking against this framework.

## Purpose

LC_SUB_UMBRELLA is part of the two-level namespace mechanism used in macOS frameworks. An umbrella framework is a framework that bundles multiple sub-frameworks together and re-exports their symbols. This command allows the linker to:

- Resolve symbols from sub-umbrella frameworks as if they came from the main umbrella
- Maintain proper symbol visibility across framework boundaries
- Support complex framework dependencies and layering

For example, the Cocoa umbrella framework re-exports symbols from Foundation, AppKit, and CoreData frameworks. Each of these would be identified by an LC_SUB_UMBRELLA command in Cocoa.framework.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_SUB_UMBRELLA`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (variable) | 4 | 4 | `UInt32` |
| String Offset | Offset from the start of the command to the umbrella name string | 8 | 4 | `UInt32` |
| Umbrella Name | Name of the sub-umbrella framework (null-terminated UTF-8 string) | Variable | Variable | `String` |

**Minimum size:** 12 bytes (header + offset) + string length + 1 (null terminator)

## Usage

This command is typically found in umbrella frameworks that bundle multiple sub-frameworks. Common examples include:

- **Cocoa.framework** - Contains LC_SUB_UMBRELLA commands for Foundation, AppKit, CoreData
- **Carbon.framework** - Contains LC_SUB_UMBRELLA commands for various Carbon sub-frameworks
- **WebKit.framework** - Contains LC_SUB_UMBRELLA commands for JavaScriptCore and other WebKit sub-frameworks

When a client links against an umbrella framework, the dynamic linker uses LC_SUB_UMBRELLA commands to know which sub-frameworks' symbols should be resolved through the umbrella framework.

## Related Commands

- **LC_SUB_FRAMEWORK** - Identifies the parent umbrella framework (used in sub-frameworks)
- **LC_SUB_CLIENT** - Restricts which clients can link against this framework
- **LC_SUB_LIBRARY** - Similar to LC_SUB_UMBRELLA but for libraries instead of frameworks
- **LC_REEXPORT_DYLIB** - Modern alternative that re-exports an entire dynamic library

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_SUB_UMBRELLA.swift`](../../Sources/SwiftMachO/LoadCommands/LC_SUB_UMBRELLA.swift).
