# LC_IDFVMLIB

**Command ID:** `0x07`

**Obsolete.** Identifies this binary as a fixed virtual memory (FVM) shared library and records its install name, minor version, and fixed header address. This is the FVM equivalent of `LC_ID_DYLIB` -- it appears inside the library itself to declare its identity.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_IDFVMLIB`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the library name string | 8 | 4 | `UInt32` |
| Minor Version | Library's minor version number | 12 | 4 | `UInt32` |
| Header Address | Fixed virtual address of the library header | 16 | 4 | `UInt32` |
| Name | Null-terminated library pathname | `Name Offset` | variable | `String` |

**Minimum size:** 20 bytes (header + fixed fields, before name string)

## See Also

- [LC_LOADFVMLIB](LC_LOADFVMLIB.md) -- Loads an FVM library
- [LC_FVMFILE](LC_FVMFILE.md) -- References a file within the FVM system

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_IDFVMLIB.swift`](../../Sources/SwiftMachO/LoadCommands/LC_IDFVMLIB.swift).
