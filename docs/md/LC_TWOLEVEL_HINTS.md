# LC_TWOLEVEL_HINTS

**Command ID:** `0x16`

**Obsolete.** Points to a table of two-level namespace hints that allowed `dyld` to quickly find the correct library for each undefined symbol without searching all loaded libraries. Each hint encoded a library index and a symbol table index, providing a fast path for symbol resolution.

Two-level hints were a performance optimization for the two-level namespace system (indicated by the `MH_TWOLEVEL` header flag). Modern versions of `dyld` no longer use the hints table -- the export trie and chained fixups provide equivalent or better lookup performance.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_TWOLEVEL_HINTS`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Hints Offset | File offset of the hints table | 8 | 4 | `UInt32` |
| Number of Hints | Number of entries in the hints table | 12 | 4 | `UInt32` |

**Fixed size:** 16 bytes

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_TWOLEVEL_HINTS.swift`](../../Sources/SwiftMachO/LoadCommands/LC_TWOLEVEL_HINTS.swift).
