# LC_DYLD_EXPORTS_TRIE

**Command ID:** `0x80000033` (`LC_REQ_DYLD | 0x33`)

Points to an export trie stored in the `__LINKEDIT` segment that describes all symbols exported by this image. The trie is a compact prefix tree where each terminal node encodes a symbol's flags, address, and optional re-export information.

This command was split out from `LC_DYLD_INFO_ONLY` to pair with `LC_DYLD_CHAINED_FIXUPS`. In the older format, the export trie was one of five data streams embedded in `LC_DYLD_INFO_ONLY`. Modern binaries use `LC_DYLD_CHAINED_FIXUPS` for rebase and bind data and `LC_DYLD_EXPORTS_TRIE` for export data, separating the two concerns into distinct load commands.

The dynamic linker (`dyld`), `nm`, `dyldinfo`, and other tools read the export trie to resolve symbol lookups. The trie format is particularly efficient for this -- looking up a symbol name requires walking one trie edge per prefix byte, which is faster than scanning a flat symbol table.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_DYLD_EXPORTS_TRIE`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Data Offset | File offset of the export trie in `__LINKEDIT` | 8 | 4 | `UInt32` |
| Data Size | Size of the export trie in bytes | 12 | 4 | `UInt32` |

**Fixed size:** 16 bytes

## Export Trie Format

The trie is a byte-encoded prefix tree. Each node begins with a terminal size (ULEB128). If non-zero, the node is a terminal containing export information for the symbol formed by concatenating all edge labels from the root to this node:

- **Flags** (ULEB128) -- Describes the export kind and attributes (regular, re-export, stub-and-resolver, weak, thread-local)
- **Address** (ULEB128) -- Offset from the image base for regular exports
- **Ordinal + name** -- For re-exports: the library ordinal (ULEB128) and the imported symbol name (null-terminated string, empty if same name)

After the terminal data, a child count byte indicates how many edges leave this node. Each edge is encoded as:

- **Edge label** -- A null-terminated string fragment
- **Child offset** -- ULEB128 offset from the start of the trie to the child node

### Export Flags

| Flag | Value | Description |
|------|-------|-------------|
| `EXPORT_SYMBOL_FLAGS_KIND_REGULAR` | `0x00` | Regular symbol |
| `EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL` | `0x01` | Thread-local variable |
| `EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE` | `0x02` | Absolute address (not slid by ASLR) |
| `EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION` | `0x04` | Weak definition |
| `EXPORT_SYMBOL_FLAGS_REEXPORT` | `0x08` | Re-exported from another dylib |
| `EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER` | `0x10` | Has a stub and lazy resolver function |

## See Also

- [LC_DYLD_CHAINED_FIXUPS](LC_DYLD_CHAINED_FIXUPS.md) -- Paired command providing rebase and bind data in modern binaries
- [LC_DYLD_INFO](LC_DYLD_INFO.md) -- Legacy command that included the export trie alongside rebase and bind streams



## Commandline

```
dyld_info -exports <path-to-binary>
```



## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_DYLD_EXPORTS_TRIE.swift`](../../Sources/SwiftMachO/LoadCommands/LC_DYLD_EXPORTS_TRIE.swift).
