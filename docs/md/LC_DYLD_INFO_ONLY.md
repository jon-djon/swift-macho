# LC_DYLD_INFO_ONLY

**Command ID:** `0x80000022` (`LC_REQ_DYLD | 0x22`)

Provides the dynamic linker (`dyld`) with compressed information needed to perform rebasing, binding, and symbol exporting. This is the required variant of `LC_DYLD_INFO` -- the `LC_REQ_DYLD` bit means that any version of `dyld` that does not understand this command will refuse to load the binary, rather than silently falling back to legacy relocation data.

In practice, `LC_DYLD_INFO_ONLY` is far more common than `LC_DYLD_INFO`. It appears in virtually all binaries linked between OS X 10.6 and the introduction of `LC_DYLD_CHAINED_FIXUPS` in macOS 11 / iOS 13.4. Modern binaries use chained fixups instead, but `LC_DYLD_INFO_ONLY` is still found in binaries targeting older deployment targets.

The command stores file offsets and sizes for five separate bytecode streams in the `__LINKEDIT` segment. See [LC_DYLD_INFO](LC_DYLD_INFO.md) for a detailed description of each data stream.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_DYLD_INFO_ONLY`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (48 bytes) | 4 | 4 | `UInt32` |
| Rebase Offset | File offset of the rebase bytecode in `__LINKEDIT` | 8 | 4 | `UInt32` |
| Rebase Size | Size of the rebase bytecode in bytes | 12 | 4 | `UInt32` |
| Bind Offset | File offset of the binding bytecode in `__LINKEDIT` | 16 | 4 | `UInt32` |
| Bind Size | Size of the binding bytecode in bytes | 20 | 4 | `UInt32` |
| Weak Bind Offset | File offset of the weak binding bytecode in `__LINKEDIT` | 24 | 4 | `UInt32` |
| Weak Bind Size | Size of the weak binding bytecode in bytes | 28 | 4 | `UInt32` |
| Lazy Bind Offset | File offset of the lazy binding bytecode in `__LINKEDIT` | 32 | 4 | `UInt32` |
| Lazy Bind Size | Size of the lazy binding bytecode in bytes | 36 | 4 | `UInt32` |
| Export Offset | File offset of the export trie in `__LINKEDIT` | 40 | 4 | `UInt32` |
| Export Size | Size of the export trie in bytes | 44 | 4 | `UInt32` |

**Fixed size:** 48 bytes

## See Also

- [LC_DYLD_INFO](LC_DYLD_INFO.md) -- Same layout without `LC_REQ_DYLD`; includes detailed data stream descriptions
- [LC_DYLD_CHAINED_FIXUPS](LC_DYLD_CHAINED_FIXUPS.md) -- Modern replacement for rebase and bind data
- [LC_DYLD_EXPORTS_TRIE](LC_DYLD_EXPORTS_TRIE.md) -- Modern replacement for the export trie (when used with chained fixups)

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_DYLD_INFO_ONLY.swift`](../../Sources/SwiftMachO/LoadCommands/LC_DYLD_INFO_ONLY.swift).
