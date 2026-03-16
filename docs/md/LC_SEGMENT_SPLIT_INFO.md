# LC_SEGMENT_SPLIT_INFO

**Command ID:** `0x1E`

Points to split segment information stored in the `__LINKEDIT` segment. This data helps the dynamic linker and the shared cache builder optimize memory usage by tracking which locations in read-only segments contain pointers to writable segments, allowing pages to be shared across processes while still supporting ASLR.

The load command itself is a `linkedit_data_command` storing an offset and size into `__LINKEDIT`. The referenced data comes in two formats:

- **V1** -- A simple list of ULEB128-encoded offset deltas, each identifying a fixup location
- **V2** -- A hierarchical structure with section-level granularity and pointer type information, identified by a `0x7F` marker byte at the start

Split segment info was used extensively in the dyld shared cache before chained fixups (`LC_DYLD_CHAINED_FIXUPS`) became the standard. It is still present in some binaries and in shared cache construction.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_SEGMENT_SPLIT_INFO`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Data Offset | File offset of the split segment info in `__LINKEDIT` | 8 | 4 | `UInt32` |
| Data Size | Size of the split segment info in bytes | 12 | 4 | `UInt32` |

**Fixed size:** 16 bytes

### V2 Pointer Kinds

| Name | Value | Description |
|------|-------|-------------|
| `pointer64` | `1` | 64-bit pointer |
| `delta64` | `2` | 64-bit delta |
| `delta32` | `3` | 32-bit delta |
| `arm64ADRP` | `4` | ARM64 ADRP instruction |
| `arm64Off12` | `5` | ARM64 12-bit offset instruction |
| `arm64Br26` | `6` | ARM64 26-bit branch |
| `armMovwMovt` | `7` | ARM MOVW/MOVT pair |
| `armBr24` | `8` | ARM 24-bit branch |
| `thumbMovwMovt` | `9` | Thumb MOVW/MOVT pair |
| `thumbBr22` | `10` | Thumb 22-bit branch |
| `imageOff32` | `11` | 32-bit image offset |
| `threaded` | `12` | Threaded 64-bit pointer |

## See Also

- [LC_DYLD_CHAINED_FIXUPS](LC_DYLD_CHAINED_FIXUPS.md) -- Modern replacement for fixup information

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_SEGMENT_SPLIT_INFO.swift`](../../Sources/SwiftMachO/LoadCommands/LC_SEGMENT_SPLIT_INFO.swift).
