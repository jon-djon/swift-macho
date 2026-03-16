# LC_DYLD_INFO

**Command ID:** `0x22`

Provides the dynamic linker (`dyld`) with compressed information needed to perform rebasing, binding, and symbol exporting. The command stores file offsets and sizes for five separate data streams in the `__LINKEDIT` segment, each encoded as a compact bytecode program that `dyld` interprets at load time.

This command was introduced as a more efficient replacement for the traditional relocation entries and indirect symbol tables used by `LC_DYSYMTAB`. It was later superseded itself by `LC_DYLD_CHAINED_FIXUPS` and `LC_DYLD_EXPORTS_TRIE` in modern binaries, which offer even better launch performance.

`LC_DYLD_INFO` differs from `LC_DYLD_INFO_ONLY` only in backward compatibility: older versions of `dyld` that do not understand the compressed format will ignore `LC_DYLD_INFO` and fall back to `LC_DYSYMTAB` relocations, whereas `LC_DYLD_INFO_ONLY` has the `LC_REQ_DYLD` bit set and will cause old `dyld` versions to refuse to load the binary entirely. In practice, `LC_DYLD_INFO` is rare -- most binaries use `LC_DYLD_INFO_ONLY`.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_DYLD_INFO`) | 0 | 4 | `UInt32` |
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

## Data Streams

All five data regions reside in the `__LINKEDIT` segment. An offset or size of zero indicates that the corresponding data is not present.

- **Rebase info** -- A bytecode program that tells `dyld` which locations in writable segments need to be adjusted by the ASLR slide. Each instruction encodes an address and a type (pointer, text absolute, text PC-relative).

- **Bind info** -- A bytecode program describing non-lazy symbol bindings. Each instruction specifies a symbol name, the library ordinal it comes from, the target address to patch, and the binding type. `dyld` processes these at load time before transferring control to the executable.

- **Weak bind info** -- Similar to bind info, but for symbols marked as weak imports. Multiple definitions of a weak symbol may exist across loaded images; `dyld` coalesces them to a single address.

- **Lazy bind info** -- Binding instructions for lazily-bound symbols. These are not processed at launch. Instead, each lazy symbol pointer initially points to a stub that calls `dyld_stub_binder`, which reads the lazy bind info on first use and patches the pointer to the resolved address.

- **Export info** -- A trie (prefix tree) encoding all symbols exported by this image. Each terminal node stores the symbol's flags and address (or re-export information). Tools like `dyldinfo -exports` and `nm -m` read this data.

## See Also

- [LC_DYLD_INFO_ONLY](LC_DYLD_INFO_ONLY.md) -- Same layout with `LC_REQ_DYLD` set; the more common variant
- [LC_DYLD_CHAINED_FIXUPS](LC_DYLD_CHAINED_FIXUPS.md) -- Modern replacement for rebase and bind data
- [LC_DYSYMTAB](LC_DYSYMTAB.md) -- Legacy relocation and indirect symbol tables that this command replaced

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_DYLD_INFO.swift`](../../Sources/SwiftMachO/LoadCommands/LC_DYLD_INFO.swift).
