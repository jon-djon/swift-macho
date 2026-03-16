# LC_FVMFILE

**Command ID:** `0x09`

**Obsolete.** References a file to be mapped into the fixed virtual memory (FVM) address space. This command was part of the early NeXT/Mach FVM shared library system and is not used by any modern toolchain.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_FVMFILE`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the pathname string | 8 | 4 | `UInt32` |
| Header Address | Fixed virtual address for the file | 12 | 4 | `UInt32` |
| Name | Null-terminated file pathname | `Name Offset` | variable | `String` |

**Minimum size:** 16 bytes (header + fixed fields, before name string)

## See Also

- [LC_LOADFVMLIB](LC_LOADFVMLIB.md) -- Loads an FVM shared library
- [LC_IDFVMLIB](LC_IDFVMLIB.md) -- Identifies an FVM shared library

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_FVMFILE.swift`](../../Sources/SwiftMachO/LoadCommands/LC_FVMFILE.swift).
