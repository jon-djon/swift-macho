# LC_UUID

**Command ID:** `0x1B`

Stores a 128-bit universally unique identifier (UUID) for the binary. The linker generates this UUID at link time, and it remains constant for a given build output. Every Mach-O binary produced by the Apple toolchain includes this command.

The UUID serves as the primary key for associating a binary with its debug symbols (`.dSYM` bundle). When a crash report is generated or a debugger attaches, the UUID is used to locate the matching dSYM so that addresses can be symbolicated. `dsymutil`, `atos`, `lldb`, and Xcode's crash reporter all rely on this identifier.

The UUID is stored as 16 raw bytes in standard UUID byte order.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_UUID`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (24 bytes) | 4 | 4 | `UInt32` |
| UUID | 128-bit unique identifier | 8 | 16 | `UUID` |

**Fixed size:** 24 bytes

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_UUID.swift`](../../Sources/SwiftMachO/LoadCommands/LC_UUID.swift).
