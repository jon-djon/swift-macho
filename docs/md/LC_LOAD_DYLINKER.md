# LC_LOAD_DYLINKER

**Command ID:** `0x0E`

Specifies the path to the dynamic linker that the kernel should use to load the executable. On Apple platforms this is typically `/usr/lib/dyld`.

When the kernel loads a Mach-O executable, it reads this command to locate the dynamic linker binary, maps it into the process address space, and transfers control to it. The dynamic linker then takes over to load all dependent libraries (identified by `LC_LOAD_DYLIB` commands), perform symbol binding, and jump to the executable's entry point.

The name string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_LOAD_DYLINKER`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the dylinker name string | 8 | 4 | `UInt32` |
| Name | Null-terminated path to the dynamic linker (e.g. `/usr/lib/dyld`) | `Name Offset` | variable | `String` |

**Minimum size:** 12 bytes (header + fixed fields, before name string)

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_LOAD_DYLINKER.swift`](../../Sources/SwiftMachO/LoadCommands/LC_LOAD_DYLINKER.swift).
