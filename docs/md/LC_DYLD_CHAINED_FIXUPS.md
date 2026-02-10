# LC_DYLD_CHAINED_FIXUPS

**Command ID:** `0x80000034` (LC_REQ_DYLD | 0x34)

Specifies the location and size of chained fixups data stored in the `__LINKEDIT` segment. Chained fixups are a modern, highly optimized format introduced by Apple to improve application launch performance by allowing the dynamic linker (dyld) to process rebasing and binding operations more efficiently.

## Purpose

LC_DYLD_CHAINED_FIXUPS replaces the older LC_DYLD_INFO_ONLY command with a more compact and efficient representation of dynamic linking information. The key advantages of chained fixups include:

- **Reduced binary size** - Chained fixups can be 2-3x smaller than the traditional fixup format
- **Faster launch times** - dyld can process fixups more quickly with less I/O
- **Better memory efficiency** - Less data needs to be loaded and processed at startup
- **Improved code signing** - More efficient representation of code signatures
- **Page-in optimization** - Better locality of reference reduces page faults

The chained fixups format stores fixup information as a chain of pointers embedded directly in the pages that need fixing up, rather than as separate rebase and bind opcodes. This allows dyld to walk through memory pages linearly, applying fixups as it goes.

## How Chained Fixups Work

In the traditional format, dyld would read separate tables of rebase and bind operations, then apply them to various locations in memory. With chained fixups:

1. **Chaining** - Each fixup location contains the offset to the next fixup in the same page
2. **In-place storage** - Fixup metadata is stored directly in the locations that need fixing up
3. **Page-aligned processing** - dyld processes one page at a time, following the chain
4. **Reduced I/O** - Only pages with fixups need to be read and modified

This approach is particularly beneficial on iOS and other memory-constrained platforms where fast startup is critical.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_DYLD_CHAINED_FIXUPS`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Data Offset | File offset of the chained fixups data in `__LINKEDIT` | 8 | 4 | `UInt32` |
| Data Size | Size of the chained fixups data in bytes | 12 | 4 | `UInt32` |

**Total size:** 16 bytes

## Chained Fixups Data Structure

The data referenced by `Data Offset` contains a `dyld_chained_fixups_header` followed by various tables:

```
struct dyld_chained_fixups_header {
    uint32_t fixups_version;        // 0
    uint32_t starts_offset;         // Offset of dyld_chained_starts_in_image
    uint32_t imports_offset;        // Offset of imports table
    uint32_t symbols_offset;        // Offset of symbol strings
    uint32_t imports_count;         // Number of imported symbols
    uint32_t imports_format;        // DYLD_CHAINED_IMPORT* format
    uint32_t symbols_format;        // 0 => uncompressed
}
```

The starts table describes where chains begin in each segment, the imports table contains information about imported symbols, and the symbols section contains null-terminated strings for symbol names.

## Adoption

LC_DYLD_CHAINED_FIXUPS is the default format for:

- **iOS 13.4+** and later
- **macOS 11.0+** (Big Sur) and later
- **tvOS 13.4+** and later
- **watchOS 6.2+** and later

Binaries using chained fixups require these OS versions or later to run. Older systems will fail to load binaries with this command.

## Related Commands

- **LC_DYLD_INFO_ONLY** - Legacy dynamic linking information format (superseded)
- **LC_DYLD_INFO** - Older version of LC_DYLD_INFO_ONLY
- **LC_DYLD_EXPORTS_TRIE** - Can be used alongside chained fixups for exports
- **LC_SEGMENT_SPLIT_INFO** - Older optimization for ASLR (Address Space Layout Randomization)

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_DYLD_CHAINED_FIXUPS.swift`](../../Sources/SwiftMachO/LoadCommands/LC_DYLD_CHAINED_FIXUPS.swift).

## References

- [dyld source code](https://github.com/apple-oss-distributions/dyld) - Apple's open source dynamic linker
- WWDC 2019 Session 415: "Optimizing App Launch" - Introduction to chained fixups
- [MachO file format documentation](https://github.com/apple-oss-distributions/xnu/blob/main/EXTERNAL_HEADERS/mach-o/loader.h)
