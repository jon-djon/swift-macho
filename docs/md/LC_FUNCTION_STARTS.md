# LC_FUNCTION_STARTS

**Command ID:** `0x26`

Points to a table of function start addresses stored in the `__LINKEDIT` segment. The data is a series of ULEB128-encoded deltas representing the offset of each function entry point relative to the `__TEXT` segment's VM address.

This information is used by debuggers, crash reporters, and profiling tools to determine function boundaries without requiring a full symbol table. It allows backtraces and sampling profilers to attribute instruction addresses to specific functions even in stripped binaries.

The load command itself is a `linkedit_data_command` that stores an offset and size pointing into `__LINKEDIT`. The referenced data is parsed into a `FunctionStarts` structure containing the decoded offset table.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_FUNCTION_STARTS`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Data Offset | File offset of the function starts data in `__LINKEDIT` | 8 | 4 | `UInt32` |
| Data Size | Size of the function starts data in bytes | 12 | 4 | `UInt32` |

**Total size:** 16 bytes

### FunctionStarts (LINKEDIT data)

The data referenced by `Data Offset` is a packed array of ULEB128-encoded unsigned integers. Each value is a delta from the previous function start address (or from the `__TEXT` segment VM address for the first entry). A zero value terminates the list.

| Name | Description | Type |
|------|-------------|------|
| Starts | Decoded function start offsets relative to `__TEXT` VM address | `[UInt]` |

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_FUNCTION_STARTS.swift`](../../Sources/SwiftMachO/LoadCommands/LC_FUNCTION_STARTS.swift).
