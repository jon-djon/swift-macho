# LC_NOTE

**Command ID:** `0x31`

Attaches arbitrary named data to a Mach-O binary. Each `LC_NOTE` command identifies a data owner (a 16-character tag), a file offset, and a size pointing to the note's payload somewhere in the file.

Notes are used by tools to embed metadata that doesn't fit into other load command types. For example, `lldb` uses notes in core dump files to store process metadata, and the kernel uses them in fileset entries. The `data_owner` string identifies which tool or subsystem owns the note, so readers can skip notes they don't understand.

Multiple `LC_NOTE` commands can appear in a single binary, each with a different owner and payload.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_NOTE`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (40 bytes) | 4 | 4 | `UInt32` |
| Data Owner | Null-padded identifier for the note owner (e.g. `kern ver str`) | 8 | 16 | `char[16]` |
| Offset | File offset of the note data | 24 | 8 | `UInt64` |
| Size | Size of the note data in bytes | 32 | 8 | `UInt64` |

**Fixed size:** 40 bytes

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_NOTE.swift`](../../Sources/SwiftMachO/LoadCommands/LC_NOTE.swift).
