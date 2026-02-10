# LC_LOAD_WEAK_DYLIB

**Command ID:** `0x80000018` (`LC_REQ_DYLD | 0x18`)

Declares an optional dynamic library dependency. Unlike `LC_LOAD_DYLIB`, if the specified library cannot be found at runtime the executable will still launch. Any symbols imported from the missing library are bound to `NULL`, and the program is responsible for checking availability before calling them.

This is the mechanism behind weak linking on Apple platforms. It allows executables to conditionally use newer frameworks or libraries that may not exist on older OS versions, falling back gracefully when they are absent.

The binary layout is identical to `LC_LOAD_DYLIB`. The name string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_LOAD_WEAK_DYLIB`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the library name string | 8 | 4 | `UInt32` |
| Timestamp | Build timestamp of the linked library | 12 | 4 | `UInt32` |
| Current Version | Current version of the library at link time | 16 | 4 | `SemanticVersion` |
| Compatibility Version | Minimum compatible version required at runtime | 20 | 4 | `SemanticVersion` |
| Name | Null-terminated install name path of the dynamic library | `Name Offset` | variable | `String` |

**Minimum size:** 24 bytes (header + fixed fields, before name string)

## See Also

- [LC_LOAD_DYLIB](LC_LOAD_DYLIB.md) - Required dylib dependency (identical layout)

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_LOAD_WEAK_DYLIB.swift`](../../Sources/SwiftMachO/LoadCommands/LC_LOAD_WEAK_DYLIB.swift).
