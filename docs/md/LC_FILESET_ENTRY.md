# LC_FILESET_ENTRY

**Command ID:** `0x80000035` (`LC_REQ_DYLD | 0x35`)

Describes one Mach-O binary within a fileset container. Filesets are used for kernel collections (the prelinked kernel cache on Apple Silicon Macs and newer iOS devices), where multiple kexts and the kernel itself are bundled into a single `MH_FILESET` Mach-O file.

Each `LC_FILESET_ENTRY` command provides the virtual address where the contained binary is mapped, the file offset to its Mach-O header, and a string identifier (typically the kext bundle ID). Tools can parse the inner Mach-O at the given file offset to inspect load commands, symbols, and code for that component.

The entry ID string is stored inline in the load command at the byte offset indicated by `Entry ID Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_FILESET_ENTRY`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the entry ID string) | 4 | 4 | `UInt32` |
| VM Address | Virtual memory address where this entry is mapped | 8 | 8 | `UInt64` |
| File Offset | File offset to the Mach-O header for this entry | 16 | 8 | `UInt64` |
| Entry ID Offset | Byte offset from the start of this command to the entry ID string | 24 | 4 | `UInt32` |
| Reserved | Reserved for future use | 28 | 4 | `UInt32` |
| Entry ID | Null-terminated identifier (e.g. kext bundle ID) | `Entry ID Offset` | variable | `String` |

**Minimum size:** 32 bytes (header + fixed fields, before entry ID string)

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_FILESET_ENTRY.swift`](../../Sources/SwiftMachO/LoadCommands/LC_FILESET_ENTRY.swift).
