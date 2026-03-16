# LC_RPATH

**Command ID:** `0x8000001C` (`LC_REQ_DYLD | 0x1C`)

Adds a directory to the runpath search list used by the dynamic linker (`dyld`) to resolve libraries referenced with `@rpath`. Each `LC_RPATH` command contributes one directory to the search list, and multiple commands can appear in a single binary to define several search paths.

When a dependent library's install name begins with `@rpath/`, `dyld` substitutes each runpath entry in order until it finds the library. This provides a flexible deployment mechanism -- the same binary can find its libraries in different locations depending on how it was installed, without hardcoding absolute paths.

Common runpath values include:
- `@executable_path/../Frameworks` -- relative to the main executable (apps)
- `@loader_path/../Frameworks` -- relative to the binary containing the `LC_RPATH` (frameworks loading other frameworks)

The path string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command). The linker flag `-rpath` produces this command.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_RPATH`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the path string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the path string | 8 | 4 | `UInt32` |
| Name | Null-terminated runpath search directory | `Name Offset` | variable | `String` |

**Minimum size:** 12 bytes (header + fixed fields, before path string)

## See Also

- [LC_LOAD_DYLIB](LC_LOAD_DYLIB.md) -- Libraries whose install names may use `@rpath`

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_RPATH.swift`](../../Sources/SwiftMachO/LoadCommands/LC_RPATH.swift).
