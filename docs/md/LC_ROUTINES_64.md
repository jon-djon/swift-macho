# LC_ROUTINES_64

**Command ID:** `0x1A`

**Obsolete.** The 64-bit counterpart to `LC_ROUTINES`. Specifies the address of the shared library initialization routine for a 64-bit binary, with 64-bit address and module fields.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_ROUTINES_64`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (72 bytes) | 4 | 4 | `UInt32` |
| Init Address | Virtual address of the initialization routine | 8 | 8 | `UInt64` |
| Init Module | Index into the module table for the init routine's module | 16 | 8 | `UInt64` |
| Reserved 1-6 | Reserved fields (should be zero) | 24 | 48 | `UInt64` x 6 |

**Fixed size:** 72 bytes

## See Also

- [LC_ROUTINES](LC_ROUTINES.md) -- 32-bit variant

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_ROUTINES_64.swift`](../../Sources/SwiftMachO/LoadCommands/LC_ROUTINES_64.swift).
