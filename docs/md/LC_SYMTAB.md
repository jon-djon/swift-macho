# LC_SYMTAB

**Command ID:** `0x02`

Specifies the location and size of the symbol table and the string table within the Mach-O binary. The symbol table maps symbol names to addresses and metadata, while the string table stores the actual name strings referenced by index from each symbol entry.

The static linker, the dynamic linker (`dyld`), and debugging tools (`lldb`, `nm`, `dsymutil`) all rely on this command to resolve names to addresses. The symbol table and string table data live in the `__LINKEDIT` segment, not inline in the load command itself -- the command only records file offsets and sizes that point into `__LINKEDIT`.

During parsing, the symbol table is read as an array of `nlist` / `nlist_64` entries (12 or 16 bytes each for 32-bit and 64-bit binaries respectively). Each entry's `n_strx` field is an index into the string table to retrieve the symbol's name.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_SYMTAB`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command | 4 | 4 | `UInt32` |
| Symbol Table Offset | File offset of the symbol table | 8 | 4 | `UInt32` |
| Number of Symbols | Number of entries in the symbol table | 12 | 4 | `UInt32` |
| String Table Offset | File offset of the string table | 16 | 4 | `UInt32` |
| String Table Size | Size of the string table in bytes | 20 | 4 | `UInt32` |

**Fixed size:** 24 bytes

## Symbol (nlist / nlist_64)

Each symbol table entry describes one symbol. The entry size depends on the binary's architecture: 12 bytes for 32-bit, 16 bytes for 64-bit.

| Name | Description | Offset | Size (32/64) | Type |
|------|-------------|--------|--------------|------|
| n_strx | Index into the string table for this symbol's name | 0 | 4 | `UInt32` |
| n_type | Type flags (see below) | 4 | 1 | `SymbolType` |
| n_sect | Section ordinal (1-based) if type includes `N_SECT`, otherwise `NO_SECT` | 5 | 1 | `UInt8` |
| n_desc | Additional descriptor, encodes debugger stab type or library ordinal info | 6 | 2 | `UInt16` |
| n_value | Symbol value -- typically the virtual address for defined symbols | 8 | 4 / 8 | `UInt32` / `UInt64` |

**Entry size:** 12 bytes (32-bit) or 16 bytes (64-bit)

### SymbolType

The `n_type` byte is a bitmask combining several fields:

| Flag | Value | Description |
|------|-------|-------------|
| `N_EXT` | `0x01` | External (global) symbol |
| `N_ABS` | `0x02` | Absolute symbol (not relocated) |
| `N_TYPE` | `0x0E` | Mask for the symbol type bits |
| `N_SECT` | `0x0E` | Symbol is defined in the section given by `n_sect` |
| `N_INDR` | `0x0A` | Indirect symbol |
| `N_PBUD` | `0x0C` | Prebound undefined (defined in a dylib) |
| `N_STAB` | `0xE0` | Mask for stab (debugger symbol) bits |

When `n_type & N_STAB` is non-zero, the symbol is a debug symbol and `n_desc` holds a stab type.

### Debugger Symbols (STAB types)

When the stab mask is set, `n_desc` identifies the debugger symbol kind:

| Name | Value | Description |
|------|-------|-------------|
| `N_GSYM` | `0x20` | Global symbol |
| `N_FNAME` | `0x22` | Procedure name (F77) |
| `N_FUN` | `0x24` | Procedure: name, section, line number, address |
| `N_STSYM` | `0x26` | Static symbol |
| `N_LCSYM` | `0x28` | `.lcomm` symbol |
| `N_BNSYM` | `0x2E` | Begin nsect symbol |
| `N_AST` | `0x32` | AST file path |
| `N_OPT` | `0x3C` | Compiler option |
| `N_RSYM` | `0x40` | Register symbol |
| `N_SLINE` | `0x44` | Source line |
| `N_ENSYM` | `0x4E` | End nsect symbol |
| `N_SSYM` | `0x60` | Structure element |
| `N_SO` | `0x64` | Source file name |
| `N_OSO` | `0x66` | Object file name |
| `N_LSYM` | `0x80` | Local symbol |
| `N_BINCL` | `0x82` | Begin include file |
| `N_SOL` | `0x84` | Included file name |
| `N_PARAMS` | `0x86` | Compiler parameters |
| `N_VERSION` | `0x88` | Compiler version |
| `N_OLEVEL` | `0x8A` | Compiler optimization level |
| `N_PSYM` | `0xA0` | Parameter |
| `N_EINCL` | `0xA2` | End include file |
| `N_ENTRY` | `0xA4` | Alternate entry point |
| `N_LBRAC` | `0xC0` | Left bracket (scope begin) |
| `N_EXCL` | `0xC2` | Deleted include file |
| `N_RBRAC` | `0xE0` | Right bracket (scope end) |
| `N_BCOMM` | `0xE2` | Begin common |
| `N_ECOMM` | `0xE4` | End common |
| `N_ECOML` | `0xE8` | End common (local name) |
| `N_LENG` | `0xFE` | Second stab entry with length information |
| `N_PC` | `0x30` | Global Pascal symbol |

## See Also

- [LC_DYSYMTAB](../../Sources/SwiftMachO/LoadCommands/LC_DYSYMTAB.swift) -- Dynamic symbol table command that subdivides this symbol table for use by `dyld`

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_SYMTAB/LC_SYMTAB.swift`](../../Sources/SwiftMachO/LoadCommands/LC_SYMTAB/LC_SYMTAB.swift) and [`Sources/SwiftMachO/LoadCommands/LC_SYMTAB/Symbol.swift`](../../Sources/SwiftMachO/LoadCommands/LC_SYMTAB/Symbol.swift).
