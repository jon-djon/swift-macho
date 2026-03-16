# LC_SUB_CLIENT

**Command ID:** `0x14`

Restricts which binaries are allowed to link directly against this sub-framework. Each `LC_SUB_CLIENT` command names one permitted client. If a binary that is not listed as a sub-client attempts to link against the sub-framework, the static linker will reject it.

This command works alongside `LC_SUB_FRAMEWORK` to enforce umbrella framework encapsulation. Normally, only the umbrella framework itself can link against its sub-frameworks. `LC_SUB_CLIENT` provides exceptions -- for example, allowing a specific Apple application to link directly against a private sub-framework.

The name string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_SUB_CLIENT`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the client name string | 8 | 4 | `UInt32` |
| Name | Null-terminated name of the permitted client | `Name Offset` | variable | `String` |

**Minimum size:** 12 bytes (header + fixed fields, before name string)

## See Also

- [LC_SUB_FRAMEWORK](LC_SUB_FRAMEWORK.md) -- Identifies the umbrella this sub-framework belongs to
- [LC_SUB_UMBRELLA](LC_SUB_UMBRELLA.md) -- Declares a sub-umbrella within an umbrella framework

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_SUB_CLIENT.swift`](../../Sources/SwiftMachO/LoadCommands/LC_SUB_CLIENT.swift).
