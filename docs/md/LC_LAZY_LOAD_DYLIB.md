# LC_LAZY_LOAD_DYLIB

**Command ID:** `0x20`

Specifies a dynamic library that is loaded lazily -- only when a symbol from it is first used at runtime. Unlike `LC_LOAD_DYLIB`, which causes `dyld` to load and link the library before `main` is called, a lazy-loaded library is deferred until the process actually calls one of its functions or accesses one of its symbols.

Lazy loading improves launch time for executables that depend on libraries they may not use in every run. For example, a command-line tool that only invokes printing functionality in rare cases can mark the printing framework as lazy so it is never loaded during typical use. The linker flag `-lazy_library` or `-lazy-l<name>` produces this command.

If the lazy library cannot be found or loaded when its first symbol is needed, `dyld` will abort the process at that point rather than at launch.

The binary layout is identical to `LC_LOAD_DYLIB`. The name string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_LAZY_LOAD_DYLIB`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the library name string | 8 | 4 | `UInt32` |
| Timestamp | Build timestamp of the linked library | 12 | 4 | `UInt32` |
| Current Version | Current version of the library at link time | 16 | 4 | `SemanticVersion` |
| Compatibility Version | Minimum compatible version required at runtime | 20 | 4 | `SemanticVersion` |
| Name | Null-terminated install name path of the dynamic library | `Name Offset` | variable | `String` |

**Minimum size:** 24 bytes (header + fixed fields, before name string)

## See Also

- [LC_LOAD_DYLIB](LC_LOAD_DYLIB.md) -- Same layout; loads the library eagerly at launch
- [LC_LOAD_WEAK_DYLIB](LC_LOAD_WEAK_DYLIB.md) -- Same layout; loads eagerly but tolerates the library being absent

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_LAZY_LOAD_DYLIB.swift`](../../Sources/SwiftMachO/LoadCommands/LC_LAZY_LOAD_DYLIB.swift).
