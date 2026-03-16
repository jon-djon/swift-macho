# LC_REEXPORT_DYLIB

**Command ID:** `0x8000001F` (`LC_REQ_DYLD | 0x1F`)

Declares that this image re-exports all symbols from another dynamic library. When a client links against this image, it automatically gains access to the re-exported library's symbols without needing to link against it directly.

Re-exporting is commonly used by umbrella frameworks. For example, the `Cocoa` framework re-exports `AppKit`, `Foundation`, and `CoreData` so that clients linking against `Cocoa` can use symbols from any of those sub-frameworks transparently. It is also used when a library is reorganized -- the old library path can re-export the new one so that existing clients continue to work.

The binary layout is identical to `LC_LOAD_DYLIB`: the command stores a name offset, timestamp, and version information. The only difference is the command ID, which tells `dyld` to merge the re-exported library's exports into this image's export namespace rather than keeping them separate.

The name string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_REEXPORT_DYLIB`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the library name string | 8 | 4 | `UInt32` |
| Timestamp | Build timestamp of the linked library | 12 | 4 | `UInt32` |
| Current Version | Current version of the library at link time | 16 | 4 | `SemanticVersion` |
| Compatibility Version | Minimum compatible version required at runtime | 20 | 4 | `SemanticVersion` |
| Name | Null-terminated install name path of the re-exported library | `Name Offset` | variable | `String` |

**Minimum size:** 24 bytes (header + fixed fields, before name string)

## See Also

- [LC_LOAD_DYLIB](LC_LOAD_DYLIB.md) -- Same binary layout; loads a required dependency without re-exporting
- [LC_LOAD_WEAK_DYLIB](LC_LOAD_WEAK_DYLIB.md) -- Same binary layout; loads an optional dependency without re-exporting
- [LC_SUB_UMBRELLA](LC_SUB_UMBRELLA.md) -- Declares a sub-umbrella within an umbrella framework

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_REEXPORT_DYLIB.swift`](../../Sources/SwiftMachO/LoadCommands/LC_REEXPORT_DYLIB.swift).
