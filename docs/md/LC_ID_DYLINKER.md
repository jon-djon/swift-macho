# LC_ID_DYLINKER

**Command ID:** `0x0F`

Identifies the name of the dynamic linker itself. This command appears inside the dynamic linker's own Mach-O binary (`/usr/lib/dyld`) to record its install path, the same way `LC_ID_DYLIB` records a shared library's install name.

While `LC_LOAD_DYLINKER` is found in executables and tells the kernel *which* dynamic linker to use, `LC_ID_DYLINKER` is found in the dynamic linker binary and declares *what* dynamic linker it is. The kernel does not use this command directly -- it exists so that tools inspecting the dyld binary can identify it.

The name string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_ID_DYLINKER`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the name string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the dylinker name string | 8 | 4 | `UInt32` |
| Name | Null-terminated path identifying this dynamic linker (e.g. `/usr/lib/dyld`) | `Name Offset` | variable | `String` |

**Minimum size:** 12 bytes (header + fixed fields, before name string)

## Relationship to LC_LOAD_DYLINKER

| Command | Found in | Purpose |
|---------|----------|---------|
| `LC_LOAD_DYLINKER` | Executables | Tells the kernel which dynamic linker to load |
| `LC_ID_DYLINKER` | The dynamic linker binary itself | Declares the install name of the dynamic linker |

This mirrors the `LC_LOAD_DYLIB` / `LC_ID_DYLIB` pair used for shared libraries.

## See Also

- [LC_LOAD_DYLINKER](LC_LOAD_DYLINKER.md) -- Specifies the dynamic linker to use when loading an executable

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_ID_DYLINKER.swift`](../../Sources/SwiftMachO/LoadCommands/LC_ID_DYLINKER.swift).
