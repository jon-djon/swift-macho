# LC_PREBIND_CKSUM

**Command ID:** `0x17`

**Obsolete.** Stores a checksum computed during the prebinding operation. The prebinding system used this checksum to detect whether a prebound binary's dependencies had changed since it was last prebound. If the checksum didn't match, `dyld` would fall back to full runtime binding.

A value of zero indicates the binary has not been prebound. Prebinding has been superseded by the dyld shared cache and chained fixups.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_PREBIND_CKSUM`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (12 bytes) | 4 | 4 | `UInt32` |
| Checksum | Prebinding checksum (0 if not prebound) | 8 | 4 | `UInt32` |

**Fixed size:** 12 bytes

## See Also

- [LC_PREBOUND_DYLIB](LC_PREBOUND_DYLIB.md) -- Records prebinding data for a dependent library

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_PREBIND_CKSUM.swift`](../../Sources/SwiftMachO/LoadCommands/LC_PREBIND_CKSUM.swift).
