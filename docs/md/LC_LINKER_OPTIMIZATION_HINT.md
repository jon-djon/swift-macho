# LC_LINKER_OPTIMIZATION_HINT

**Command ID:** `0x2E`

Points to linker optimization hint (LOH) data stored in the `__LINKEDIT` segment. LOHs are compiler-generated annotations that tell the linker about instruction sequences that can be rewritten into more efficient forms once final addresses are known.

Currently LOHs are specific to ARM64. The compiler emits them for common ADRP-based instruction patterns -- for example, an `ADRP` + `ADD` pair that loads an address might be optimizable into a single instruction if the target turns out to be within range after linking. The linker reads the LOH data and patches instruction sequences in the `__TEXT` segment where possible, reducing code size and improving performance.

The load command itself is a `linkedit_data_command` storing an offset and size into `__LINKEDIT`. The referenced data is a series of ULEB128-encoded entries, each specifying a hint kind followed by the addresses of the instructions involved.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_LINKER_OPTIMIZATION_HINT`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Data Offset | File offset of the LOH data in `__LINKEDIT` | 8 | 4 | `UInt32` |
| Data Size | Size of the LOH data in bytes | 12 | 4 | `UInt32` |

**Fixed size:** 16 bytes

## LOH Kinds (ARM64)

| Name | Value | Description |
|------|-------|-------------|
| `LOH_ARM64_ADRP_ADRP` | `1` | Two consecutive ADRPs to the same page |
| `LOH_ARM64_ADRP_LDR` | `2` | ADRP followed by LDR with page offset |
| `LOH_ARM64_ADRP_ADD_LDR` | `3` | ADRP + ADD + LDR sequence |
| `LOH_ARM64_ADRP_LDR_GOT_LDR` | `4` | ADRP + LDR (GOT) + LDR sequence |
| `LOH_ARM64_ADRP_ADD_STR` | `5` | ADRP + ADD + STR sequence |
| `LOH_ARM64_ADRP_LDR_GOT_STR` | `6` | ADRP + LDR (GOT) + STR sequence |
| `LOH_ARM64_ADRP_ADD` | `7` | ADRP + ADD pair |
| `LOH_ARM64_ADRP_LDR_GOT` | `8` | ADRP + LDR (GOT) pair |

## See Also

- [LC_FUNCTION_STARTS](LC_FUNCTION_STARTS.md) -- Function boundary information used alongside LOHs
- [LC_DATA_IN_CODE](LC_DATA_IN_CODE.md) -- Identifies data regions that LOHs must avoid

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_LINKER_OPTIMIZATION_HINT.swift`](../../Sources/SwiftMachO/LoadCommands/LC_LINKER_OPTIMIZATION_HINT.swift).
