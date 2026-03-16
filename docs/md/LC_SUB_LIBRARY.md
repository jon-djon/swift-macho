# LC_SUB_LIBRARY

**Command ID:** `0x15`

Identifies a sub-library that this library re-exports as part of an umbrella library. This is the library-level analog of `LC_SUB_UMBRELLA` (which is for frameworks). The umbrella library re-exports all symbols from its sub-libraries so that clients linking against the umbrella automatically gain access to them.

The name string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_SUB_LIBRARY`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the sub-library name string | 8 | 4 | `UInt32` |
| Sub-Library Name | Null-terminated name of the sub-library | `Name Offset` | variable | `String` |

**Minimum size:** 12 bytes (header + fixed fields, before name string)

## See Also

- [LC_SUB_UMBRELLA](LC_SUB_UMBRELLA.md) -- Framework-level equivalent
- [LC_SUB_FRAMEWORK](LC_SUB_FRAMEWORK.md) -- Identifies the umbrella a sub-framework belongs to
- [LC_REEXPORT_DYLIB](LC_REEXPORT_DYLIB.md) -- Modern way to re-export another library's symbols

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_SUB_LIBRARY.swift`](../../Sources/SwiftMachO/LoadCommands/LC_SUB_LIBRARY.swift).
