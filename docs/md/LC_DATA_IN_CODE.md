# LC_DATA_IN_CODE

**Command ID:** `0x29`

Points to a table of data-in-code entries stored in the `__LINKEDIT` segment. Each entry identifies a region within a code section that contains data rather than executable instructions -- for example, jump tables, constant pools, or padding embedded directly in the `__text` section.

The compiler emits these annotations so that the linker and disassemblers can distinguish data from code. Without them, tools like `otool -tv` or `lldb` would attempt to disassemble data bytes as instructions, producing garbage output. The linker also uses this information to avoid applying code-specific optimizations (like ARM64 linker optimization hints) to data regions.

The load command itself is a `linkedit_data_command` storing an offset and size into `__LINKEDIT`. The referenced data is an array of 8-byte `DataInCode` entries.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_DATA_IN_CODE`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Data Offset | File offset of the data-in-code entries in `__LINKEDIT` | 8 | 4 | `UInt32` |
| Data Size | Size of the data-in-code entries in bytes | 12 | 4 | `UInt32` |

**Fixed size:** 16 bytes

## DataInCode Entry

Each entry describes one data region within a code section.

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Offset | Offset from the start of the `__TEXT` segment to the data region | 0 | 4 | `UInt32` |
| Length | Length of the data region in bytes | 4 | 2 | `UInt16` |
| Kind | Type of data (see below) | 6 | 2 | `Kind` |

**Entry size:** 8 bytes

### Kind

| Name | Value | Description |
|------|-------|-------------|
| `data` | `1` | Generic data (e.g. constant pool) |
| `jumpTable8` | `2` | Jump table with 1-byte entries |
| `jumpTable16` | `3` | Jump table with 2-byte entries |
| `jumpTable32` | `4` | Jump table with 4-byte (relative) entries |
| `absJumpTable32` | `5` | Jump table with 4-byte absolute entries |

## See Also

- [LC_FUNCTION_STARTS](LC_FUNCTION_STARTS.md) -- Complementary command that marks where functions begin

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_DATA_IN_CODE.swift`](../../Sources/SwiftMachO/LoadCommands/LC_DATA_IN_CODE.swift).
