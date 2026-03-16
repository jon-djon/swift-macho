# LC_DYLD_ENVIRONMENT

**Command ID:** `0x27`

Embeds a `dyld` environment variable directly in the Mach-O binary. When `dyld` loads the executable, it reads these commands and applies the environment variables as if they had been set in the process environment before launch.

The value is stored as a `KEY=VALUE` string (e.g. `DYLD_FRAMEWORK_PATH=/opt/frameworks`). This allows a binary to configure `dyld` behavior without relying on the external environment, which is useful for self-contained executables or testing scenarios.

For security reasons, `dyld` restricts which environment variables are honored from this command. Only variables that `dyld` recognizes are accepted, and restricted binaries (setuid/setgid, hardened runtime, or platform binaries) may ignore them entirely. This prevents arbitrary environment injection via binary modification.

The string is stored inline in the load command at the byte offset indicated by `Name Offset` (relative to the start of the command).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_DYLD_ENVIRONMENT`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the string) | 4 | 4 | `UInt32` |
| Name Offset | Byte offset from the start of this command to the environment string | 8 | 4 | `UInt32` |
| Name | Environment variable in `KEY=VALUE` format | `Name Offset` | variable | `String` |

**Minimum size:** 12 bytes (header + fixed fields, before string)

## See Also

- [LC_LOAD_DYLINKER](LC_LOAD_DYLINKER.md) -- Specifies which dynamic linker processes these environment variables

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_DYLD_ENVIRONMENT.swift`](../../Sources/SwiftMachO/LoadCommands/LC_DYLD_ENVIRONMENT.swift).
