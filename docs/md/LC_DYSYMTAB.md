# LC_DYSYMTAB

**Command ID:** `0x0B`

Subdivides the symbol table (defined by `LC_SYMTAB`) into groups that the dynamic linker (`dyld`) can use efficiently at runtime. Rather than scanning every symbol, `dyld` can jump directly to the external or undefined symbol ranges it needs.

The command also records file offsets and counts for several auxiliary tables stored in the `__LINKEDIT` segment: a table of contents for multi-module images, a module table, an external reference symbol table, an indirect symbol table, and external and local relocation entries. In modern single-module executables and dylibs most of these auxiliary tables are empty -- the indirect symbol table is the main one still in active use, mapping stub and pointer slots in `__stubs` and `__got` sections back to symbol table indices.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_DYSYMTAB`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command | 4 | 4 | `UInt32` |
| Local Symbol Index | Index of the first local symbol in the symbol table | 8 | 4 | `UInt32` |
| Num Local Symbols | Number of local symbols | 12 | 4 | `UInt32` |
| External Symbol Index | Index of the first externally defined symbol | 16 | 4 | `UInt32` |
| Num External Symbols | Number of externally defined symbols | 20 | 4 | `UInt32` |
| Undefined Symbol Index | Index of the first undefined symbol | 24 | 4 | `UInt32` |
| Num Undefined Symbols | Number of undefined symbols | 28 | 4 | `UInt32` |
| TOC Offset | File offset of the table of contents | 32 | 4 | `UInt32` |
| Num TOC Entries | Number of entries in the table of contents | 36 | 4 | `UInt32` |
| Module Table Offset | File offset of the module table | 40 | 4 | `UInt32` |
| Num Module Table Entries | Number of entries in the module table | 44 | 4 | `UInt32` |
| External Reference Symbol Offset | File offset of the external reference symbol table | 48 | 4 | `UInt32` |
| Num External Reference Symbols | Number of external reference symbol entries | 52 | 4 | `UInt32` |
| Indirect Symbol Offset | File offset of the indirect symbol table | 56 | 4 | `UInt32` |
| Num Indirect Symbols | Number of indirect symbol entries | 60 | 4 | `UInt32` |
| External Relocation Offset | File offset of the external relocation entries | 64 | 4 | `UInt32` |
| Num External Relocations | Number of external relocation entries | 68 | 4 | `UInt32` |
| Local Relocation Offset | File offset of the local relocation entries | 72 | 4 | `UInt32` |
| Num Local Relocations | Number of local relocation entries | 76 | 4 | `UInt32` |

**Fixed size:** 80 bytes

## Symbol Table Grouping

The first six fields after the header divide the symbol table from `LC_SYMTAB` into three contiguous, non-overlapping groups. The symbol table must be arranged so that local symbols come first, followed by externally defined symbols, followed by undefined symbols:

```
┌──────────────────────────────┐  ← localSymbolIndex
│  Local symbols               │
│  (private to this image)     │
├──────────────────────────────┤  ← externalSymbolIndex
│  Externally defined symbols  │
│  (exported by this image)    │
├──────────────────────────────┤  ← undefinedSymbolIndex
│  Undefined symbols           │
│  (imported, resolved by dyld)│
└──────────────────────────────┘
```

## Indirect Symbol Table

The indirect symbol table is an array of `UInt32` values, each being an index into the main symbol table. It provides the mapping that `dyld` uses to bind lazy and non-lazy symbol pointers.

Sections of type `S_LAZY_SYMBOL_POINTERS`, `S_NON_LAZY_SYMBOL_POINTERS`, and `S_SYMBOL_STUBS` each have a `reserved1` field in their section header that gives the starting index into the indirect symbol table for that section. Each slot in the section corresponds to one entry in the indirect symbol table, which in turn points to the full symbol information in the main symbol table.

Two special values may appear:

| Name | Value | Description |
|------|-------|-------------|
| `INDIRECT_SYMBOL_LOCAL` | `0x80000000` | Slot refers to a local symbol (no symbol table entry needed) |
| `INDIRECT_SYMBOL_ABS` | `0x40000000` | Slot refers to an absolute symbol |

## Table of Contents, Module Table, and External References

These tables support multi-module dynamic libraries, a feature that is largely historical. In modern single-module images these fields are typically all zero.

- **Table of Contents** -- Maps external symbols to the module that defines them, allowing the dynamic linker to load only the required modules.
- **Module Table** -- Describes each module within the dynamic library, including its symbol ranges and initialization/termination function pointers.
- **External Reference Symbols** -- Lists, per module, which symbols are referenced from other modules in the same library.

## Relocation Entries

- **External Relocations** -- Relocation entries for symbols defined in other images. In modern `dyld`-based linking these are largely replaced by chained fixups (`LC_DYLD_CHAINED_FIXUPS`).
- **Local Relocations** -- Relocation entries for symbols defined within this image. Also largely superseded by chained fixups in modern binaries.

## See Also

- [LC_SYMTAB](LC_SYMTAB.md) -- Defines the symbol table that this command subdivides
- [LC_DYLD_CHAINED_FIXUPS](LC_DYLD_CHAINED_FIXUPS.md) -- Modern replacement for relocation entries

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_DYSYMTAB.swift`](../../Sources/SwiftMachO/LoadCommands/LC_DYSYMTAB.swift).
