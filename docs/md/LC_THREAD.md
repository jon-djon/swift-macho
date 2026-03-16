# LC_THREAD

**Command ID:** `0x04`

Specifies an initial thread state without setting the program counter. This command has the same binary layout as `LC_UNIXTHREAD` -- a flavor, count, and architecture-specific register data -- but semantically it creates an additional thread rather than defining the process entry point.

`LC_THREAD` was used in core dump files and some early Mach-O binaries to record thread states. It is rarely encountered in modern binaries. The implementation currently parses only the load command header; see `LC_UNIXTHREAD` for the full thread state format including flavor values and register layouts.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_THREAD`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including thread state) | 4 | 4 | `UInt32` |
| Flavor | Thread state flavor identifying the architecture | 8 | 4 | `UInt32` |
| Count | Number of 32-bit words in the thread state data | 12 | 4 | `UInt32` |
| Thread State | Architecture-specific register state | 16 | variable | varies |

**Minimum size:** 16 bytes (header + flavor + count, before thread state)

## See Also

- [LC_UNIXTHREAD](LC_UNIXTHREAD.md) -- Same layout; sets the program counter to define the entry point
- [LC_MAIN](LC_MAIN.md) -- Modern entry point command

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_THREAD.swift`](../../Sources/SwiftMachO/LoadCommands/LC_THREAD.swift).
