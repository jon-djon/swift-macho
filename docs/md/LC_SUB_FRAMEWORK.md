# LC_SUB_FRAMEWORK

**Command ID:** `0x12`

Identifies the umbrella framework that this sub-framework belongs to. When a framework is part of a larger umbrella framework (e.g. `AppKit` is a sub-framework of `Cocoa`), this command records the umbrella's name so that the linker and `dyld` can enforce linking restrictions.

A sub-framework with this command can only be directly linked by its umbrella framework or by other sub-frameworks within the same umbrella. Clients must link against the umbrella instead. This enforces encapsulation -- Apple can reorganize sub-frameworks without breaking client code.

The name string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_SUB_FRAMEWORK`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the umbrella name string | 8 | 4 | `UInt32` |
| Umbrella Name | Null-terminated name of the parent umbrella framework | `Name Offset` | variable | `String` |

**Minimum size:** 12 bytes (header + fixed fields, before name string)

## See Also

- [LC_SUB_UMBRELLA](LC_SUB_UMBRELLA.md) -- Declares a sub-umbrella within an umbrella framework
- [LC_SUB_CLIENT](LC_SUB_CLIENT.md) -- Restricts which clients can link against a sub-framework
- [LC_SUB_LIBRARY](LC_SUB_LIBRARY.md) -- Declares a sub-library within an umbrella

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_SUB_FRAMEWORK.swift`](../../Sources/SwiftMachO/LoadCommands/LC_SUB_FRAMEWORK.swift).
