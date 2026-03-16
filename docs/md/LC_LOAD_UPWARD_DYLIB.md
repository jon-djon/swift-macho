# LC_LOAD_UPWARD_DYLIB

**Command ID:** `0x80000023` (`LC_REQ_DYLD | 0x23`)

Declares an upward dependency on a dynamic library. This is used to break circular dependency cycles between libraries, most commonly within umbrella frameworks where a sub-framework needs to reference symbols from a sibling sub-framework or from the umbrella itself.

In a normal dependency graph, if library A depends on library B (`LC_LOAD_DYLIB`), then B must not also depend on A -- that would be a cycle. An upward dependency lets B declare that it uses symbols from A without creating a true circular link. `dyld` handles this by deferring binding of upward dependencies: it does not require the upward library to be fully initialized before the depending library, and it tolerates the upward library not yet being loaded when the depending library is first loaded.

Apple's system frameworks use upward dependencies extensively. For example, within the CoreServices umbrella, sub-frameworks like LaunchServices and Metadata use upward dependencies to reference each other's symbols.

The binary layout is identical to `LC_LOAD_DYLIB`. The name string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_LOAD_UPWARD_DYLIB`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the library name string | 8 | 4 | `UInt32` |
| Timestamp | Build timestamp of the linked library | 12 | 4 | `UInt32` |
| Current Version | Current version of the library at link time | 16 | 4 | `SemanticVersion` |
| Compatibility Version | Minimum compatible version required at runtime | 20 | 4 | `SemanticVersion` |
| Name | Null-terminated install name path of the upward dependency | `Name Offset` | variable | `String` |

**Minimum size:** 24 bytes (header + fixed fields, before name string)

## See Also

- [LC_LOAD_DYLIB](LC_LOAD_DYLIB.md) -- Same layout; declares a normal (downward) dependency
- [LC_REEXPORT_DYLIB](LC_REEXPORT_DYLIB.md) -- Same layout; re-exports another library's symbols
- [LC_SUB_UMBRELLA](LC_SUB_UMBRELLA.md) -- Declares a sub-umbrella within an umbrella framework

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_LOAD_UPWARD_DYLIB .swift`](../../Sources/SwiftMachO/LoadCommands/LC_LOAD_UPWARD_DYLIB%20.swift).
