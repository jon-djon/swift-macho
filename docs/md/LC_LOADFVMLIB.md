# LC_LOADFVMLIB

**Command ID:** `0x06`

**Obsolete.** Specifies a fixed virtual memory (FVM) shared library to load. FVM libraries were an early shared library mechanism on NeXT/Mach systems where libraries were mapped at fixed virtual addresses. They were superseded by dynamically-loaded libraries (`LC_LOAD_DYLIB`) and `dyld`.

The command records the library's name, minor version, and the fixed virtual address of its header.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_LOADFVMLIB`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the library name string | 8 | 4 | `UInt32` |
| Minor Version | Library's minor version number | 12 | 4 | `UInt32` |
| Header Address | Fixed virtual address of the library header | 16 | 4 | `UInt32` |
| Name | Null-terminated library pathname | `Name Offset` | variable | `String` |

**Minimum size:** 20 bytes (header + fixed fields, before name string)

## See Also

- [LC_IDFVMLIB](LC_IDFVMLIB.md) -- Identifies this binary as an FVM library
- [LC_LOAD_DYLIB](LC_LOAD_DYLIB.md) -- Modern replacement for loading shared libraries

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_LOADFVMLIB.swift`](../../Sources/SwiftMachO/LoadCommands/LC_LOADFVMLIB.swift).
