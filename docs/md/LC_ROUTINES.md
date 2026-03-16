# LC_ROUTINES

**Command ID:** `0x11`

**Obsolete.** Specifies the address of the shared library initialization routine for a 32-bit binary. When `dyld` loaded a library containing this command, it would call the function at the given address before the library's symbols became available to clients.

This command was used in the multi-module dynamic library era. Modern libraries use `__mod_init_func` section pointers or `__attribute__((constructor))` functions instead, which are processed through the `LC_SEGMENT` machinery.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_ROUTINES`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (40 bytes) | 4 | 4 | `UInt32` |
| Init Address | Virtual address of the initialization routine | 8 | 4 | `UInt32` |
| Init Module | Index into the module table for the init routine's module | 12 | 4 | `UInt32` |
| Reserved 1-6 | Reserved fields (should be zero) | 16 | 24 | `UInt32` x 6 |

**Fixed size:** 40 bytes

## See Also

- [LC_ROUTINES_64](LC_ROUTINES_64.md) -- 64-bit variant

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_ROUTINES.swift`](../../Sources/SwiftMachO/LoadCommands/LC_ROUTINES.swift).
